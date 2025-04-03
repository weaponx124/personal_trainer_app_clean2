import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/custom_food.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/custom_food_repository.dart';
import 'package:personal_trainer_app_clean/features/diet/diet_state_manager.dart';
import 'package:personal_trainer_app_clean/features/diet/widgets/add_custom_food_dialog.dart';
import 'package:personal_trainer_app_clean/features/diet/custom_food_dialog.dart';

class CustomFoodManager {
  final CustomFoodRepository _customFoodRepository;
  final DietStateManager _stateManager;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  CustomFoodManager({
    required CustomFoodRepository customFoodRepository,
    required DietStateManager stateManager,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  })  : _customFoodRepository = customFoodRepository,
        _stateManager = stateManager,
        _scaffoldMessengerKey = scaffoldMessengerKey;

  Future<void> loadCustomFoods() async {
    try {
      _stateManager.customFoods = await _customFoodRepository.getCustomFoods();
      print('CustomFoodManager: Loaded custom foods: ${_stateManager.customFoods.length}');
      for (var food in _stateManager.customFoods) {
        print('CustomFoodManager: Loaded custom food: ${food.toJson()}');
      }
      _stateManager.initializeAllFoods(_stateManager.customFoods);
    } catch (e) {
      print('CustomFoodManager: Error loading custom foods: $e');
      _stateManager.customFoods = [];
    }
  }

  void addCustomFood(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddCustomFoodDialog(
        onSave: (customFoodMap) async {
          final customFood = CustomFood(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: customFoodMap['name'] as String,
            calories: customFoodMap['calories'] as double,
            protein: customFoodMap['protein'] as double,
            carbs: customFoodMap['carbs'] as double,
            fat: customFoodMap['fat'] as double,
            sodium: customFoodMap['sodium'] as double,
            fiber: customFoodMap['fiber'] as double,
            servingSizeUnit: customFoodMap['servingSizeUnit'] as String,
            quantityPerServing: customFoodMap['quantityPerServing'] as double,
          );
          try {
            print('CustomFoodManager: Adding custom food: ${customFood.toJson()}');
            _stateManager.customFoods.add(customFood);
            await _customFoodRepository.addCustomFood(customFood);
            print('CustomFoodManager: Added custom food to repository');
            _stateManager.allFoods.add({
              'food': customFood.name,
              'measurement': customFood.servingSizeUnit ?? 'serving',
              'quantityPerServing': customFood.quantityPerServing,
              'calories': customFood.calories,
              'protein': customFood.protein,
              'carbs': customFood.carbs,
              'fat': customFood.fat,
              'sodium': customFood.sodium,
              'fiber': customFood.fiber,
              'servings': 1.0,
              'isRecipe': false,
            });
            print('CustomFoodManager: Updated allFoods: ${_stateManager.allFoods}');
            Navigator.pop(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('Custom food "${customFood.name}" added successfully!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            });
          } catch (e) {
            print('CustomFoodManager: Error adding custom food: $e');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('Failed to add custom food: $e'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }
        },
      ),
    );
  }

  void editCustomFood(BuildContext context, CustomFood food) {
    showDialog(
      context: context,
      builder: (context) => AddCustomFoodDialog(
        onSave: (customFoodMap) async {
          final updatedFood = CustomFood(
            id: food.id,
            name: customFoodMap['name'] as String,
            calories: customFoodMap['calories'] as double,
            protein: customFoodMap['protein'] as double,
            carbs: customFoodMap['carbs'] as double,
            fat: customFoodMap['fat'] as double,
            sodium: customFoodMap['sodium'] as double,
            fiber: customFoodMap['fiber'] as double,
            servingSizeUnit: customFoodMap['servingSizeUnit'] as String,
            quantityPerServing: customFoodMap['quantityPerServing'] as double,
          );
          try {
            print('CustomFoodManager: Updating custom food: ${updatedFood.toJson()}');
            _stateManager.customFoods = _stateManager.customFoods.map((f) {
              if (f.id == updatedFood.id) {
                return updatedFood;
              }
              return f;
            }).toList();
            await _customFoodRepository.addCustomFood(updatedFood);
            print('CustomFoodManager: Updated custom food in repository');
            _stateManager.initializeAllFoods(_stateManager.customFoods);
            Navigator.pop(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('Custom food "${updatedFood.name}" updated successfully!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            });
          } catch (e) {
            print('CustomFoodManager: Error updating custom food: $e');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('Failed to update custom food: $e'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }
        },
        initialCustomFood: food,
      ),
    );
  }

  Future<void> deleteCustomFood(String foodId) async {
    _stateManager.customFoods.removeWhere((food) => food.id == foodId);
    await _customFoodRepository.deleteCustomFood(foodId);
    _stateManager.initializeAllFoods(_stateManager.customFoods);
    print('CustomFoodManager: Deleted custom food with ID: $foodId');
  }

  void manageCustomFoods(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ManageCustomFoodDialog(
        customFoodManager: this,
        customFoods: _stateManager.customFoods,
      ),
    );
  }
}