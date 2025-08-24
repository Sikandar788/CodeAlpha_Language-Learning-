import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lingua_spark.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE vocabs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT,
            translation TEXT,
            example TEXT,
            category TEXT,
            language TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertVocab(Vocab v) async {
    final db = await _database;
    return await db.insert('vocabs', v.toMap());
  }

  static Future<List<Vocab>> fetchVocabs({String? language, String? category}) async {
    final db = await _database;
    String where = '';
    List<dynamic> args = [];
    if (language != null) {
      where += 'language = ?';
      args.add(language);
    }
    if (category != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'category = ?';
      args.add(category);
    }
    final res = await db.query('vocabs', where: where.isEmpty ? null : where, whereArgs: args.isEmpty ? null : args);
    return res.map((e) => Vocab.fromMap(e)).toList();
  }

  static Future<int> deleteAll() async {
    final db = await _database;
    return await db.delete('vocabs');
  }
}
