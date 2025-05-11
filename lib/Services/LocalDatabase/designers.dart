import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../Models/designers.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    return await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'designers.db'); // Name of the DB

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE designers (
            id TEXT PRIMARY KEY,
            name TEXT,
            category TEXT,
            contact TEXT,
            country TEXT,
            desc TEXT,
            designerId TEXT,
            email TEXT,
            profileImg TEXT,
            rate TEXT,
            slogan TEXT,
            state TEXT
          )
        ''');
      },
    );
  }

  // Insert designer into local DB
  static Future<void> insertDesigner(DesignerModel designer) async {
    if (kIsWeb) return;
    final db = await database;
    await db.insert(
      'designers',
      designer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if the designer already exists
    );
  }

  // Fetch all designers from local DB
  static Future<List<DesignerModel>> getDesigners() async {
    if (kIsWeb) return [];

    final db = await database;
    final maps = await db.query('designers');

    return maps.map((map) => DesignerModel.fromMap(map)).toList();
  }

  // Clear all designers in local DB
  static Future<void> clearDesigners() async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete('designers');
  }
}
