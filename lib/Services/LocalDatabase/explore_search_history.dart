import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ExploreSearchHistory {
  static final ExploreSearchHistory _instance = ExploreSearchHistory._internal();
  static Database? _database;

  factory ExploreSearchHistory() {
    return _instance;
  }

  ExploreSearchHistory._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'veloras.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
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

  Future<void> addSearchQuery(String query) async {
    try {
      final db = await database;
      await db.insert(
        'search_history',
        {
          'query': query,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error adding search query: $e');
      rethrow;
    }
  }

  Future<List<String>> getRecentSearches({int limit = 10}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'search_history',
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return List.generate(maps.length, (i) {
        return maps[i]['query'] as String;
      });
    } catch (e) {
      print('Error getting recent searches: $e');
      return [];
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      final db = await database;
      await db.delete('search_history');
    } catch (e) {
      print('Error clearing search history: $e');
      rethrow;
    }
  }

  Future<void> removeSearchQuery(String query) async {
    try {
      final db = await database;
      await db.delete(
        'search_history',
        where: 'query = ?',
        whereArgs: [query],
      );
    } catch (e) {
      print('Error removing search query: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
} 