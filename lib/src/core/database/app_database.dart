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
  TextColumn get folderId => text().nullable().withDefault(const Constant(null))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(notes, notes.folderId);
      }
      if (from <= 3) {
        // Add isPinned column for versions 3 and below
        try {
          await m.addColumn(notes, notes.isPinned as GeneratedColumn);
        } catch (e) {
          // Column might already exist, ignore
        }
      }
    },
  );

  Future<void> insertNote(NoteEntity note) => into(notes).insert(note);
  Future<void> updateNoteData(NoteEntity note) => update(notes).replace(note);
  Future<void> updateNoteFolderId(String id, String? folderId) =>
      (update(notes)..where((t) => t.id.equals(id))).write(NotesCompanion(folderId: Value(folderId)));
  Future<void> deleteNote(String id) =>
      (delete(notes)..where((t) => t.id.equals(id))).go();
  Stream<List<NoteEntity>> watchAllNotes() => select(notes).watch();
  Future<NoteEntity?> getNoteById(String id) =>
      (select(notes)..where((t) => t.id.equals(id))).getSingleOrNull();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'notes_v4.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
