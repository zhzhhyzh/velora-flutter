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
    String path = join(await getDatabasesPath(), 'explore_search_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE search_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            query TEXT NOT NULL,
            timestamp INTEGER NOT NULL
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