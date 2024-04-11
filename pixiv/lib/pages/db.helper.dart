import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'favorites.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favorites(id TEXT PRIMARY KEY, tags TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insert(String id, List<String> tags) async {
    final db = await database(); // 注意这里的调用方式
    await db.insert(
      'favorites',
      {'id': id, 'tags': tags.join(', ')},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> isFavorited(String id) async {
    final db = await database(); // 注意这里的调用方式
    final maps = await db.query(
      'favorites',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  static Future<void> delete(String id) async {
    final db = await database(); // 注意这里的调用方式
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> getAllFavorites() async {
    final db = await DBHelper.database();
    return db.query('favorites');
  }
}
