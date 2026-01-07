import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../transcription/services/audio_recorder_service.dart';
import '../../transcription/widgets/recording_dialog.dart';
import '../../transcription/utils/voice_add_to_note_processor.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_options_dialog.dart';
import '../widgets/checklist_widget.dart';
import '../widgets/color_picker_modal.dart';
import '../widgets/photo_options_dialog.dart';
import '../services/image_service.dart';
import '../models/checklist_item.dart';
import '../models/checklist_utils.dart';
import '../models/note.dart';
import '../../../core/database/app_database.dart';

class NoteDetailScreen extends StatefulWidget {
  final String noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditingTitle = false;
  bool _isEditingContent = false;
  bool _isChecklistEditing = false;
  
  // Search state
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  int _currentMatchIndex = 0;
  int _totalMatches = 0;

  // Image service
  final ImageService _imageService = ImageService();
  List<AttachmentEntity> _attachments = [];

  @override
  void initState() {
    super.initState();
    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    _titleController = TextEditingController(text: note?.title ?? '');
    // Si hay checklist, obtener solo el texto original
    final content = note?.content ?? '';
    final textContent = ChecklistUtils.hasChecklist(content) 
        ? ChecklistUtils.getText(content) 
        : content;
    _contentController = TextEditingController(text: textContent);
    
    _searchController.addListener(_onSearchChanged);
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    final attachments = await context.read<NotesProvider>().getAttachments(widget.noteId);
    setState(() {
      _attachments = attachments;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveTitle() async {
    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    if (note?.isLocked == true) {
      _showLockedAlert();
      setState(() => _isEditingTitle = false);
      return;
    }
    
    if (_titleController.text.isNotEmpty) {
      await context.read<NotesProvider>().updateNote(
        widget.noteId,
        title: _titleController.text,
      );
    }
    setState(() => _isEditingTitle = false);
  }

  Future<void> _saveContent() async {
    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    if (note == null) return;

    if (note.isLocked) {
      _showLockedAlert();
      setState(() => _isEditingContent = false);
      return;
    }

    final hasChecklist = ChecklistUtils.hasChecklist(note.content);
    
    if (hasChecklist) {
      // Si hay checklist, actualizar solo el texto manteniendo el checklist
      final items = ChecklistUtils.jsonToItems(note.content);
      final newContent = ChecklistUtils.itemsToJson(items, _contentController.text);
      await context.read<NotesProvider>().updateNote(
        widget.noteId,
        content: newContent,
      );
    } else {
      // Si no hay checklist, actualizar el contenido normalmente
      await context.read<NotesProvider>().updateNote(
        widget.noteId,
        content: _contentController.text,
      );
    }
    
    setState(() => _isEditingContent = false);
  }

  void _onDoneEditing() {
    FocusScope.of(context).unfocus();
    if (_isEditingTitle) _saveTitle();
    if (_isEditingContent) _saveContent();
  }

  void _showOptionsDialog() {
    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    
    showDialog(
      context: context,
      builder: (context) => NoteOptionsDialog(
        onChecklist: () {
          if (note != null) {
            _convertToChecklist(note);
          }
        },
        onLock: _toggleLock,
        onShare: () {
          // TODO: Implement share functionality
        },
        onAddToHomeScreen: () {
          // TODO: Implement add to home screen functionality
        },
        isLocked: note?.isLocked ?? false,
      ),
    );
  }

  void _toggleLock() async {
    final l10n = AppLocalizations.of(context)!;
    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    final willBeLocked = !(note?.isLocked ?? false);
    
    await context.read<NotesProvider>().toggleLock(widget.noteId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(willBeLocked ? l10n.noteLocked : l10n.noteUnlocked),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showLockedAlert() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.noteLockedTitle),
        content: Text(l10n.noteLockedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions() {
    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    if (note?.isLocked == true) {
      _showLockedAlert();
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => PhotoOptionsDialog(
        onTakePhoto: _takePicture,
        onUploadFile: _uploadFile,
      ),
    );
  }

  Future<void> _takePicture() async {
    final imagePath = await _imageService.takePicture();
    
    if (imagePath != null) {
      // Save attachment to database
      await context.read<NotesProvider>().addAttachment(
        widget.noteId,
        imagePath,
        'image',
      );
      
      // Reload attachments
      await _loadAttachments();
      
      // Show success feedback
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.photoAddedSuccess),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _uploadFile() async {
    // Show options to pick image or file
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('File'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    if (result == 'image') {
      final imagePath = await _imageService.pickImage();
      if (imagePath != null) {
        await context.read<NotesProvider>().addAttachment(
          widget.noteId,
          imagePath,
          'image',
        );
        await _loadAttachments();
        
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.photoAddedSuccess),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      final fileData = await _imageService.pickFile();
      if (fileData != null) {
        await context.read<NotesProvider>().addAttachment(
          widget.noteId,
          fileData['path']!,
          'file',
          fileName: fileData['name'],
        );
        await _loadAttachments();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File added successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _convertToChecklist(Note note) async {
    if (note.isLocked) {
      _showLockedAlert();
      return;
    }
    
    // Si ya hay checklist, solo activar modo edición y agregar un item nuevo
    if (ChecklistUtils.hasChecklist(note.content)) {
      setState(() {
        _isChecklistEditing = true;
      });
      
      // Agregar un nuevo item vacío al final
      final currentItems = ChecklistUtils.jsonToItems(note.content);
      final newItem = ChecklistItem(
        id: ChecklistUtils.generateItemId(),
        text: '',
      );
      currentItems.add(newItem);
      
      // Actualizar con el nuevo item
      final originalText = ChecklistUtils.getText(note.content);
      final checklistContent = ChecklistUtils.itemsToJson(currentItems, originalText);
      await context.read<NotesProvider>().updateNote(
        widget.noteId,
        content: checklistContent,
      );
      return;
    }
    
    // Si NO hay checklist, crear uno nuevo con el contenido actual como texto
    final baseText = note.content;
    final checklistContent = ChecklistUtils.addChecklistToContent(baseText);
    await context.read<NotesProvider>().updateNote(
      widget.noteId,
      content: checklistContent,
    );
    setState(() {
      _isChecklistEditing = true;
      _contentController.text = ChecklistUtils.getText(checklistContent);
    });
  }

  Future<void> _onChecklistItemsChanged(List<ChecklistItem> items) async {
    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    if (note == null) return;

    if (note.isLocked) {
      _showLockedAlert();
      return;
    }

    // Si no hay items, remover el checklist y volver a texto normal
    if (items.isEmpty) {
      final textContent = ChecklistUtils.getText(note.content);
      await context.read<NotesProvider>().updateNote(
        widget.noteId,
        content: textContent,
      );
      setState(() {
        _contentController.text = textContent;
        _isChecklistEditing = false;
      });
      return;
    }

    // Mantener el texto original y actualizar el checklist
    final originalText = ChecklistUtils.getText(note.content);
    final checklistContent = ChecklistUtils.itemsToJson(items, originalText);
    await context.read<NotesProvider>().updateNote(
      widget.noteId,
      content: checklistContent,
    );
    setState(() {
      _contentController.text = originalText;
    });
  }

  void _toggleChecklistEdit() {
    setState(() {
      _isChecklistEditing = !_isChecklistEditing;
    });
  }

  // Search methods
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _updateMatchCount();
    });
  }

  void _updateMatchCount() {
    if (_searchQuery.isEmpty) {
      _totalMatches = 0;
      _currentMatchIndex = 0;
      return;
    }

    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    if (note == null) return;

    int count = 0;
    
    // Count in title
    count += _countMatches(note.title.toLowerCase(), _searchQuery);
    
    // Count in text content
    final textContent = ChecklistUtils.getText(note.content).toLowerCase();
    count += _countMatches(textContent, _searchQuery);
    
    // Count in checklist items
    if (ChecklistUtils.hasChecklist(note.content)) {
      final items = ChecklistUtils.jsonToItems(note.content);
      for (var item in items) {
        count += _countMatches(item.text.toLowerCase(), _searchQuery);
      }
    }

    _totalMatches = count;
    if (_currentMatchIndex > _totalMatches) {
      _currentMatchIndex = _totalMatches > 0 ? 1 : 0;
    } else if (_currentMatchIndex == 0 && _totalMatches > 0) {
      _currentMatchIndex = 1;
    }
  }

  int _countMatches(String text, String query) {
    if (query.isEmpty || text.isEmpty) return 0;
    int count = 0;
    int index = 0;
    while ((index = text.indexOf(query, index)) != -1) {
      count++;
      index += query.length;
    }
    return count;
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchQuery = '';
        _currentMatchIndex = 0;
        _totalMatches = 0;
      }
    });
  }

  void _nextMatch() {
    if (_totalMatches > 0) {
      setState(() {
        _currentMatchIndex = (_currentMatchIndex % _totalMatches) + 1;
      });
    }
  }

  void _previousMatch() {
    if (_totalMatches > 0) {
      setState(() {
        _currentMatchIndex = _currentMatchIndex > 1 ? _currentMatchIndex - 1 : _totalMatches;
      });
    }
  }

  TextSpan _buildHighlightedText(String text, TextStyle? style, Color highlightColor) {
    if (_searchQuery.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    int currentIndex = 0;
    int matchIndex = 0;

    while (currentIndex < text.length) {
      final index = lowerText.indexOf(_searchQuery, currentIndex);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(currentIndex), style: style));
        break;
      }

      // Add text before match
      if (index > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, index), style: style));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + _searchQuery.length),
        style: style?.copyWith(
          backgroundColor: highlightColor,
          color: Colors.black87,
        ),
      ));

      currentIndex = index + _searchQuery.length;
      matchIndex++;
    }

    return TextSpan(children: spans);
  }

  Future<void> _onVoiceRecording() async {
    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    if (note == null) return;

    // Check if note is locked
    if (note.isLocked) {
      _showLockedAlert();
      return;
    }

    // Initialize recorder service
    final recorderService = AudioRecorderService();
    try {
      // Set language based on app's current locale
      final locale = Localizations.localeOf(context);
      final languageCode = locale.languageCode;
      recorderService.setLanguage(languageCode);
      
      await recorderService.init();

      // Start recording
      final started = await recorderService.startRecording();
      if (!started && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
        return;
      }

      if (!mounted) return;

      // Show recording dialog (reusing the same dialog as Quick Voice Note)
      final transcriptionResult = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => RecordingDialog(
          onCancel: () async {
            await recorderService.cancel();
            Navigator.of(dialogContext).pop();
          },
          onStop: () async {
            final processed = await recorderService.stopAndTranscribe();
            Navigator.of(dialogContext).pop(processed?.originalText ?? '');
          },
        ),
      );

      if (transcriptionResult == null || transcriptionResult.isEmpty || !mounted) {
        return;
      }

      // Process the transcription to determine what to do
      final hasChecklist = ChecklistUtils.hasChecklist(note.content);
      final result = VoiceAddToNoteProcessor.processAddToNote(
        transcribedText: transcriptionResult,
        language: languageCode,
        isChecklist: hasChecklist,
      );

      if (result.shouldAddItems && result.itemsToAdd.isNotEmpty) {
        // User wants to add items to checklist
        final currentItems = ChecklistUtils.jsonToItems(note.content);
        final updatedItems = [...currentItems, ...result.itemsToAdd];
        
        final originalText = ChecklistUtils.getText(note.content);
        final newContent = ChecklistUtils.itemsToJson(updatedItems, originalText);
        
        await context.read<NotesProvider>().updateNote(
          widget.noteId,
          content: newContent,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${result.itemsToAdd.length} item(s) to checklist'),
            ),
          );
        }
      } else if (result.textToAdd.isNotEmpty) {
        // User wants to add text to note
        final currentText = hasChecklist 
            ? ChecklistUtils.getText(note.content)
            : note.content;
        
        // Append the new text with proper spacing
        final newText = currentText.isEmpty 
            ? result.textToAdd
            : '$currentText\n\n${result.textToAdd}';
        
        if (hasChecklist) {
          // Maintain checklist and update text part
          final items = ChecklistUtils.jsonToItems(note.content);
          final newContent = ChecklistUtils.itemsToJson(items, newText);
          
          await context.read<NotesProvider>().updateNote(
            widget.noteId,
            content: newContent,
          );
          
          setState(() {
            _contentController.text = newText;
          });
        } else {
          // Regular note, just update content
          await context.read<NotesProvider>().updateNote(
            widget.noteId,
            content: newText,
          );
          
          setState(() {
            _contentController.text = newText;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Text added to note')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      recorderService.dispose();
    }
  }

  void _showColorPicker() {
    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    if (note == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => ColorPickerModal(
        currentColor: note.color,
        onColorSelected: (color) async {
          await context.read<NotesProvider>().updateNote(
            widget.noteId,
            color: color,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final note = context.watch<NotesProvider>().getNoteById(widget.noteId);

    if (note == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Note not found')),
      );
    }

    // Actualizar controladores si el contenido cambió externamente
    final currentText = ChecklistUtils.hasChecklist(note.content)
        ? ChecklistUtils.getText(note.content)
        : note.content;
    if (_contentController.text != currentText && !_isEditingContent) {
      _contentController.text = currentText;
    }

    // Get note color
    final noteColor = Color(int.parse('0x${note.color}'));
    // Determine text color based on background luminance (NOT theme mode)
    final textColor = noteColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    // Determine icon color
    final iconColor = noteColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    // Determine hint/secondary color
    final hintColor = noteColor.computeLuminance() > 0.5 
        ? Colors.black54 
        : Colors.white.withValues(alpha: 0.6);

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(color: iconColor),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: textColor,
          displayColor: textColor,
          decorationColor: textColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: hintColor),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: textColor,
          selectionColor: textColor.withValues(alpha: 0.3),
          selectionHandleColor: textColor,
        ),
      ),
      child: Scaffold(
        backgroundColor: noteColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top Action Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: Icon(
                      note.isPinned ? Icons.star : Icons.star_border,
                      color: note.isPinned ? Colors.amber : iconColor,
                    ),
                    onPressed: () {
                      context.read<NotesProvider>().togglePin(widget.noteId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    onPressed: _showPhotoOptions,
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none),
                    onPressed: _onVoiceRecording,
                  ),
                  IconButton(
                    icon: const Icon(Icons.palette_outlined),
                    onPressed: _showColorPicker,
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) {
                      final note = context.watch<NotesProvider>().getNoteById(widget.noteId);
                      final hasChecklist = note != null && ChecklistUtils.hasChecklist(note.content);
                      
                      return IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: (_isEditingTitle || _isEditingContent || (hasChecklist && _isChecklistEditing))
                            ? () {
                                if (hasChecklist) {
                                  _toggleChecklistEdit();
                                } else {
                                  _onDoneEditing();
                                }
                              }
                            : hasChecklist
                                ? _toggleChecklistEdit
                                : null,
                      );
                    },
                  ),
                  if (!_isSearching) ...[
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _toggleSearch,
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: _showOptionsDialog,
                    ),
                  ] else ...[
                    // Search navigation buttons
                    if (_totalMatches > 0) ...[
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up),
                        onPressed: _previousMatch,
                        iconSize: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        onPressed: _nextMatch,
                        iconSize: 20,
                      ),
                    ],
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _toggleSearch,
                    ),
                  ],
                ],
              ),
            ),

            // Search bar or Date and character count
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        autofocus: true,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Search in note...',
                          hintStyle: TextStyle(color: hintColor),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: iconColor),
                        ),
                      ),
                    ),
                    if (_totalMatches > 0)
                      Text(
                        '$_currentMatchIndex/$_totalMatches',
                        style: TextStyle(color: hintColor, fontSize: 14),
                      ),
                  ],
                ),
              )
            else
              // Date and character count
              Builder(
              builder: (context) {
                final hasChecklist = ChecklistUtils.hasChecklist(note.content);
                final textContent = ChecklistUtils.getText(note.content);
                int charCount = textContent.length;
                if (hasChecklist) {
                  final items = ChecklistUtils.jsonToItems(note.content);
                  charCount += items.fold(0, (sum, item) => sum + item.text.length);
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(note.updatedAt),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: hintColor),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$charCount chars',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: hintColor),
                      ),
                      if (!hasChecklist) ...[
                        const Spacer(),
                        Text(
                          'Toca para editar',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: hintColor),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    GestureDetector(
                      onTap: () {
                        if (note.isLocked) {
                          _showLockedAlert();
                        } else {
                          setState(() => _isEditingTitle = true);
                        }
                      },
                      child: _isEditingTitle
                          ? TextField(
                              controller: _titleController,
                              autofocus: true,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Title',
                                hintStyle: TextStyle(color: hintColor),
                              ),
                              onSubmitted: (_) => _saveTitle(),
                              onTapOutside: (_) => _saveTitle(),
                            )
                          : RichText(
                              text: _buildHighlightedText(
                                note.title,
                                Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                Colors.yellow.shade300,
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Content and/or Checklist
                    Builder(
                      builder: (context) {
                        final hasChecklist = ChecklistUtils.hasChecklist(note.content);
                        final textContent = ChecklistUtils.getText(note.content);
                        final isEditingContent = _isEditingContent;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text content (siempre visible, puede estar vacío)
                            GestureDetector(
                              onTap: () {
                                if (note.isLocked) {
                                  _showLockedAlert();
                                } else {
                                  setState(() => _isEditingContent = true);
                                }
                              },
                              child: isEditingContent
                                  ? TextField(
                                      controller: _contentController,
                                      autofocus: true,
                                      maxLines: null,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: textColor,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Note',
                                        hintStyle: TextStyle(color: hintColor),
                                      ),
                                      onTapOutside: (_) => _saveContent(),
                                      onSubmitted: (_) => _saveContent(),
                                    )
                                  : textContent.isNotEmpty || !hasChecklist
                                      ? RichText(
                                          text: _buildHighlightedText(
                                            textContent.isEmpty ? 'Toca para agregar contenido' : textContent,
                                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              color: textContent.isEmpty ? hintColor : textColor,
                                            ),
                                            Colors.yellow.shade300,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                            ),
                            
                            // Checklist (si existe)
                            if (hasChecklist) ...[
                              if (textContent.isNotEmpty) const SizedBox(height: 24),
                              ChecklistWidget(
                                items: ChecklistUtils.jsonToItems(note.content),
                                isEditing: _isChecklistEditing,
                                onItemsChanged: _onChecklistItemsChanged,
                                onEditModeRequested: _toggleChecklistEdit,
                                searchQuery: _searchQuery,
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    // Attachments Gallery
                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _attachments.map((attachment) {
                          if (attachment.type == 'image') {
                            return _ImageThumbnail(
                              imagePath: attachment.filePath,
                              textColor: textColor,
                              onDelete: () async {
                                await context.read<NotesProvider>().deleteAttachment(attachment.id);
                                await _imageService.deleteImage(attachment.filePath);
                                await _loadAttachments();
                              },
                            );
                          } else {
                            return _FileThumbnail(
                              filePath: attachment.filePath,
                              fileName: attachment.fileName ?? 'Unknown',
                              textColor: textColor,
                              onDelete: () async {
                                await context.read<NotesProvider>().deleteAttachment(attachment.id);
                                await _imageService.deleteImage(attachment.filePath);
                                await _loadAttachments();
                              },
                            );
                          }
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final String imagePath;
  final Color textColor;
  final VoidCallback onDelete;

  const _ImageThumbnail({
    required this.imagePath,
    required this.textColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(imagePath),
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FileThumbnail extends StatelessWidget {
  final String filePath;
  final String fileName;
  final Color textColor;
  final VoidCallback onDelete;

  const _FileThumbnail({
    required this.filePath,
    required this.fileName,
    required this.textColor,
    required this.onDelete,
  });

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red.shade600;
      case 'doc':
      case 'docx':
        return Colors.blue.shade700;
      case 'xls':
      case 'xlsx':
        return Colors.green.shade700;
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFileIcon(fileName),
                size: 48,
                color: _getFileColor(fileName),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
