import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/water_intake.dart';

class WaterIntakeRepository {
  static const String _waterIntakeKey = 'water_intake';

  Future<List<WaterIntake>> getWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final waterIntakeJson = prefs.getString(_waterIntakeKey);
    if (waterIntakeJson == null) {
      return [];
    }
    final List<dynamic> waterIntakeList = jsonDecode(waterIntakeJson);
    return waterIntakeList.map((json) => WaterIntake.fromMap(json)).toList();
  }

  Future<void> addWaterIntake(double amount) async {
    final waterIntakeList = await getWaterIntake();
    final newWaterIntake = WaterIntake(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    waterIntakeList.add(newWaterIntake);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_waterIntakeKey, jsonEncode(waterIntakeList.map((e) => e.toMap()).toList()));
  }

  // New method to add water intake with a specific timestamp
  Future<void> addWaterIntakeWithTimestamp(double amount, int timestamp) async {
    final waterIntakeList = await getWaterIntake();
    final newWaterIntake = WaterIntake(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      timestamp: timestamp,
    );
    waterIntakeList.add(newWaterIntake);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_waterIntakeKey, jsonEncode(waterIntakeList.map((e) => e.toMap()).toList()));
  }

  Future<void> clearWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_waterIntakeKey);
  }
}