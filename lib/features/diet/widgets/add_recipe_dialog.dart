import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddRecipeDialog extends StatelessWidget {
  final List<Map<String, dynamic>> allFoods;
  final Function(Map<String, dynamic>) onSave;

  const AddRecipeDialog({
    Key? key,
    required this.allFoods,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    List<Map<String, dynamic>> ingredients = [];

    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Create Recipe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ...ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${ingredient['name']} (${ingredient['servings']} servings)',
                        style: GoogleFonts.roboto(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setDialogState(() {
                          ingredients.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  String? selectedFood = allFoods.isNotEmpty ? allFoods[0]['name'] as String : null;
                  final TextEditingController servingsController = TextEditingController();

                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setInnerDialogState) => AlertDialog(
                        title: const Text('Add Ingredient'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButton<String>(
                              value: selectedFood,
                              hint: const Text('Select Food'),
                              isExpanded: true,
                              items: allFoods.map((food) {
                                return DropdownMenuItem<String>(
                                  value: food['name'] as String,
                                  child: Text(food['name'] as String),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setInnerDialogState(() {
                                  selectedFood = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: servingsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Servings',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (selectedFood != null && servingsController.text.isNotEmpty) {
                                Navigator.pop(context, true);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a food and enter servings')),
                                );
                              }
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (result == true) {
                    final servings = double.tryParse(servingsController.text) ?? 1.0;
                    final food = allFoods.firstWhere((f) => f['name'] == selectedFood);
                    setDialogState(() {
                      ingredients.add({
                        'name': food['name'],
                        'servings': servings,
                        'calories': ((food['calories'] as num?)?.toDouble() ?? 0.0) * servings,
                        'protein': ((food['protein'] as num?)?.toDouble() ?? 0.0) * servings,
                        'carbs': ((food['carbs'] as num?)?.toDouble() ?? 0.0) * servings,
                        'fat': ((food['fat'] as num?)?.toDouble() ?? 0.0) * servings,
                        'sodium': ((food['sodium'] as num?)?.toDouble() ?? 0.0) * servings,
                        'fiber': ((food['fiber'] as num?)?.toDouble() ?? 0.0) * servings,
                      });
                    });
                  }
                },
                child: const Text('Add Ingredient'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && ingredients.isNotEmpty) {
                // Calculate total nutritional values
                double totalCalories = 0.0;
                double totalProtein = 0.0;
                double totalCarbs = 0.0;
                double totalFat = 0.0;
                double totalSodium = 0.0;
                double totalFiber = 0.0;

                for (var ingredient in ingredients) {
                  totalCalories += ingredient['calories'] as double;
                  totalProtein += ingredient['protein'] as double;
                  totalCarbs += ingredient['carbs'] as double;
                  totalFat += ingredient['fat'] as double;
                  totalSodium += ingredient['sodium'] as double;
                  totalFiber += ingredient['fiber'] as double;
                }

                final recipe = {
                  'name': nameController.text,
                  'ingredients': ingredients,
                  'calories': totalCalories,
                  'protein': totalProtein,
                  'carbs': totalCarbs,
                  'fat': totalFat,
                  'sodium': totalSodium,
                  'fiber': totalFiber,
                  'suitable_for': ['recipe'],
                };
                onSave(recipe);
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a recipe name and add at least one ingredient')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}