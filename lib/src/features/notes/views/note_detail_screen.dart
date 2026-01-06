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
import '../models/checklist_item.dart';
import '../models/checklist_utils.dart';
import '../models/note.dart';

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveTitle() async {
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
        onLock: () {
          // TODO: Implement lock/unlock functionality
        },
        onShare: () {
          // TODO: Implement share functionality
        },
        onAddToHomeScreen: () {
          // TODO: Implement add to home screen functionality
        },
        isLocked: false, // TODO: Get from note state
      ),
    );
  }

  Future<void> _convertToChecklist(Note note) async {
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

  Future<void> _onVoiceRecording() async {
    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    if (note == null) return;

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      color: note.isPinned ? Colors.amber : Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {
                      context.read<NotesProvider>().togglePin(widget.noteId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none),
                    onPressed: _onVoiceRecording,
                  ),
                  IconButton(
                    icon: const Icon(Icons.palette_outlined),
                    onPressed: () {},
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
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: _showOptionsDialog,
                  ),
                ],
              ),
            ),

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
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$charCount chars',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      if (!hasChecklist) ...[
                        const Spacer(),
                        Text(
                          'Toca para editar',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
                      onTap: () => setState(() => _isEditingTitle = true),
                      child: _isEditingTitle
                          ? TextField(
                              controller: _titleController,
                              autofocus: true,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Title',
                              ),
                              onSubmitted: (_) => _saveTitle(),
                              onTapOutside: (_) => _saveTitle(),
                            )
                          : Text(
                              note.title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
                                setState(() => _isEditingContent = true);
                              },
                              child: isEditingContent
                                  ? TextField(
                                      controller: _contentController,
                                      autofocus: true,
                                      maxLines: null,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Note',
                                      ),
                                      onTapOutside: (_) => _saveContent(),
                                      onSubmitted: (_) => _saveContent(),
                                    )
                                  : textContent.isNotEmpty || !hasChecklist
                                      ? Text(
                                          textContent.isEmpty
                                              ? 'Toca para agregar contenido'
                                              : textContent,
                                          style: Theme.of(context).textTheme.bodyLarge
                                              ?.copyWith(
                                                color: textContent.isEmpty
                                                    ? Colors.grey
                                                    : null,
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
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
