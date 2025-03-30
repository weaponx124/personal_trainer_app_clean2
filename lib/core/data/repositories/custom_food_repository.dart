import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/custom_food.dart';

class CustomFoodRepository {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'custom_foods.db');
    try {
      return await openDatabase(
        path,
        version: 2, // Increment the version to trigger onUpgrade
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE custom_foods (
              id TEXT PRIMARY KEY,
              name TEXT,
              calories REAL,
              protein REAL,
              carbs REAL,
              fat REAL,
              sodium REAL,  -- Added sodium column
              fiber REAL    -- Added fiber column
            )
          ''');
          print('CustomFoodRepository: Created custom_foods table in SQLite.');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Add sodium and fiber columns to existing table
            await db.execute('ALTER TABLE custom_foods ADD COLUMN sodium REAL DEFAULT 0.0');
            await db.execute('ALTER TABLE custom_foods ADD COLUMN fiber REAL DEFAULT 0.0');
            print('CustomFoodRepository: Migrated custom_foods table to version 2 (added sodium and fiber columns).');
          }
        },
        onOpen: (db) {
          print('CustomFoodRepository: Opened custom_foods database.');
        },
      );
    } catch (e, stackTrace) {
      print('CustomFoodRepository: Error initializing database: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<CustomFood>> getCustomFoods() async {
    try {
      final db = await database;
      final results = await db.query('custom_foods');
      final foods = results.map((map) => CustomFood.fromMap(map)).toList();
      print('CustomFoodRepository: Loaded ${foods.length} custom foods from SQLite: ${foods.map((f) => f.toMap()).toList()}');
      return foods;
    } catch (e, stackTrace) {
      print('CustomFoodRepository: Error loading custom foods from SQLite: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<void> addCustomFood(CustomFood food) async {
    try {
      final db = await database;
      await db.insert('custom_foods', food.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      print('CustomFoodRepository: Added custom food to SQLite: ${food.toMap()}');
    } catch (e, stackTrace) {
      print('CustomFoodRepository: Error adding custom food to SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to add custom food: $e');
    }
  }

  Future<void> updateCustomFood(CustomFood food) async {
    try {
      final db = await database;
      await db.update(
        'custom_foods',
        food.toMap(),
        where: 'id = ?',
        whereArgs: [food.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('CustomFoodRepository: Updated custom food in SQLite: ${food.toMap()}');
    } catch (e, stackTrace) {
      print('CustomFoodRepository: Error updating custom food in SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to update custom food: $e');
    }
  }

  Future<void> deleteCustomFood(String foodId) async {
    try {
      final db = await database;
      await db.delete(
        'custom_foods',
        where: 'id = ?',
        whereArgs: [foodId],
      );
      print('CustomFoodRepository: Deleted custom food with ID: $foodId');
    } catch (e, stackTrace) {
      print('CustomFoodRepository: Error deleting custom food from SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to delete custom food: $e');
    }
  }
}