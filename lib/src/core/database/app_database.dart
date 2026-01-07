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

@DataClassName('AttachmentEntity')
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text()();
  TextColumn get filePath => text()();
  TextColumn get type => text()(); // 'image', 'file'
  TextColumn get fileName => text().nullable()(); // Original filename for files
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Notes, Attachments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

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
      if (from < 5) {
        // Create attachments table in version 5
        await m.createTable(attachments);
      }
      if (from < 6) {
        // Add fileName column to attachments in version 6
        try {
          await m.addColumn(attachments, attachments.fileName);
        } catch (e) {
          // Column might already exist, ignore
        }
      }
    },
  );

  // Notes operations
  Future<void> insertNote(NoteEntity note) => into(notes).insert(note);
  Future<void> updateNoteData(NoteEntity note) => update(notes).replace(note);
  Future<void> updateNoteFolderId(String id, String? folderId) =>
      (update(notes)..where((t) => t.id.equals(id))).write(NotesCompanion(folderId: Value(folderId)));
  Future<void> deleteNote(String id) =>
      (delete(notes)..where((t) => t.id.equals(id))).go();
  Stream<List<NoteEntity>> watchAllNotes() => select(notes).watch();
  Future<NoteEntity?> getNoteById(String id) =>
      (select(notes)..where((t) => t.id.equals(id))).getSingleOrNull();

  // Attachments operations
  Future<void> insertAttachment(AttachmentEntity attachment) => 
      into(attachments).insert(attachment);
  Future<List<AttachmentEntity>> getAttachmentsForNote(String noteId) =>
      (select(attachments)..where((t) => t.noteId.equals(noteId))).get();
  Future<void> deleteAttachment(String id) =>
      (delete(attachments)..where((t) => t.id.equals(id))).go();
  Future<void> deleteAttachmentsForNote(String noteId) =>
      (delete(attachments)..where((t) => t.noteId.equals(noteId))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'notes_v6.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
