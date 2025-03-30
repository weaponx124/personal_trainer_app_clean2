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
      return await openDatabase(
        path,
        version: 1,
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
              ingredients TEXT
            )
          ''');
          print('RecipeRepository: Created recipes table in SQLite.');
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
      print('RecipeRepository: Loaded ${recipes.length} recipes from SQLite: ${recipes.map((r) => r.toMap()).toList()}');
      return recipes;
    } catch (e, stackTrace) {
      print('RecipeRepository: Error loading recipes from SQLite: $e');
      print('Stack trace: $stackTrace');
      // Clear recipes to prevent future errors
      await clearRecipes();
      return [];
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      final db = await database;
      await db.insert('recipes', recipe.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      print('RecipeRepository: Added recipe to SQLite: ${recipe.toMap()}');
    } catch (e, stackTrace) {
      print('RecipeRepository: Error adding recipe to SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to add recipe: $e');
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      final db = await database;
      await db.update(
        'recipes',
        recipe.toMap(),
        where: 'id = ?',
        whereArgs: [recipe.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('RecipeRepository: Updated recipe in SQLite: ${recipe.toMap()}');
    } catch (e, stackTrace) {
      print('RecipeRepository: Error updating recipe in SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to update recipe: $e');
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      final db = await database;
      await db.delete(
        'recipes',
        where: 'id = ?',
        whereArgs: [recipeId],
      );
      print('RecipeRepository: Deleted recipe with ID from SQLite: $recipeId');
    } catch (e, stackTrace) {
      print('RecipeRepository: Error deleting recipe from SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to delete recipe: $e');
    }
  }

  Future<void> clearRecipes() async {
    try {
      final db = await database;
      await db.delete('recipes');
      print('RecipeRepository: Cleared all recipes from SQLite');
    } catch (e, stackTrace) {
      print('RecipeRepository: Error clearing recipes from SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to clear recipes: $e');
    }
  }

  // Migrate existing recipes from SharedPreferences to SQLite (one-time operation)
  Future<void> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getString('recipes') ?? '[]';
      final List<dynamic> recipesList = jsonDecode(recipesJson);
      final recipes = recipesList.map((data) => Recipe.fromMap(data)).toList();

      for (var recipe in recipes) {
        await addRecipe(recipe);
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