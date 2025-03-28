import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/custom_food.dart';

class CustomFoodRepository {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'custom_foods.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE custom_foods (
            id TEXT PRIMARY KEY,
            name TEXT,
            calories REAL,
            protein REAL,
            carbs REAL,
            fat REAL
          )
        ''');
      },
    );
  }

  Future<List<CustomFood>> getCustomFoods() async {
    final db = await database;
    final results = await db.query('custom_foods');
    return results.map((map) => CustomFood.fromMap(map)).toList();
  }

  Future<void> addCustomFood(CustomFood customFood) async {
    final db = await database;
    await db.insert('custom_foods', customFood.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}