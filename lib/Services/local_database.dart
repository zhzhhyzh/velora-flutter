import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'local_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile(
            id TEXT PRIMARY KEY,
            data TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE jobs(
            id TEXT PRIMARY KEY,
            data TEXT
          );
        ''');
      },
    );
  }

  // 🔵 Save or Update Single Data
  static Future<void> saveData({
    required String tableName,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.insert(
      tableName,
      {
        'id': id,
        'data': jsonEncode(data),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 🟣 Save Multiple Data
  static Future<void> saveMultipleData({
    required String tableName,
    required List<Map<String, dynamic>> dataList,
  }) async {
    final db = await database;
    final batch = db.batch();
    for (final data in dataList) {
      final id = data['id'];
      batch.insert(
        tableName,
        {
          'id': id,
          'data': jsonEncode(data),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // 🟢 Get Single Data by ID
  static Future<Map<String, dynamic>?> getData({
    required String tableName,
    required String id,
  }) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    final map = result.first;
    return jsonDecode(map['data'] as String) as Map<String, dynamic>;
  }

  // 🟡 Get All Data in Table
  static Future<List<Map<String, dynamic>>> getAllData({
    required String tableName,
  }) async {
    final db = await database;
    final result = await db.query(tableName);
    return result
        .map((e) => jsonDecode(e['data'] as String) as Map<String, dynamic>)
        .toList();
  }

  // 🧹 Clear Whole Table
  static Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }
}
