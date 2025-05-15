import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/contest.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    return await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'veloras.db');

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

        await db.execute('''
          CREATE TABLE search_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            query TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');

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

        await db.execute('''
          CREATE TABLE contests (
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            category TEXT,
            startDate TEXT,
            endDate TEXT,
            coverImagePath TEXT,
            createdBy TEXT,
            createdAt TEXT,
            isActive INTEGER
          )
        ''');
      },
    );
  }

  static Future<void> insertContest(Contest contest) async {
    if (kIsWeb) return;
    final db = await database;
    await db.insert(
      'contests',
      contest.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Contest>> getContests() async {
    if (kIsWeb) return [];

    final db = await database;
    final maps = await db.query('contests');

    return maps.map((map) => Contest(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      coverImagePath: map['coverImagePath'] as String,
      createdBy: map['createdBy'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: (map['isActive'] as int) == 1,
    )).toList();
  }

  static Future<void> clearContests() async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete('contests');
  }
}
