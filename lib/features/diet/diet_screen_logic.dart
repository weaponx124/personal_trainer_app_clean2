import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';
import 'package:personal_trainer_app_clean/core/data/models/shopping_list_item.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/custom_food_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/meal_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/recipe_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/shopping_list_repository.dart';
import 'package:personal_trainer_app_clean/features/diet/custom_food_manager.dart';
import 'package:personal_trainer_app_clean/features/diet/diet_profile.dart';
import 'package:personal_trainer_app_clean/features/diet/diet_state_manager.dart';
import 'package:personal_trainer_app_clean/features/diet/fat_secret_service.dart';
import 'package:personal_trainer_app_clean/features/diet/meal_manager.dart';
import 'package:personal_trainer_app_clean/features/diet/profile_manager.dart';
import 'package:personal_trainer_app_clean/features/diet/recipe_manager.dart';
import 'package:personal_trainer_app_clean/features/diet/shopping_list_manager.dart';

class DietScreenLogic {
  late TabController _tabController;
  final DietStateManager _stateManager;
  final FatSecretService _fatSecretService;
  final MealManager _mealManager;
  final RecipeManager _recipeManager;
  final ShoppingListManager _shoppingListManager;
  final CustomFoodManager _customFoodManager;
  final ProfileManager _profileManager;
  late ValueNotifier<int> _tabIndexNotifier; // Added ValueNotifier for tab index

  DietScreenLogic({
    required TickerProvider vsync,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    required DietStateManager stateManager,
    CustomFoodRepository? customFoodRepository,
  })  : _stateManager = stateManager,
        _fatSecretService = FatSecretService(),
        _mealManager = MealManager(
          mealRepository: MealRepository(),
          stateManager: stateManager,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
        _recipeManager = RecipeManager(
          recipeRepository: RecipeRepository(),
          stateManager: stateManager,
          fatSecretService: FatSecretService(),
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
        _shoppingListManager = ShoppingListManager(
          shoppingListRepository: ShoppingListRepository(),
          stateManager: stateManager,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
        _customFoodManager = CustomFoodManager(
          customFoodRepository: customFoodRepository ?? CustomFoodRepository(),
          stateManager: stateManager,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
        _profileManager = ProfileManager(stateManager) {
    _tabController = TabController(length: 3, vsync: vsync);
    _tabIndexNotifier = ValueNotifier<int>(0); // Initialize with index 0
    print('DietScreenLogic: Initialized with stateManager meals: ${_stateManager.meals.value.length}');
  }

  TabController get tabController => _tabController;
  DietStateManager get stateManager => _stateManager;

  Future<void> init() async {
    _tabController.addListener(_onTabChanged);
    // Set initial index
    _tabIndexNotifier.value = _tabController.index;
    await _customFoodManager.loadCustomFoods();
    // Removed: await _fatSecretService.fetchFatSecretAccessToken();
    // No need to fetch an access token with OAuth 1.0; the FatSecretService handles authentication internally
    _stateManager.resetData();
    await _mealManager.loadMeals();
    print('DietScreenLogic: After loading meals, stateManager meals: ${_stateManager.meals.value.length}');
    for (var meal in _stateManager.meals.value) {
      print('DietScreenLogic: Loaded meal: ${meal.toJson()}');
    }
    await _recipeManager.loadRecipes();
    await _shoppingListManager.loadShoppingList();
    await _profileManager.loadProfile();
    print('DietScreenLogic: Initialization complete, meals: ${_stateManager.meals.value.length}');
  }

  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _tabIndexNotifier.dispose(); // Dispose of the ValueNotifier
    _stateManager.dispose();
  }

  void _onTabChanged() {
    print('DietScreenLogic: Tab changed to index: ${_tabController.index}');
    _tabIndexNotifier.value = _tabController.index; // Update the ValueNotifier
  }

  void addMeal(BuildContext context) => _mealManager.addMeal(context);

  void addCustomFood(BuildContext context) => _customFoodManager.addCustomFood(context);

  void manageCustomFoods(BuildContext context) => _customFoodManager.manageCustomFoods(context);

  void addRecipe(BuildContext context) => _recipeManager.addRecipe(context);

  void editMeal(BuildContext context, Meal meal) => _mealManager.editMeal(context, meal);

  void editRecipe(BuildContext context, Recipe recipe) => _recipeManager.editRecipe(context, recipe);

  void deleteMeal(String mealId) => _mealManager.deleteMeal(mealId);

  void deleteRecipe(String recipeId) => _recipeManager.deleteRecipe(recipeId);

  void addShoppingItem(ShoppingListItem item) => _shoppingListManager.addShoppingItem(item);

  void toggleShoppingItem(String itemId, bool value) => _shoppingListManager.toggleShoppingItem(itemId, value);

  void generateShoppingList() => _shoppingListManager.generateShoppingList();

  void clearShoppingList() => _shoppingListManager.clearShoppingList();

  void showAddShoppingItemDialog(BuildContext context) => _shoppingListManager.showAddShoppingItemDialog(context);

  void setMealType(String? type) {
    if (type != null && _stateManager.mealNames.value.contains(type)) {
      _stateManager.selectedMealType = type; // Fixed syntax: removed non-breaking space and typo 'W'
    }
  }

  void setSelectedDate(DateTime date) {
    _stateManager.selectedDate = date;
  }

  Future<void> setDietProfile(DietProfile profile, int customCalories) => _profileManager.setDietProfile(profile, customCalories);

  Future<void> setMealNames(List<String> names) => _profileManager.setMealNames(names);

  Widget buildFAB(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _tabIndexNotifier, // Use the ValueNotifier
      builder: (context, index, child) {
        print('DietScreenLogic: Building FAB for tab index: $index');
        switch (index) {
          case 0:
            return FloatingActionButton(
              onPressed: () => _mealManager.showAddMealDialog(context),
              tooltip: 'Add Meal to Log',
              child: const Icon(Icons.restaurant_menu),
            );
          case 1:
            return FloatingActionButton(
              onPressed: () => _recipeManager.addRecipe(context),
              tooltip: 'Add Recipe',
              child: const Icon(Icons.add),
            );
          case 2:
            return FloatingActionButton(
              onPressed: () => showAddShoppingItemDialog(context),
              tooltip: 'Add Shopping Item',
              child: const Icon(Icons.add),
            );
          default:
            return FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.error),
            );
        }
      },
    );
  }

  Future<List<FoodItem>> getFoodMacros(String query) async {
    return [];
  }

  void addFoodToMeal(String foodId, Meal meal) {
    _mealManager.addFoodToMeal(foodId, meal);
  }
}

class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}