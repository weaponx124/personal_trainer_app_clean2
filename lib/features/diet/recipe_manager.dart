import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/recipe_repository.dart';
import 'package:personal_trainer_app_clean/features/diet/diet_state_manager.dart';
import 'package:personal_trainer_app_clean/features/diet/fat_secret_service.dart';
import 'package:personal_trainer_app_clean/features/diet/widgets/add_recipe_dialog.dart';

class RecipeManager {
  final RecipeRepository _recipeRepository;
  final DietStateManager _stateManager;
  final FatSecretService _fatSecretService;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  RecipeManager({
    required RecipeRepository recipeRepository,
    required DietStateManager stateManager,
    required FatSecretService fatSecretService,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  })  : _recipeRepository = recipeRepository,
        _stateManager = stateManager,
        _fatSecretService = fatSecretService,
        _scaffoldMessengerKey = scaffoldMessengerKey;

  Future<void> loadRecipes() async {
    try {
      _stateManager.recipes.value = await _recipeRepository.getRecipes();
      print('RecipeManager: Loaded ${_stateManager.recipes.value.length} recipes from repository');
      for (var recipe in _stateManager.recipes.value) {
        print('RecipeManager: Loaded recipe: ${recipe.toJson()}');
      }
    } catch (e) {
      print('RecipeManager: Error loading recipes from repository: $e');
      _stateManager.recipes.value = [];
    }
  }

  void addRecipe(BuildContext context) {
    print('RecipeManager: Opening AddRecipeDialog');
    showDialog(
      context: context,
      builder: (context) => AddRecipeDialog(
        stateManager: _stateManager,
        fatSecretService: _fatSecretService,
        onRecipeAdded: (recipe) async {
          print('RecipeManager: onRecipeAdded called with recipe: ${recipe.toJson()}');
          _stateManager.recipes.value = [..._stateManager.recipes.value, recipe];
          print('RecipeManager: Updated recipes list: ${_stateManager.recipes.value.map((r) => r.toJson()).toList()}');
          await _recipeRepository.insertRecipe(recipe);
          print('RecipeManager: Added recipe: ${recipe.toJson()}');
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('Recipe "${recipe.name}" added successfully!'),
                duration: const Duration(seconds: 2),
              ),
            );
          });
        },
      ),
    );
  }

  void editRecipe(BuildContext context, Recipe recipe) {
    print('RecipeManager: Opening AddRecipeDialog for editing recipe: ${recipe.toJson()}');
    showDialog(
      context: context,
      builder: (context) => AddRecipeDialog(
        stateManager: _stateManager,
        fatSecretService: _fatSecretService,
        onRecipeAdded: (updatedRecipe) async {
          print('RecipeManager: onRecipeAdded called for edit with updatedRecipe: ${updatedRecipe.toJson()}');
          _stateManager.recipes.value = _stateManager.recipes.value.map((r) {
            if (r.id == updatedRecipe.id) {
              return updatedRecipe;
            }
            return r;
          }).toList();
          print('RecipeManager: Updated recipes list: ${_stateManager.recipes.value.map((r) => r.toJson()).toList()}');
          await _recipeRepository.insertRecipe(updatedRecipe);
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('Recipe "${updatedRecipe.name}" updated successfully!'),
                duration: const Duration(seconds: 2),
              ),
            );
          });
        },
        initialRecipe: recipe,
      ),
    );
  }

  void deleteRecipe(String recipeId) async {
    _stateManager.recipes.value = _stateManager.recipes.value.where((recipe) => recipe.id != recipeId).toList();
    await _recipeRepository.deleteRecipe(recipeId);
    print('RecipeManager: Deleted recipe with ID: $recipeId');
  }
}