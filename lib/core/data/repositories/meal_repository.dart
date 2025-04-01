import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/meal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealRepository {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'meals.db');
    try {
      return await openDatabase(
        path,
        version: 2, // Increment the version to trigger onUpgrade
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE meals (
              id TEXT PRIMARY KEY,
              food TEXT,
              mealType TEXT,
              calories REAL,
              protein REAL,
              carbs REAL,
              fat REAL,
              sodium REAL,
              fiber REAL,
              timestamp INTEGER,
              servings REAL,
              isRecipe INTEGER,
              ingredients TEXT,
              servingSizeUnit TEXT
            )
          ''');
          print('MealRepository: Created meals table in SQLite.');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE meals ADD COLUMN servingSizeUnit TEXT');
            print('MealRepository: Added servingSizeUnit column to meals table.');
          }
        },
        onOpen: (db) {
          print('MealRepository: Opened meals database.');
        },
      );
    } catch (e, stackTrace) {
      print('MealRepository: Error initializing database: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Meal>> getMeals() async {
    try {
      final db = await database;
      final results = await db.query('meals');
      final meals = results.map((map) => Meal.fromMap(map)).toList();
      print('MealRepository: Loaded ${meals.length} meals from SQLite: ${meals.map((m) => m.toJson()).toList()}');
      return meals;
    } catch (e, stackTrace) {
      print('MealRepository: Error loading meals from SQLite: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<void> insertMeal(Meal meal) async {
    try {
      final db = await database;
      await db.insert('meals', meal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      print('MealRepository: Inserted meal into SQLite: ${meal.toJson()}');
    } catch (e, stackTrace) {
      print('MealRepository: Error inserting meal into SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to insert meal: $e');
    }
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      final db = await database;
      await db.delete('meals', where: 'id = ?', whereArgs: [mealId]);
      print('MealRepository: Deleted meal with ID: $mealId');
    } catch (e, stackTrace) {
      print('MealRepository: Error deleting meal from SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to delete meal: $e');
    }
  }

  Future<void> clearMeals() async {
    try {
      final db = await database;
      await db.delete('meals');
      print('MealRepository: Cleared all meals from SQLite');
    } catch (e, stackTrace) {
      print('MealRepository: Error clearing meals from SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to clear meals: $e');
    }
  }

  Future<void> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getString('meals') ?? '[]';
      final List<dynamic> mealsList = jsonDecode(mealsJson);
      final meals = mealsList.map((data) => Meal.fromJson(data)).toList();

      for (var meal in meals) {
        await insertMeal(meal);
      }
      print('MealRepository: Migrated ${meals.length} meals from SharedPreferences to SQLite.');

      // Clear SharedPreferences after migration
      await prefs.remove('meals');
    } catch (e, stackTrace) {
      print('MealRepository: Error migrating meals from SharedPreferences to SQLite: $e');
      print('Stack trace: $stackTrace');
    }
  }
}