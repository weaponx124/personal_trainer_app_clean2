import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/custom_food.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              sodium REAL,
              fiber REAL,
              servingSizeUnit TEXT
            )
          ''');
          print('CustomFoodRepository: Created custom_foods table in SQLite.');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE custom_foods ADD COLUMN servingSizeUnit TEXT');
            print('CustomFoodRepository: Added servingSizeUnit column to custom_foods table.');
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
      final customFoods = results.map((map) => CustomFood.fromMap(map)).toList();
      print('CustomFoodRepository: Loaded ${customFoods.length} custom foods from SQLite: ${customFoods.map((f) => f.toJson()).toList()}');
      return customFoods;
    } catch (e, stackTrace) {
      print('CustomFoodRepository: Error loading custom foods from SQLite: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<void> addCustomFood(CustomFood customFood) async {
    try {
      final db = await database;
      await db.insert('custom_foods', customFood.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      print('CustomFoodRepository: Inserted custom food into SQLite: ${customFood.toJson()}');
    } catch (e, stackTrace) {
      print('CustomFoodRepository: Error inserting custom food into SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to insert custom food: $e');
    }
  }

  Future<void> deleteCustomFood(String foodId) async {
    try {
      final db = await database;
      await db.delete('custom_foods', where: 'id = ?', whereArgs: [foodId]);
      print('CustomFoodRepository: Deleted custom food with ID: $foodId');
    } catch (e, stackTrace) {
      print('CustomFoodRepository: Error deleting custom food from SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to delete custom food: $e');
    }
  }

  Future<void> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customFoodsJson = prefs.getString('custom_foods') ?? '[]';
      final List<dynamic> customFoodsList = jsonDecode(customFoodsJson);
      final customFoods = customFoodsList.map((data) => CustomFood.fromJson(data)).toList();

      for (var customFood in customFoods) {
        await addCustomFood(customFood);
      }
      print('CustomFoodRepository: Migrated ${customFoods.length} custom foods from SharedPreferences to SQLite.');

      // Clear SharedPreferences after migration
      await prefs.remove('custom_foods');
    } catch (e, stackTrace) {
      print('CustomFoodRepository: Error migrating custom foods from SharedPreferences to SQLite: $e');
      print('Stack trace: $stackTrace');
    }
  }
}