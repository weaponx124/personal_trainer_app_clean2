import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/custom_food.dart';

class CustomFoodRepository {
  static const String _customFoodsKey = 'custom_foods';

  Future<List<CustomFood>> getCustomFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final String? customFoodsJson = prefs.getString(_customFoodsKey);
    if (customFoodsJson == null) return [];
    final List<dynamic> customFoodsList = jsonDecode(customFoodsJson);
    return customFoodsList.map((map) => CustomFood.fromMap(map)).toList();
  }

  Future<void> saveCustomFoods(List<CustomFood> customFoods) async {
    final prefs = await SharedPreferences.getInstance();
    final customFoodsJson = jsonEncode(customFoods.map((food) => food.toMap()).toList());
    await prefs.setString(_customFoodsKey, customFoodsJson);
  }

  Future<void> addCustomFood(CustomFood customFood) async {
    final customFoods = await getCustomFoods();
    customFoods.add(customFood);
    await saveCustomFoods(customFoods);
  }
}