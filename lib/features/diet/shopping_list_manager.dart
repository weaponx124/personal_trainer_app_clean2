import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';
import 'package:personal_trainer_app_clean/core/data/models/shopping_list_item.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/shopping_list_repository.dart';
import 'package:personal_trainer_app_clean/features/diet/diet_state_manager.dart';

class ShoppingListManager {
  final ShoppingListRepository _shoppingListRepository;
  final DietStateManager _stateManager;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  ShoppingListManager({
    required ShoppingListRepository shoppingListRepository,
    required DietStateManager stateManager,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  })  : _shoppingListRepository = shoppingListRepository,
        _stateManager = stateManager,
        _scaffoldMessengerKey = scaffoldMessengerKey;

  Future<void> loadShoppingList() async {
    try {
      _stateManager.shoppingList.value = await _shoppingListRepository.getShoppingList();
      print('Loaded shopping list items from repository: ${_stateManager.shoppingList.value.length}');
      for (var item in _stateManager.shoppingList.value) {
        print('Loaded shopping list item: ${item.toJson()}');
      }
    } catch (e) {
      print('Error loading shopping list from repository: $e');
      _stateManager.shoppingList.value = [];
    }
  }

  void addShoppingItem(ShoppingListItem item) async {
    _stateManager.shoppingList.value = [..._stateManager.shoppingList.value, item];
    await _shoppingListRepository.saveShoppingList(_stateManager.shoppingList.value);
  }

  void toggleShoppingItem(String itemId, bool value) async {
    print('Toggling shopping item with ID: $itemId to checked: $value');
    _stateManager.shoppingList.value = _stateManager.shoppingList.value.map((item) {
      if (item.id == itemId) {
        print('Found matching item: ${item.toJson()}');
        return ShoppingListItem(
          id: item.id,
          name: item.name,
          quantity: item.quantity,
          checked: value,
          servingSizeUnit: item.servingSizeUnit,
        );
      }
      return item;
    }).toList();
    print('Updated shopping list: ${_stateManager.shoppingList.value.map((i) => i.toJson()).toList()}');
    await _shoppingListRepository.saveShoppingList(_stateManager.shoppingList.value);
  }

  void generateShoppingList() async {
    final now = DateTime.now();
    final startOfPeriod = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    final endOfPeriod = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    final mealsInPeriod = _stateManager.meals.value.where((meal) {
      final timestamp = meal.timestamp;
      return timestamp >= startOfPeriod && timestamp <= endOfPeriod;
    }).toList();

    final Map<String, Map<String, dynamic>> ingredientQuantities = {};
    for (var meal in mealsInPeriod) {
      final servings = meal.servings;
      if (meal.isRecipe) {
        final recipe = _stateManager.recipes.value.firstWhere(
              (r) => r.id == meal.food,
          orElse: () => Recipe(
            id: '',
            name: meal.food,
            calories: meal.calories,
            protein: meal.protein,
            carbs: meal.carbs,
            fat: meal.fat,
            sodium: meal.sodium,
            fiber: meal.fiber,
            ingredients: [],
          ),
        );
        for (var ingredient in recipe.ingredients) {
          final foodName = ingredient['food'] as String;
          final ingredientServings = (ingredient['servings'] as double) * servings;
          final measurement = ingredient['measurement'] as String;
          if (!ingredientQuantities.containsKey(foodName)) {
            ingredientQuantities[foodName] = {
              'quantity': 0.0,
              'servingSizeUnit': measurement,
            };
          }
          ingredientQuantities[foodName]!['quantity'] = (ingredientQuantities[foodName]!['quantity'] as double) + ingredientServings;
        }
      } else {
        final foodName = meal.food;
        // Look up the food in foodDatabase or allFoods to get the measurement
        final foodEntry = _stateManager.allFoods.firstWhere(
              (f) => f['food'] == foodName,
          orElse: () => _stateManager.foodDatabase.firstWhere(
                (f) => f['food'] == foodName,
            orElse: () => {'food': foodName, 'measurement': 'serving'},
          ),
        );
        final measurement = foodEntry['measurement'] as String;
        if (!ingredientQuantities.containsKey(foodName)) {
          ingredientQuantities[foodName] = {
            'quantity': 0.0,
            'servingSizeUnit': measurement,
          };
        }
        ingredientQuantities[foodName]!['quantity'] = (ingredientQuantities[foodName]!['quantity'] as double) + servings;
      }
    }

    // Generate unique IDs by appending a counter to the timestamp
    final baseTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
    int counter = 0;
    _stateManager.shoppingList.value = ingredientQuantities.entries.map((entry) {
      final foodName = entry.key;
      final data = entry.value;
      final totalServings = data['quantity'] as double;
      final servingSizeUnit = data['servingSizeUnit'] as String;
      // Look up the food to get the quantity per serving
      final foodEntry = _stateManager.allFoods.firstWhere(
            (f) => f['food'] == foodName,
        orElse: () => _stateManager.foodDatabase.firstWhere(
              (f) => f['food'] == foodName,
          orElse: () => {'food': foodName, 'measurement': 'serving', 'servings': 1.0},
        ),
      );
      final servingsPerUnit = foodEntry['servings'] as double? ?? 1.0;
      final totalQuantity = totalServings * servingsPerUnit; // Scale the quantity by the servings per unit
      final uniqueId = '$baseTimestamp-${counter++}'; // Ensure unique ID
      return ShoppingListItem(
        id: uniqueId,
        name: foodName,
        quantity: totalQuantity,
        checked: false,
        servingSizeUnit: servingSizeUnit,
      );
    }).toList();
    await _shoppingListRepository.saveShoppingList(_stateManager.shoppingList.value);
  }

  void clearShoppingList() async {
    _stateManager.shoppingList.value = [];
    await _shoppingListRepository.clearShoppingList();
  }

  void showAddShoppingItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Add Shopping Item'),
        content: Text('Placeholder for shopping item input form'),
        actions: [],
      ),
    );
  }
}