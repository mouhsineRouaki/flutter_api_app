import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseFavorite {
  static final DatabaseFavorite _instance = DatabaseFavorite._internal();
  factory DatabaseFavorite() => _instance;
  DatabaseFavorite._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(path,version: 1,onCreate: _onCreate,);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorite (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        coverId TEXT,
        year TEXT NOT NULL,
        key TEXT
      );
    ''');
  }

  Future<int> insertBook(Map<String, dynamic> favorite) async {
    final db = await database;
    return await db.insert('favorite', favorite);
  }

  Future<List<Map<String, dynamic>>> getfavorite() async {
    final db = await database;
    return await db.query('favorite');
  }

  Future<int> deleteFavorite(String title) async {
    final db = await database;
    return await db.delete('favorite', where: 'title = ?', whereArgs: [title]);
  }
  
  Future<int> deleteFavoriteByBookId(String booktitle) async {
    final db = await database;
    return await db.delete('favorite', where: 'title = ?', whereArgs: [booktitle]);
  }

  Future<int> updateFavorite(Map<String, dynamic> favorite) async {
    final db = await database;
    return await db.update('favorite', favorite, where: 'id = ?', whereArgs: [favorite['id']]);
  }
  
  Future<bool> isFavorite(String booktitle) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorite',where: 'title = ?',whereArgs: [booktitle],);
    return maps.isNotEmpty;
  }
}