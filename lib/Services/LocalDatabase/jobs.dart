import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/jobs.dart'; // Adjust path as needed

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    return await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jobs.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE jobs (
            id TEXT PRIMARY KEY,
            jobTitle TEXT,
            comName TEXT,
            jobLocation TEXT,
            jobCat TEXT,
            jobImage TEXT,
            deadline TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertJob(JobModel job) async {
    if (kIsWeb) return;
    final db = await database;
    await db.insert(
      'jobs',
      job.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<JobModel>> getJobs() async {
    if (kIsWeb) return [];

    final db = await database;
    final maps = await db.query('jobs');

    return maps.map((map) => JobModel.fromMap(map)).toList();
  }

  static Future<void> clearJobs() async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete('jobs');
  }
}
