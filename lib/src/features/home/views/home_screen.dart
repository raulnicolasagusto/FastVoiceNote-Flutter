import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../widgets/note_card.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../notes/providers/notes_provider.dart';
import 'package:intl/intl.dart';
import '../../notes/models/note.dart';
import '../../transcription/services/audio_recorder_service.dart';
import '../../transcription/widgets/recording_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFabExpanded = false;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  Future<void> _onQuickVoiceNote() async {
    // 1. Close FAB first
    _toggleFab();

    // 2. Initialize service (loads native lib & model if first time)
    final recorderService = AudioRecorderService();
    try {
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
      final resultText = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => RecordingDialog(
          onCancel: () async {
            await recorderService.cancel();
            Navigator.of(dialogContext).pop(); // Return null
          },
          onStop: () async {
            // Show processing state?
            // For now, blocking wait in dialog action or here
            // Let's assume dialog closes then we process or we wait here.

            // BETTER UX: Keep dialog, show "Processing..." spinner inside dialog?
            // To keep it simple as per plan: Stop -> Process -> Close -> Navigate.
            // We can implement a loading state in the dialog if needed,
            // but for now let's just do the logic.

            // To update dialog UI, we need state there.
            // Let's close dialog with a specific flag or handle logic inside?
            // The simplest way to pass data back is Navigator.pop(result)

            // We'll signal the dialog to show processing if we modify it,
            // or just show a global loader.

            // Implementation:
            // 1. User clicks stop.
            // 2. We trigger service.stopAndTranscribe().
            // 3. Then pop with text.

            // TODO: Add loading feedback in RecordingDialog.
            // For now, we'll do the work and close.
            final text = await recorderService.stopAndTranscribe();
            Navigator.of(dialogContext).pop(text);
          },
        ),
      );

      // 5. Create Note if text exists
      if (resultText != null && resultText.isNotEmpty && mounted) {
        final l10n = AppLocalizations.of(context)!;
        final now = DateTime.now();
        final id = now.millisecondsSinceEpoch.toString();

        final newNote = Note(
          id: id,
          title: '${l10n.newNote} (Voice) ${DateFormat.Hm().format(now)}',
          content: resultText,
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

  void _onNewNote() {
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

    context.read<NotesProvider>().addNote(newNote);
    _toggleFab();
    context.push('/note/$id');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notes = context.watch<NotesProvider>().notes;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                title: Text(
                  l10n.notesTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: false,
                floating: true,
                snap: true,
                pinned: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.create_new_folder_outlined),
                    onPressed: () {},
                  ),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ],
                bottom: TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: l10n.allTab),
                    Tab(text: '${l10n.folderTab} 1'),
                    Tab(text: '${l10n.folderTab} 2'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 0.1,
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return GestureDetector(
                      onTap: () => context.push('/note/${note.id}'),
                      child: NoteCard(
                        title: note.title,
                        date: note.updatedAt,
                        content: note.content,
                        color: Color(int.parse('0x${note.color}')),
                        hasImage: note.hasImage,
                        hasVoice: note.hasVoice,
                      ),
                    );
                  },
                ),
              ),
              const Center(child: Text('Folder 1 Content')),
              const Center(child: Text('Folder 2 Content')),
            ],
          ),
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
