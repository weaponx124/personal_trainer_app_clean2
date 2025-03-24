import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import 'dart:io' show Platform;

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'personal_trainer.db';
  static const int _databaseVersion = 1;

  DatabaseService() {
    // Initialize sqflite_common_ffi for Windows
    if (Platform.isWindows) {
      print('DatabaseService: Initializing sqflite_common_ffi for Windows...');
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print('DatabaseService: Initializing database...');
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        print('DatabaseService: Creating database tables...');
        await db.execute('''
          CREATE TABLE programs (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            details TEXT NOT NULL,
            oneRMs TEXT NOT NULL,
            currentWeek INTEGER NOT NULL,
            currentSession INTEGER NOT NULL,
            sessionsCompleted INTEGER NOT NULL,
            startDate TEXT NOT NULL,
            completed INTEGER NOT NULL,
            workouts TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE workouts (
            id TEXT PRIMARY KEY,
            programId TEXT NOT NULL,
            name TEXT NOT NULL,
            exercises TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            FOREIGN KEY (programId) REFERENCES programs(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE meals (
            id TEXT PRIMARY KEY,
            food TEXT NOT NULL,
            mealType TEXT NOT NULL,
            calories REAL,
            protein REAL,
            carbs REAL,
            fat REAL,
            sodium REAL,
            fiber REAL,
            timestamp INTEGER NOT NULL,
            servings REAL,
            isRecipe INTEGER NOT NULL,
            ingredients TEXT
          )
        ''');
      },
    );
  }

  // Program CRUD Operations
  Future<void> insertProgram(Program program) async {
    final db = await database;
    await db.insert(
      'programs',
      program.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('DatabaseService: Inserted program: ${program.name} with ID: ${program.id}');
  }

  Future<List<Program>> getPrograms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('programs');
    print('DatabaseService: Retrieved ${maps.length} programs from SQLite: $maps');
    return List.generate(maps.length, (i) => Program.fromMap(maps[i]));
  }

  Future<Program?> getProgram(String programId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'programs',
      where: 'id = ?',
      whereArgs: [programId],
    );
    if (maps.isNotEmpty) {
      return Program.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateProgram(Program program) async {
    final db = await database;
    await db.update(
      'programs',
      program.toMap(),
      where: 'id = ?',
      whereArgs: [program.id],
    );
    print('DatabaseService: Updated program: ${program.name}');
  }

  Future<void> deleteProgram(String programId) async {
    final db = await database;
    await db.delete(
      'programs',
      where: 'id = ?',
      whereArgs: [programId],
    );
    print('DatabaseService: Deleted program with ID: $programId');
  }

  // Workout CRUD Operations
  Future<void> insertWorkout(Workout workout) async {
    final db = await database;
    await db.insert(
      'workouts',
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('DatabaseService: Inserted workout: ${workout.name} with programId: ${workout.programId}');
  }

  Future<List<Workout>> getWorkouts(String programId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'programId = ?',
      whereArgs: [programId],
    );
    print('DatabaseService: Retrieved ${maps.length} workouts for program $programId from SQLite: $maps');
    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  Future<void> updateWorkout(Workout workout) async {
    final db = await database;
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
    print('DatabaseService: Updated workout: ${workout.name}');
  }

  Future<void> clearWorkouts(String programId) async {
    final db = await database;
    await db.delete(
      'workouts',
      where: 'programId = ?',
      whereArgs: [programId],
    );
    print('DatabaseService: Cleared workouts for program ID: $programId');
  }

  // Meal CRUD Operations
  Future<void> insertMeal(Meal meal) async {
    final db = await database;
    await db.insert(
      'meals',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('DatabaseService: Inserted meal: ${meal.food}');
  }

  Future<List<Meal>> getMeals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('meals');
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  Future<void> deleteMeal(String mealId) async {
    final db = await database;
    await db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [mealId],
    );
    print('DatabaseService: Deleted meal with ID: $mealId');
  }

  Future<void> clearMeals() async {
    final db = await database;
    await db.delete('meals');
    print('DatabaseService: Cleared all meals');
  }
}