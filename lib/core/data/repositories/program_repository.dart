import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';

class ProgramRepository {
  static const String _programsKey = 'programs';

  Future<List<Program>> getPrograms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programsJson = prefs.getString(_programsKey);
      print('Programs JSON from SharedPreferences: $programsJson');
      if (programsJson == null) return [];
      final programsList = jsonDecode(programsJson) as List<dynamic>;
      final programs = programsList.map((program) => Program.fromMap(program as Map<String, dynamic>)).toList();
      print('Loaded programs: ${programs.map((p) => p.toMap()).toList()}');
      return programs;
    } catch (e, stackTrace) {
      print('Error loading programs: $e');
      print('Stack trace: $stackTrace');
      await clearPrograms();
      return [];
    }
  }

  Future<void> insertProgram(Program program) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programs = await getPrograms();
      final programWithId = Program(
        id: Uuid().v4(),
        name: program.name,
        description: program.description,
      );
      programs.add(programWithId);
      print('Inserting program: ${programWithId.toMap()}');
      await prefs.setString(_programsKey, jsonEncode(programs.map((p) => p.toMap()).toList()));
      print('Saved programs to SharedPreferences: ${prefs.getString(_programsKey)}');
    } catch (e, stackTrace) {
      print('Error inserting program: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to insert program: $e');
    }
  }

  Future<void> updateProgram(Program updatedProgram) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programs = await getPrograms();
      final index = programs.indexWhere((p) => p.id == updatedProgram.id);
      if (index != -1) {
        programs[index] = updatedProgram;
        print('Updating program: ${updatedProgram.toMap()}');
        await prefs.setString(_programsKey, jsonEncode(programs.map((p) => p.toMap()).toList()));
        print('Saved programs to SharedPreferences: ${prefs.getString(_programsKey)}');
      } else {
        throw Exception('Program with ID ${updatedProgram.id} not found');
      }
    } catch (e, stackTrace) {
      print('Error updating program: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to update program: $e');
    }
  }

  Future<void> deleteProgram(String programId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programs = await getPrograms();
      programs.removeWhere((p) => p.id == programId);
      print('Deleting program with ID: $programId');
      await prefs.setString(_programsKey, jsonEncode(programs.map((p) => p.toMap()).toList()));
      print('Saved programs to SharedPreferences: ${prefs.getString(_programsKey)}');
    } catch (e, stackTrace) {
      print('Error deleting program: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to delete program: $e');
    }
  }

  Future<void> clearPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_programsKey);
    print('Cleared all programs from SharedPreferences');
  }
}