import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/shopping_list_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListRepository {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shopping_list.db');
    try {
      return await openDatabase(
        path,
        version: 2, // Increment the version to trigger onUpgrade
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE shopping_list (
              id TEXT PRIMARY KEY,
              name TEXT,
              quantity REAL,
              checked INTEGER,
              servingSizeUnit TEXT
            )
          ''');
          print('ShoppingListRepository: Created shopping_list table in SQLite.');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE shopping_list ADD COLUMN servingSizeUnit TEXT');
            print('ShoppingListRepository: Added servingSizeUnit column to shopping_list table.');
          }
        },
        onOpen: (db) {
          print('ShoppingListRepository: Opened shopping_list database.');
        },
      );
    } catch (e, stackTrace) {
      print('ShoppingListRepository: Error initializing database: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<ShoppingListItem>> getShoppingList() async {
    try {
      final db = await database;
      final results = await db.query('shopping_list');
      final shoppingList = results.map((map) => ShoppingListItem.fromMap(map)).toList();
      print('ShoppingListRepository: Loaded ${shoppingList.length} shopping list items from SQLite: ${shoppingList.map((i) => i.toJson()).toList()}');
      return shoppingList;
    } catch (e, stackTrace) {
      print('ShoppingListRepository: Error loading shopping list from SQLite: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<void> saveShoppingList(List<ShoppingListItem> shoppingList) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete('shopping_list');
        for (var item in shoppingList) {
          await txn.insert('shopping_list', item.toMap());
        }
      });
      print('ShoppingListRepository: Saved ${shoppingList.length} shopping list items to SQLite.');
    } catch (e, stackTrace) {
      print('ShoppingListRepository: Error saving shopping list to SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to save shopping list: $e');
    }
  }

  Future<void> clearShoppingList() async {
    try {
      final db = await database;
      await db.delete('shopping_list');
      print('ShoppingListRepository: Cleared shopping list from SQLite.');
    } catch (e, stackTrace) {
      print('ShoppingListRepository: Error clearing shopping list from SQLite: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to clear shopping list: $e');
    }
  }

  Future<void> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shoppingListJson = prefs.getString('shopping_list') ?? '[]';
      final List<dynamic> shoppingListData = jsonDecode(shoppingListJson);
      final shoppingList = shoppingListData.map((data) => ShoppingListItem.fromJson(data)).toList();

      await saveShoppingList(shoppingList);
      print('ShoppingListRepository: Migrated ${shoppingList.length} shopping list items from SharedPreferences to SQLite.');

      // Clear SharedPreferences after migration
      await prefs.remove('shopping_list');
    } catch (e, stackTrace) {
      print('ShoppingListRepository: Error migrating shopping list from SharedPreferences to SQLite: $e');
      print('Stack trace: $stackTrace');
    }
  }
}