import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DataClassName('NoteEntity')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get color => text()();
  BoolColumn get hasImage => boolean().withDefault(const Constant(false))();
  BoolColumn get hasVoice => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> insertNote(NoteEntity note) => into(notes).insert(note);
  Future<void> updateNoteData(NoteEntity note) => update(notes).replace(note);
  Future<void> deleteNote(String id) =>
      (delete(notes)..where((t) => t.id.equals(id))).go();
  Stream<List<NoteEntity>> watchAllNotes() => select(notes).watch();
  Future<NoteEntity?> getNoteById(String id) =>
      (select(notes)..where((t) => t.id.equals(id))).getSingleOrNull();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
