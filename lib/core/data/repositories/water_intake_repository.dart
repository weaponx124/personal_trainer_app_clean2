import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/water_intake.dart';

class WaterIntakeRepository {
  static const String _waterIntakeKey = 'waterIntake';

  Future<List<WaterIntake>> getWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final waterIntakeJson = prefs.getString(_waterIntakeKey);
    if (waterIntakeJson == null) return [];
    final waterIntakeList = jsonDecode(waterIntakeJson) as List<dynamic>;
    return waterIntakeList.map((entry) {
      if (entry == null) return null;
      return WaterIntake.fromMap(entry as Map<String, dynamic>);
    }).whereType<WaterIntake>().toList();
  }

  Future<void> addWaterIntake(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final waterIntake = await getWaterIntake();
    final entry = WaterIntake(
      id: Uuid().v4(),
      amount: amount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    waterIntake.add(entry);
    await prefs.setString(_waterIntakeKey, jsonEncode(waterIntake.map((e) => e.toMap()).toList()));
    print('Added water intake: ${entry.toMap()}');
  }

  Future<void> clearWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_waterIntakeKey, jsonEncode([]));
    print('Cleared water intake');
  }
}