import 'package:flutter/material.dart';
import '../models/note.dart';

class NotesProvider extends ChangeNotifier {
  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Grocery 3/10/25 12:...',
      content: '• chocolate\n• milk\n• eggs',
      createdAt: DateTime(2025, 10, 3),
      updatedAt: DateTime(2025, 10, 3),
      color: 'FFFFFFFF',
    ),
    Note(
      id: '2',
      title: 'Goals',
      content: 'Football Is A Game Played On A Rectangular Field, B...',
      createdAt: DateTime(2022, 7, 27),
      updatedAt: DateTime(2022, 7, 27),
      color: 'FFF3E5F5',
    ),
    Note(
      id: '3',
      title: 'Projects',
      content:
          'Finish 3 new projects by the end of the...\nThank you all for wa...',
      createdAt: DateTime(2022, 7, 27),
      updatedAt: DateTime(2022, 7, 27),
      color: 'FFFFFFFF',
      hasImage: true,
      hasVoice: true,
    ),
    Note(
      id: '4',
      title: 'Shopping',
      content: '• Mango\n• Apples\n• Oranges',
      createdAt: DateTime(2022, 7, 27),
      updatedAt: DateTime(2022, 7, 27),
      color: 'FFFFFFFF',
    ),
    Note(
      id: '5',
      title: 'To do list',
      content: '• Go to the gym\n• Work\n• Walking.',
      createdAt: DateTime(2022, 7, 27),
      updatedAt: DateTime(2022, 7, 27),
      color: 'FFFFFFFF',
    ),
    Note(
      id: '6',
      title: 'Tennis',
      content: 'Tennis Is Also One Of The Most Popular Indoor Sports In Ma...',
      createdAt: DateTime(2022, 7, 27),
      updatedAt: DateTime(2022, 7, 27),
      color: 'FFFFFFFF',
    ),
  ];

  List<Note> get notes => List.unmodifiable(_notes);

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateNote(String id, {String? title, String? content}) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void addNote(Note note) {
    _notes.insert(0, note);
    notifyListeners();
  }
}
