import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';
import '../diet_state_manager.dart';
import '../fat_secret_service.dart';

class AddRecipeDialog extends StatefulWidget {
  final DietStateManager stateManager;
  final FatSecretService fatSecretService;
  final Function(Recipe) onRecipeAdded;
  final Recipe? initialRecipe;

  const AddRecipeDialog({
    super.key,
    required this.stateManager,
    required this.fatSecretService,
    required this.onRecipeAdded,
    this.initialRecipe,
  });

  @override
  State<AddRecipeDialog> createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends State<AddRecipeDialog> {
  final nameController = TextEditingController();
  final servingSizeUnitController = TextEditingController(); // New field for serving size unit
  final List<Map<String, dynamic>> ingredients = [];
  String searchQuery = '';
  List<Map<String, dynamic>> filteredFoods = [];

  double totalCalories = 0.0;
  double totalProtein = 0.0;
  double totalCarbs = 0.0;
  double totalFat = 0.0;
  double totalSodium = 0.0;
  double totalFiber = 0.0;

  @override
  void initState() {
    super.initState();
    filteredFoods = widget.stateManager.allFoods;
    if (widget.initialRecipe != null) {
      nameController.text = widget.initialRecipe!.name;
      servingSizeUnitController.text = widget.initialRecipe!.servingSizeUnit ?? '';
      ingredients.addAll(widget.initialRecipe!.ingredients);
      totalCalories = widget.initialRecipe!.calories;
      totalProtein = widget.initialRecipe!.protein;
      totalCarbs = widget.initialRecipe!.carbs;
      totalFat = widget.initialRecipe!.fat;
      totalSodium = widget.initialRecipe!.sodium;
      totalFiber = widget.initialRecipe!.fiber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialRecipe != null ? 'Edit Recipe' : 'Add Recipe'),
      content: SizedBox(
        height: 450,
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Recipe Name'),
              ),
              TextField(
                controller: servingSizeUnitController,
                decoration: const InputDecoration(labelText: 'Serving Size Unit (e.g., 1 bowl)'),
              ),
              const SizedBox(height: 16),
              const Text('Add Ingredient from Food Database'),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Food',
                  labelStyle: TextStyle(color: Color(0xFF1C2526)),
                ),
                style: const TextStyle(color: Color(0xFF1C2526)),
                onChanged: (value) async {
                  searchQuery = value;
                  List<Map<String, dynamic>> apiFoods = [];
                  if (value.isNotEmpty) {
                    apiFoods = await widget.fatSecretService.fetchFoods(value);
                  }
                  setState(() {
                    filteredFoods = widget.stateManager.allFoods
                        .where((food) => food['food']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                        .toList();
                    filteredFoods.addAll(apiFoods);
                  });
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: filteredFoods.length,
                  itemBuilder: (context, index) {
                    final food = filteredFoods[index];
                    return ListTile(
                      title: Text(
                        '${food['food']} ${food['measurement']}',
                        style: const TextStyle(color: Color(0xFF1C2526)),
                      ),
                      subtitle: Wrap(
                        spacing: 8.0,
                        children: [
                          Text(
                            '${food['calories'].toStringAsFixed(1)} kcal',
                            style: const TextStyle(color: Color(0xFF808080)),
                          ),
                          Text(
                            '${food['protein'].toStringAsFixed(1)}g protein',
                            style: const TextStyle(color: Color(0xFF808080)),
                          ),
                          Text(
                            '${food['carbs'].toStringAsFixed(1)}g carbs',
                            style: const TextStyle(color: Color(0xFF808080)),
                          ),
                          Text(
                            '${food['fat'].toStringAsFixed(1)}g fat',
                            style: const TextStyle(color: Color(0xFF808080)),
                          ),
                          Text(
                            '${food['sodium'].toStringAsFixed(1)}mg sodium',
                            style: const TextStyle(color: Color(0xFF808080)),
                          ),
                          Text(
                            '${food['fiber'].toStringAsFixed(1)}g fiber',
                            style: const TextStyle(color: Color(0xFF808080)),
                          ),
                        ],
                      ),
                      onTap: () async {
                        final servingsController = TextEditingController();
                        final result = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Add ${food['food']}'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: servingsController,
                                  decoration: const InputDecoration(labelText: 'Servings'),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final servings = double.tryParse(servingsController.text) ?? 1.0;
                                  Navigator.pop(context, {
                                    'food': food['food'],
                                    'measurement': food['measurement'],
                                    'calories': food['calories'],
                                    'protein': food['protein'],
                                    'carbs': food['carbs'],
                                    'fat': food['fat'],
                                    'sodium': food['sodium'],
                                    'fiber': food['fiber'],
                                    'servings': servings,
                                  });
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            ingredients.add(result);
                            totalCalories += result['calories'] * result['servings'];
                            totalProtein += result['protein'] * result['servings'];
                            totalCarbs += result['carbs'] * result['servings'];
                            totalFat += result['fat'] * result['servings'];
                            totalSodium += result['sodium'] * result['servings'];
                            totalFiber += result['fiber'] * result['servings'];
                          });
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text('Ingredients Added:'),
              ...ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        '- ${ingredient['food']} ${ingredient['measurement']}: ${ingredient['servings']} servings',
                        style: const TextStyle(color: Color(0xFF808080)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFF808080)),
                      onPressed: () {
                        setState(() {
                          final removedIngredient = ingredients.removeAt(index);
                          totalCalories -= removedIngredient['calories'] * removedIngredient['servings'];
                          totalProtein -= removedIngredient['protein'] * removedIngredient['servings'];
                          totalCarbs -= removedIngredient['carbs'] * removedIngredient['servings'];
                          totalFat -= removedIngredient['fat'] * removedIngredient['servings'];
                          totalSodium -= removedIngredient['sodium'] * removedIngredient['servings'];
                          totalFiber -= removedIngredient['fiber'] * removedIngredient['servings'];
                        });
                      },
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              Text('Total Calories: ${totalCalories.toStringAsFixed(1)} kcal'),
              Text('Total Protein: ${totalProtein.toStringAsFixed(1)} g'),
              Text('Total Carbs: ${totalCarbs.toStringAsFixed(1)} g'),
              Text('Total Fat: ${totalFat.toStringAsFixed(1)} g'),
              Text('Total Sodium: ${totalSodium.toStringAsFixed(1)} mg'),
              Text('Total Fiber: ${totalFiber.toStringAsFixed(1)} g'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final name = nameController.text;
            if (name.isNotEmpty && ingredients.isNotEmpty) {
              final recipe = Recipe(
                id: widget.initialRecipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                calories: totalCalories,
                protein: totalProtein,
                carbs: totalCarbs,
                fat: totalFat,
                sodium: totalSodium,
                fiber: totalFiber,
                ingredients: ingredients,
                servingSizeUnit: servingSizeUnitController.text.isNotEmpty ? servingSizeUnitController.text : 'serving',
              );
              widget.onRecipeAdded(recipe);
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a recipe name and add at least one ingredient')),
                );
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}