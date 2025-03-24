import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/services/database_service.dart';
import 'package:personal_trainer_app_clean/core/utils/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgramRepository {
  final DatabaseService _databaseService = getIt<DatabaseService>();

  Future<List<Program>> getPrograms() async {
    try {
      final programs = await _databaseService.getPrograms();
      print('ProgramRepository: Retrieved ${programs.length} programs: ${programs.map((p) => p.id).toList()}');
      return programs;
    } catch (e) {
      print('Error loading programs: $e');
      return [];
    }
  }

  Future<Program?> getProgram(String programId) async {
    try {
      return await _databaseService.getProgram(programId);
    } catch (e) {
      print('Error loading program: $e');
      return null;
    }
  }

  Future<void> insertProgram(Program program) async {
    try {
      await _databaseService.insertProgram(program);
    } catch (e) {
      print('Error inserting program: $e');
      throw Exception('Failed to insert program: $e');
    }
  }

  Future<void> updateProgram(Program program) async {
    try {
      await _databaseService.updateProgram(program);
    } catch (e) {
      print('Error updating program: $e');
      throw Exception('Failed to update program: $e');
    }
  }

  Future<void> deleteProgram(String programId) async {
    try {
      await _databaseService.deleteProgram(programId);
    } catch (e) {
      print('Error deleting program: $e');
      throw Exception('Failed to delete program: $e');
    }
  }

  // Migrate existing data from SharedPreferences to SQLite (one-time operation)
  Future<void> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programData = prefs.getString('programs') ?? '[]';
      final List<dynamic> programList = jsonDecode(programData);
      final programs = programList.map((data) => Program.fromMap(data)).toList();

      for (var program in programs) {
        await insertProgram(program);
      }
      print('ProgramRepository: Migrated ${programs.length} programs from SharedPreferences to SQLite.');

      // Clear SharedPreferences after migration
      await prefs.remove('programs');
    } catch (e) {
      print('Error migrating programs from SharedPreferences: $e');
    }
  }
}