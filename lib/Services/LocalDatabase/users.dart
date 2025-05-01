import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../Models/users.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    return await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            phoneNumber TEXT,
            position TEXT,
            userImage TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertUser(UserModel user) async {
    if (kIsWeb) return;
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<UserModel?> getUserById(String id) async {
    if (kIsWeb) return null;
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  static Future<List<UserModel>> getAllUsers() async {
    if (kIsWeb) return [];

    final db = await database;
    final maps = await db.query('users');

    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  static Future<void> deleteUserById(String id) async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearUsers() async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete('users');
  }
}
