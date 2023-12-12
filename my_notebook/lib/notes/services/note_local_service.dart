import 'package:my_notebook/common/encryption_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/note.dart';

class NoteLocalService {
  static EncryptionHelper encryptionHelper = EncryptionHelper();
  static Database? _database;
  static String tableName = 'Notes';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    final docDirectory = await getDatabasesPath();
    final path = join(docDirectory, 'notes.db');
    return await openDatabase(path,
        version: 1, onCreate: _createDB, singleInstance: true);
  }

  _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        title TEXT,
        note TEXT,
        createdAt TEXT
      )
    ''');
  }

  deleteDB() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  Future<List<Note>> readNotes() async {
    final db = await database;
    var res = await db.query(tableName);
    List<Note> list = [];

    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        Note note = Note.fromMap(map);
        note.title = await encryptionHelper.decryptText(note.title);
        note.note = await encryptionHelper.decryptText(note.note);
        list.add(note);
      }
    }

    return list;
  }

  Future<Note?> readNoteById(String id) async {
    final db = await database;
    var res = await db.query('Notes', where: 'id = ?', whereArgs: [id]);

    if (res.isNotEmpty) {
      Note note = Note.fromMap(res.first);
      note.title = await encryptionHelper.decryptText(note.title);
      note.note = await encryptionHelper.decryptText(note.note);
      return note;
    }

    return null;
  }

  Future<void> createNote({required String uuid, required String title}) async {
    final db = await database;
    Note note = Note(
      id: uuid,
      title: await encryptionHelper.encryptText(title),
      note: '',
      createdAt: DateTime.now(),
    );
    await db.insert(tableName, note.toMap());
  }

  Future<void> createFromNote({required Note note}) async {
    final db = await database;
    Map<String, dynamic> map = note.toMap();
    map['title'] = await encryptionHelper.encryptText(note.title);
    map['note'] = await encryptionHelper.encryptText(note.note);
    await db.insert(tableName, map);
  }

  Future<void> updateTitle({required String id, required String title}) async {
    final db = await database;
    await db.update(
        tableName, {'title': await encryptionHelper.encryptText(title)},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateNote({required String id, required String note}) async {
    final db = await database;
    await db.update(
        tableName, {'note': await encryptionHelper.encryptText(note)},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteNote({required String id}) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
