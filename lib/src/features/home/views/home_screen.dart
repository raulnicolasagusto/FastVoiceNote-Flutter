import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../widgets/note_card.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../notes/providers/notes_provider.dart';
import '../../notes/widgets/move_to_folder_modal.dart';
import '../../notes/widgets/create_folder_modal.dart';
import 'package:intl/intl.dart';
import '../../notes/models/note.dart';
import '../../notes/models/checklist_utils.dart';
import '../../transcription/services/audio_recorder_service.dart';
import '../../transcription/widgets/recording_dialog.dart';
import '../../transcription/utils/voice_to_checklist_processor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  late TabController _tabController;
  bool _isFabExpanded = false;
  final Set<String> _selectedNotes = {};
  bool _foldersLoaded = false;
  
  // Search state
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    await AppFolders.loadCustomFolders();
    if (mounted) {
      final newLength = 1 + AppFolders.getAllFolders().length;
      _tabController = TabController(length: newLength, vsync: this);
      setState(() {
        _foldersLoaded = true;
      });
    }
  }

  int _getTabCount() {
    // 1 (All Notes) + number of folders
    return 1 + AppFolders.getAllFolders().length;
  }

  List<String?> _getFolderIds() {
    // Return list of folder IDs: null for "All Notes", then all folder IDs
    final allFolders = AppFolders.getAllFolders();
    return [null, ...allFolders.keys];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  bool get _isSelectionMode => _selectedNotes.isNotEmpty;

  void _toggleSelection(String noteId) {
    setState(() {
      if (_selectedNotes.contains(noteId)) {
        _selectedNotes.remove(noteId);
      } else {
        _selectedNotes.add(noteId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNotes.clear();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchQuery = '';
        _searchFocusNode.unfocus();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Note> _getFilteredNotes(List<Note> allNotes, String? folderId) {
    List<Note> filtered = folderId == null
        ? List.from(allNotes)
        : allNotes.where((note) => note.folderId == folderId).toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((note) {
        // Search in title
        if (note.title.toLowerCase().contains(_searchQuery)) return true;
        
        // Search in content (including checklist items)
        final content = ChecklistUtils.getPreview(note.content).toLowerCase();
        if (content.contains(_searchQuery)) return true;
        
        // Search in date
        final dateStr = DateFormat('dd/MM/yyyy').format(note.updatedAt).toLowerCase();
        if (dateStr.contains(_searchQuery)) return true;
        
        return false;
      }).toList();
    }

    // Sort: pinned first, then by updatedAt (newest first)
    filtered.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return b.isPinned ? 1 : -1; // Pinned (true) first
      }
      return b.updatedAt.compareTo(a.updatedAt); // Newest first
    });

    return filtered;
  }

  Widget _buildNoteGrid(List<Note> notesToShow, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 0.1,
        left: 8,
        right: 8,
        bottom: 8,
      ),
      child: notesToShow.isEmpty
          ? Center(
              child: Text(
                'No notes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            )
          : MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: notesToShow.length,
              itemBuilder: (context, index) {
                final note = notesToShow[index];
                final preview = ChecklistUtils.getPreview(note.content);
                final isSelected = _selectedNotes.contains(note.id);
                return GestureDetector(
                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleSelection(note.id);
                    } else {
                      context.push('/note/${note.id}');
                    }
                  },
                  onLongPress: () {
                    _toggleSelection(note.id);
                  },
                  child: NoteCard(
                    title: note.title,
                    date: note.updatedAt,
                    content: preview,
                    color: Color(int.parse('0x${note.color}')),
                    hasImage: note.hasImage,
                    hasVoice: note.hasVoice,
                    isSelected: isSelected,
                    isPinned: note.isPinned,
                  ),
                );
              },
            ),
    );
  }

  List<Tab> _buildTabs(AppLocalizations l10n) {
    final folderIds = _getFolderIds();
    return folderIds.map((folderId) {
      if (folderId == null) {
        return Tab(text: l10n.allTab);
      }
      final folderName = AppFolders.getFolderName(folderId);
      final isCustomFolder = !AppFolders.isDefaultFolder(folderId);
      
      // Si es carpeta personalizada, permitir long press para editar/eliminar
      if (isCustomFolder) {
        return Tab(
          child: GestureDetector(
            onLongPress: () => _showEditFolderDialog(folderId, folderName),
            child: Text(folderName),
          ),
        );
      }
      
      return Tab(text: folderName);
    }).toList();
  }

  List<Widget> _buildTabViews(List<Note> notes, BuildContext context) {
    final folderIds = _getFolderIds();
    return folderIds.map((folderId) {
      return _buildNoteGrid(_getFilteredNotes(notes, folderId), context);
    }).toList();
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final count = _selectedNotes.length;
    if (count == 0) return;

    final isSingle = count == 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSingle ? l10n.deleteSingleTitle : l10n.deleteMultipleTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  isSingle
                      ? l10n.deleteSingleMessage
                      : l10n.deleteMultipleMessage(count.toString()),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.deleteCancel,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.deleteConfirm,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await context.read<NotesProvider>().deleteNotes(_selectedNotes.toList());
      _clearSelection();
    }
  }

  void _showMoveToFolderModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => MoveToFolderModal(
        onFolderSelected: (folderId) async {
          // Mover las notas
          await context.read<NotesProvider>().moveNotes(
            _selectedNotes.toList(),
            folderId,
          );
          
          // Limpiar la selección
          _clearSelection();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  folderId == null 
                    ? 'Moved to All Notes'
                    : 'Moved to ${AppFolders.getFolderName(folderId)}',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showCreateFolderModal() {
    showDialog(
      context: context,
      builder: (context) => CreateFolderModal(
        onFolderCreated: (folderName) async {
          Navigator.of(context).pop();
          
          // Generate a unique folder ID
          final folderId = 'folder_${DateTime.now().millisecondsSinceEpoch}';
          
          // Add folder to AppFolders
          await AppFolders.addCustomFolder(folderId, folderName);
          
          // Recreate TabController with new count
          final oldController = _tabController;
          final newLength = 1 + AppFolders.getAllFolders().length;
          _tabController = TabController(length: newLength, vsync: this);
          oldController.dispose();
          
          // Rebuild UI
          setState(() {});
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Folder "$folderName" created')),
          );
        },
      ),
    );
  }

  void _showEditFolderDialog(String folderId, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            border: OutlineInputBorder(),
          ),
          maxLength: 30,
        ),
        actions: [
          // Delete button
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteFolder(folderId, currentName);
            },
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const Spacer(),
          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          // Save button
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                await AppFolders.renameFolder(folderId, newName);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Renamed to "$newName"')),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFolder(String folderId, String folderName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Delete "$folderName"? Notes will move to All.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Move notes from this folder to null (All)
              final notesProvider = context.read<NotesProvider>();
              final notesToMove = notesProvider.notes
                  .where((note) => note.folderId == folderId)
                  .map((note) => note.id)
                  .toList();
              
              if (notesToMove.isNotEmpty) {
                await notesProvider.moveNotes(notesToMove, null);
              }
              
              // Delete folder
              await AppFolders.deleteFolder(folderId);
              
              // Recreate TabController with new count
              final oldController = _tabController;
              final newLength = 1 + AppFolders.getAllFolders().length;
              _tabController = TabController(length: newLength, vsync: this);
              oldController.dispose();
              
              // Rebuild UI
              setState(() {});
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "$folderName"')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _onQuickVoiceNote() async {
    // 1. Close FAB first
    _toggleFab();

    // 2. Initialize service (loads native lib & model if first time)
    final recorderService = AudioRecorderService();
    try {
      // Set language based on app's current locale
      final locale = Localizations.localeOf(context);
      final languageCode = locale.languageCode; // 'en', 'es', 'pt', etc.
      recorderService.setLanguage(languageCode);
      
      await recorderService.init();

      // 3. Start recording immediately logic
      final started = await recorderService.startRecording();
      if (!started && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
        return;
      }

      if (!mounted) return;

      // 4. Show Dialog
      // We keep the dialog open until Stop/Cancel
      final processed = await showDialog<ProcessedTranscription>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => RecordingDialog(
          onCancel: () async {
            await recorderService.cancel();
            Navigator.of(dialogContext).pop(); // Return null
          },
          onStop: () async {
            // TODO: Add loading feedback in RecordingDialog.
            // For now, we'll do the work and close.
            final result = await recorderService.stopAndTranscribe();
            Navigator.of(dialogContext).pop(result);
          },
        ),
      );

      // 5. Create Note if processed content exists
      if (processed != null && mounted) {
        final l10n = AppLocalizations.of(context)!;
        final now = DateTime.now();
        final id = now.millisecondsSinceEpoch.toString();
        
        // Generate note content based on whether it's a checklist or regular text
        final noteContent = VoiceToChecklistProcessor.generateNoteContent(processed);
        
        // Create appropriate title based on content type
        final noteTitle = processed.isChecklist 
            ? '${l10n.checklist} ${DateFormat.Hm().format(now)}'
            : '${l10n.newNote} (Voice) ${DateFormat.Hm().format(now)}';

        final newNote = Note(
          id: id,
          title: noteTitle,
          content: noteContent,
          createdAt: now,
          updatedAt: now,
          color: 'FFFFFFFF',
          hasVoice: true, // Mark as voice note source
        );

        context.read<NotesProvider>().addNote(newNote);
        context.push('/note/$id');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      recorderService.dispose();
    }
  }

  Future<void> _onNewNote() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final dateStr = DateFormat.yMd().add_Hm().format(now);
    final id = now.millisecondsSinceEpoch.toString();

    final newNote = Note(
      id: id,
      title: '${l10n.newNote} $dateStr',
      content: '',
      createdAt: now,
      updatedAt: now,
      color: 'FFFFFFFF',
    );

    await context.read<NotesProvider>().addNote(newNote);
    _toggleFab();
    context.push('/note/$id');
  }

  @override
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notes = context.watch<NotesProvider>().notes;

    // Show loading until folders are loaded
    if (!_foldersLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: _isSelectionMode
                  ? Text(
                      '${_selectedNotes.length} ${l10n.deleteMultipleTitle}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : _isSearching
                      ? TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search notes...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : Text(
                          l10n.notesTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
              centerTitle: false,
              floating: true,
              snap: true,
              pinned: true,
              actions: [
                if (_isSelectionMode) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    tooltip: 'Move',
                    onPressed: _showMoveToFolderModal,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSelection,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _confirmDelete,
                  ),
                ] else ...[
                  if (!_isSearching)
                    IconButton(
                      icon: const Icon(Icons.create_new_folder_outlined),
                      onPressed: _showCreateFolderModal,
                    ),
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close : Icons.search),
                    onPressed: _toggleSearch,
                  ),
                  if (!_isSearching)
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                ],
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                indicatorSize: TabBarIndicatorSize.label,
                tabs: _buildTabs(l10n),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _buildTabViews(notes, context),
        ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Quick Voice Note button
          ScaleTransition(
            scale: _animation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 140),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      l10n.quickVoiceNote,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    heroTag: 'quickVoiceNote',
                    onPressed: _onQuickVoiceNote,
                    backgroundColor: const Color(0xFF2196F3),
                    child: const Icon(Icons.mic, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // New Note button
          ScaleTransition(
            scale: _animation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      l10n.newNote,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    heroTag: 'newNote',
                    onPressed: _onNewNote,
                    backgroundColor: const Color(0xFF2196F3),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Main FAB
          FloatingActionButton(
            heroTag: 'mainFab',
            onPressed: _toggleFab,
            child: AnimatedRotation(
              turns: _isFabExpanded ? 0.125 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: Icon(_isFabExpanded ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
