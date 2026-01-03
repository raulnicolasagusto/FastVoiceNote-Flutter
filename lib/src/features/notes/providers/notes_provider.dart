import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/database/app_database.dart';
import '../models/note.dart';

class NotesProvider extends ChangeNotifier {
  final AppDatabase _database;
  StreamSubscription<List<NoteEntity>>? _notesSubscription;
  List<Note> _notes = [];

  NotesProvider(this._database) {
    _init();
  }

  void _init() {
    _notesSubscription = _database.watchAllNotes().listen((entities) {
      _notes = entities.map((e) => Note.fromEntity(e)).toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }

  List<Note> get notes => List.unmodifiable(_notes);

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> togglePin(String id) async {
    final note = getNoteById(id);
    if (note != null) {
      await updateNote(id, isPinned: !note.isPinned);
    }
  }

  Future<void> updateNote(String id, {String? title, String? content, String? folderId, bool replaceFolderId = false, bool? isPinned}) async {
    final note = getNoteById(id);
    if (note != null) {
      // Si replaceFolderId es true, cambiar folderId aunque sea null
      final newFolderId = replaceFolderId ? folderId : (folderId ?? note.folderId);
      
      final updatedNote = note.copyWith(
        title: title,
        content: content,
        folderId: newFolderId,
        isPinned: isPinned,
        updatedAt: DateTime.now(),
      );

      await _database.updateNoteData(
        NoteEntity(
          id: updatedNote.id,
          title: updatedNote.title,
          content: updatedNote.content,
          createdAt: updatedNote.createdAt,
          updatedAt: updatedNote.updatedAt,
          color: updatedNote.color,
          hasImage: updatedNote.hasImage,
          hasVoice: updatedNote.hasVoice,
          folderId: updatedNote.folderId,
          isPinned: updatedNote.isPinned,
        ),
      );
    }
  }

  void addNote(Note note) {
    _database.insertNote(
      NoteEntity(
        id: note.id,
        title: note.title,
        content: note.content,
        createdAt: note.createdAt,
        updatedAt: note.updatedAt,
        color: note.color,
        hasImage: note.hasImage,
        hasVoice: note.hasVoice,
        folderId: note.folderId,
        isPinned: note.isPinned,
      ),
    );
  }

  Future<void> deleteNote(String id) async {
    await _database.deleteNote(id);
  }

  Future<void> deleteNotes(List<String> ids) async {
    for (final id in ids) {
      await _database.deleteNote(id);
    }
  }

  Future<void> moveNotes(List<String> noteIds, String? folderId) async {
    for (final noteId in noteIds) {
      await _database.updateNoteFolderId(noteId, folderId);
    }
  }
}
