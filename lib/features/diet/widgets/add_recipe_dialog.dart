import 'package:flutter/material.dart';

class AddRecipeDialog extends StatefulWidget {
  final List<Map<String, dynamic>> allFoods;
  final Function(Map<String, dynamic>) onSave;

  const AddRecipeDialog({super.key, required this.allFoods, required this.onSave});

  @override
  _AddRecipeDialogState createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends State<AddRecipeDialog> {
  final TextEditingController _nameController = TextEditingController();
  final List<Map<String, dynamic>> _ingredients = [];
  String? _selectedFoodId;
  final TextEditingController _servingsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Deduplicate allFoods to ensure no duplicate names
    final Map<String, Map<String, dynamic>> uniqueFoods = {};
    for (var food in widget.allFoods) {
      final name = food['name'] as String;
      if (!uniqueFoods.containsKey(name)) {
        uniqueFoods[name] = food;
      } else {
        print('Warning: Duplicate food name "$name" found in allFoods for AddRecipeDialog. Keeping the first occurrence.');
      }
    }
    final deduplicatedFoods = uniqueFoods.values.toList();

    // Create a list of foods with unique identifiers
    final foodsWithIds = deduplicatedFoods.asMap().entries.map((entry) {
      final index = entry.key;
      final food = entry.value;
      return {
        ...food,
        'uniqueId': 'food:$index:${food['name']}', // Unique identifier for food
      };
    }).toList();

    // Select the first item by its uniqueId, or null if the list is empty
    if (_selectedFoodId == null && foodsWithIds.isNotEmpty) {
      _selectedFoodId = foodsWithIds[0]['uniqueId'] as String;
    }

    return AlertDialog(
      title: const Text('Create Recipe'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFoodId,
                    hint: const Text('Select Ingredient'),
                    isExpanded: true,
                    items: foodsWithIds.map((food) {
                      return DropdownMenuItem<String>(
                        value: food['uniqueId'] as String,
                        child: Text(food['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFoodId = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Servings',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () {
                    if (_selectedFoodId != null && _servingsController.text.isNotEmpty) {
                      final selectedFood = foodsWithIds.firstWhere((food) => food['uniqueId'] == _selectedFoodId);
                      final servings = double.tryParse(_servingsController.text) ?? 0.0;
                      if (servings <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid number of servings')),
                        );
                        return;
                      }
                      setState(() {
                        _ingredients.add({
                          'name': selectedFood['name'],
                          'servings': servings,
                          'calories': (selectedFood['calories'] as num?)?.toDouble() ?? 0.0,
                          'protein': (selectedFood['protein'] as num?)?.toDouble() ?? 0.0,
                          'carbs': (selectedFood['carbs'] as num?)?.toDouble() ?? 0.0,
                          'fat': (selectedFood['fat'] as num?)?.toDouble() ?? 0.0,
                          'sodium': (selectedFood['sodium'] as num?)?.toDouble() ?? 0.0,
                          'fiber': (selectedFood['fiber'] as num?)?.toDouble() ?? 0.0,
                        });
                        _servingsController.clear();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select an ingredient and enter servings')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._ingredients.map((ingredient) {
              return ListTile(
                title: Text(ingredient['name'] as String),
                subtitle: Text('Servings: ${ingredient['servings']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _ingredients.remove(ingredient);
                    });
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && _ingredients.isNotEmpty) {
              double totalCalories = 0.0;
              double totalProtein = 0.0;
              double totalCarbs = 0.0;
              double totalFat = 0.0;
              double totalSodium = 0.0;
              double totalFiber = 0.0;

              for (var ingredient in _ingredients) {
                final servings = ingredient['servings'] as double;
                totalCalories += (ingredient['calories'] as double) * servings;
                totalProtein += (ingredient['protein'] as double) * servings;
                totalCarbs += (ingredient['carbs'] as double) * servings;
                totalFat += (ingredient['fat'] as double) * servings;
                totalSodium += (ingredient['sodium'] as double) * servings;
                totalFiber += (ingredient['fiber'] as double) * servings;
              }

              final recipeDetails = {
                'name': _nameController.text,
                'calories': totalCalories,
                'protein': totalProtein,
                'carbs': totalCarbs,
                'fat': totalFat,
                'sodium': totalSodium,
                'fiber': totalFiber,
                'ingredients': _ingredients,
              };
              widget.onSave(recipeDetails);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a recipe name and add at least one ingredient')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}