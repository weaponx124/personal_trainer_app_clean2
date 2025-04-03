import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeRepository {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'recipes.db');
    try {
      print('RecipeRepository: Initializing database at path: $path');
      return await openDatabase(
        path,
        version: 3, // Increment the version to trigger onUpgrade
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE recipes (
              id TEXT PRIMARY KEY,
              name TEXT,
              calories REAL,
              protein REAL,
              carbs REAL,
              fat REAL,
              sodium REAL,
              fiber REAL,
              ingredients TEXT,
              servingSizeUnit TEXT,
              quantityPerServing REAL
            )
          ''');
          print('RecipeRepository: Created recipes table in SQLite.');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE recipes ADD COLUMN servingSizeUnit TEXT');
            print('RecipeRepository: Added servingSizeUnit column to recipes table.');
          }
          if (oldVersion < 3) {
            await db.execute('ALTER TABLE recipes ADD COLUMN quantityPerServing REAL');
            print('RecipeRepository: Added quantityPerServing column to recipes table.');
          }
        },
        onOpen: (db) {
          print('RecipeRepository: Opened recipes database.');
        },
      );
    } catch (e, stackTrace) {
      print('RecipeRepository: Error initializing database: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Recipe>> getRecipes() async {
    try {
      final db = await database;
      final results = await db.query('recipes');
      final recipes = results.map((map) => Recipe.fromMap(map)).toList();
      print('RecipeRepository: Loaded ${recipes.length} recipes from SQLite: ${recipes.map((r) => r.toJson()).toList()}');
      return recipes;
    } catch (e, stackTrace) {
      print('RecipeRepository: Error loading recipes from SQLite: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<void> insertRecipe(Recipe recipe) async {
    try {
      final db = await database;
      print('RecipeRepository: Inserting recipe: ${recipe.toJson()}');
      await db.insert('recipes', recipe.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      print('RecipeRepository: Inserted recipe into SQLite: ${recipe.toJson()}');
    } catch (e, stackTrace) {
      print('RecipeRepository: Error inserting recipe into SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to insert recipe: $e');
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      final db = await database;
      await db.delete('recipes', where: 'id = ?', whereArgs: [recipeId]);
      print('RecipeRepository: Deleted recipe with ID: $recipeId');
    } catch (e, stackTrace) {
      print('RecipeRepository: Error deleting recipe from SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to delete recipe: $e');
    }
  }

  Future<void> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getString('recipes') ?? '[]';
      final List<dynamic> recipesList = jsonDecode(recipesJson);
      final recipes = recipesList.map((data) => Recipe.fromJson(data)).toList();

      for (var recipe in recipes) {
        await insertRecipe(recipe);
      }
      print('RecipeRepository: Migrated ${recipes.length} recipes from SharedPreferences to SQLite.');

      // Clear SharedPreferences after migration
      await prefs.remove('recipes');
    } catch (e, stackTrace) {
      print('RecipeRepository: Error migrating recipes from SharedPreferences to SQLite: $e');
      print('Stack trace: $stackTrace');
    }
  }
}