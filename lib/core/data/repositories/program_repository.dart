import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgramRepository {
  Future<List<Program>> getPrograms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programData = prefs.getString('programs') ?? '[]';
      final List<dynamic> programList = jsonDecode(programData);
      return programList.map((data) => Program.fromMap(data)).toList();
    } catch (e) {
      print('Error loading programs: $e');
      return [];
    }
  }

  Future<Program?> getProgram(String programId) async {
    try {
      final programs = await getPrograms();
      return programs.firstWhere((program) => program.id == programId, orElse: () => null as Program);
    } catch (e) {
      print('Error loading program: $e');
      return null;
    }
  }

  Future<void> insertProgram(Program program) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programs = await getPrograms();
      programs.add(program);
      await prefs.setString('programs', jsonEncode(programs.map((p) => p.toMap()).toList()));
      print('Inserted program: ${program.name}');
    } catch (e) {
      print('Error inserting program: $e');
      throw Exception('Failed to insert program: $e');
    }
  }

  Future<void> updateProgram(Program program) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programs = await getPrograms();
      final index = programs.indexWhere((p) => p.id == program.id);
      if (index != -1) {
        programs[index] = program;
        await prefs.setString('programs', jsonEncode(programs.map((p) => p.toMap()).toList()));
        print('Updated program: ${program.name}');
      }
    } catch (e) {
      print('Error updating program: $e');
      throw Exception('Failed to update program: $e');
    }
  }

  Future<void> deleteProgram(String programId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programs = await getPrograms();
      final updatedPrograms = programs.where((p) => p.id != programId).toList();
      await prefs.setString('programs', jsonEncode(updatedPrograms.map((p) => p.toMap()).toList()));
      print('Deleted program with ID: $programId');
    } catch (e) {
      print('Error deleting program: $e');
      throw Exception('Failed to delete program: $e');
    }
  }
}