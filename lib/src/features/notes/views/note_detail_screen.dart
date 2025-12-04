import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notes_provider.dart';

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

  @override
  void initState() {
    super.initState();
    final note = context.read<NotesProvider>().getNoteById(widget.noteId);
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveTitle() {
    if (_titleController.text.isNotEmpty) {
      context.read<NotesProvider>().updateNote(
        widget.noteId,
        title: _titleController.text,
      );
    }
    setState(() => _isEditingTitle = false);
  }

  void _saveContent() {
    context.read<NotesProvider>().updateNote(
      widget.noteId,
      content: _contentController.text,
    );
    setState(() => _isEditingContent = false);
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
                      Icons.star_border,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.palette_outlined),
                    onPressed: () {},
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Date and character count
            Padding(
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
                    '${note.content.length} chars',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    'Toca para editar',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
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

                    // Content
                    GestureDetector(
                      onTap: () => setState(() => _isEditingContent = true),
                      child: _isEditingContent
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
                            )
                          : Text(
                              note.content.isEmpty
                                  ? 'Toca para agregar contenido'
                                  : note.content,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: note.content.isEmpty
                                        ? Colors.grey
                                        : null,
                                  ),
                            ),
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
