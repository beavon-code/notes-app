import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  static final _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

  List<DatabaseNotes> _notes = [];

  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;

  late final _notesStreamController;

  Future<DatabaseUser> getOrCreateUser({required email}) async {
    await _ensureDbIsOpen();
    try {
      final user = await getUser(email: email);
      return user;
    } on UserDoesNotExistException {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    await _ensureDbIsOpen();
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNotes> updateNote({
    required DatabaseNotes note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updateCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      final updateNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updateNote.id);
      _notes.add(updateNote);
      _notesStreamController.add(_notes);
      return updateNote;
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((notesRow) => DatabaseNotes.fromRow(notesRow));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNotes();
    } else {
      final note = DatabaseNotes.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletion = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletion;
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = getUser(email: owner.email);
    // ignore: unrelated_type_equality_checks
    if (dbUser != owner) {
      throw UserDoesNotExistException();
    }

    const text = '';

    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNotes(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.delete(
      noteTable,
      where: 'id=?',
      whereArgs: [id],
    );
    if (result == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseUser> getUser({required email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: email,
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw UserDoesNotExistException();
    }
    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final create = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (create.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(
      userTable,
      {
        emailColumn: [email.toLowerCase()],
      },
    );
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> deleteUser({required email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);

      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }
}

class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final id;
  final userId;
  final text;
  final isSyncedWithCloud;

  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedWithCloudColumn]) == 1 ? true : false;

  @override
  String toString() {
    return 'Note ID=$id, userId=$userId, isSyncedWithCloud=$isSyncedWithCloud';
  }

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const userTable = 'user';
const noteTable = 'notes';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL UNIQUE,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL UNIQUE,
	"text"	TEXT,
	"user_id"	INTEGER NOT NULL,
	"is_synced_with_cloud"	INTEGER DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);''';
