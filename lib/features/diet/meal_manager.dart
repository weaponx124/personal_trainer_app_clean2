import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/meal_repository.dart';
import 'package:personal_trainer_app_clean/features/diet/diet_state_manager.dart';
import 'package:personal_trainer_app_clean/features/diet/widgets/add_meal_dialog.dart';

class MealManager {
  final MealRepository _mealRepository;
  final DietStateManager _stateManager;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  MealManager({
    required MealRepository mealRepository,
    required DietStateManager stateManager,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  })  : _mealRepository = mealRepository,
        _stateManager = stateManager,
        _scaffoldMessengerKey = scaffoldMessengerKey {
    print('MealManager: Initialized with stateManager meals: ${_stateManager.meals.value.length}');
  }

  Future<void> loadMeals() async {
    try {
      // Clear the database on app start to ensure no phantom meals (remove this if you want persistence)
      // await _mealRepository.clearMeals();
      // print('MealManager: Cleared meals database');

      final loadedMeals = await _mealRepository.getMeals();
      print('MealManager: Loaded ${loadedMeals.length} meals from repository');
      for (var meal in loadedMeals) {
        print('MealManager: Loaded meal: ${meal.toJson()}');
      }
      _stateManager.meals.value = loadedMeals;
      print('MealManager: Updated stateManager meals, new count: ${_stateManager.meals.value.length}');
    } catch (e) {
      print('MealManager: Error loading meals from repository: $e');
      _stateManager.meals.value = [];
    }
  }

  void addMeal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddMealDialog(
        stateManager: _stateManager,
        onMealAdded: (meal) async {
          print('MealManager: Adding meal: ${meal.toJson()}');
          _stateManager.meals.value = [..._stateManager.meals.value, meal];
          await _mealRepository.insertMeal(meal);
          await loadMeals(); // Reload meals to ensure consistency with the database
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('Meal "${meal.food}" added successfully!'),
                duration: const Duration(seconds: 2),
              ),
            );
          });
        },
      ),
    );
  }

  void showAddMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddMealDialog(
        stateManager: _stateManager,
        onMealAdded: (meal) async {
          print('MealManager: Adding meal from showAddMealDialog: ${meal.toJson()}');
          _stateManager.meals.value = [..._stateManager.meals.value, meal];
          await _mealRepository.insertMeal(meal);
          await loadMeals(); // Reload meals to ensure consistency with the database
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('Meal "${meal.food}" added successfully!'),
                duration: const Duration(seconds: 2),
              ),
            );
          });
        },
      ),
    );
  }

  void editMeal(BuildContext context, Meal meal) {
    showDialog(
      context: context,
      builder: (context) => AddMealDialog(
        stateManager: _stateManager,
        onMealAdded: (updatedMeal) async {
          print('MealManager: Updating meal: ${updatedMeal.toJson()}');
          _stateManager.meals.value = _stateManager.meals.value.map((m) {
            if (m.id == meal.id) {
              return updatedMeal.copyWith(id: meal.id, timestamp: meal.timestamp);
            }
            return m;
          }).toList();
          await _mealRepository.insertMeal(updatedMeal.copyWith(id: meal.id, timestamp: meal.timestamp));
          await loadMeals(); // Reload meals to ensure consistency with the database
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('Meal "${updatedMeal.food}" updated successfully!'),
                duration: const Duration(seconds: 2),
              ),
            );
          });
        },
        initialMeal: meal,
      ),
    );
  }

  void deleteMeal(String mealId) async {
    _stateManager.meals.value = _stateManager.meals.value.where((meal) => meal.id != mealId).toList();
    await _mealRepository.deleteMeal(mealId);
    await loadMeals(); // Reload meals to ensure consistency with the database
  }

  void addFoodToMeal(String foodId, Meal meal) {
    // Placeholder method, not implemented
  }
}