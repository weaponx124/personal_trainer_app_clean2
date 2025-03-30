import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/custom_food.dart';
import './diet_screen_logic.dart';

class CustomFoodDialog extends StatefulWidget {
  final DietScreenLogic logic;

  const CustomFoodDialog({super.key, required this.logic});

  @override
  State<CustomFoodDialog> createState() => _CustomFoodDialogState();
}

class _CustomFoodDialogState extends State<CustomFoodDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Custom Foods'),
      content: SizedBox(
        height: 400,
        width: 300,
        child: widget.logic.customFoods.isEmpty
            ? const Center(child: Text('No custom foods added yet.'))
            : ListView.builder(
          itemCount: widget.logic.customFoods.length,
          itemBuilder: (context, index) {
            final customFood = widget.logic.customFoods[index];
            return ListTile(
              title: Text(
                customFood.name,
                style: const TextStyle(color: Color(0xFF1C2526)),
              ),
              subtitle: Wrap(
                spacing: 8.0,
                children: [
                  Text(
                    '${customFood.calories.toStringAsFixed(1)} kcal',
                    style: const TextStyle(color: Color(0xFF808080)),
                  ),
                  Text(
                    '${customFood.protein.toStringAsFixed(1)}g protein',
                    style: const TextStyle(color: Color(0xFF808080)),
                  ),
                  Text(
                    '${customFood.carbs.toStringAsFixed(1)}g carbs',
                    style: const TextStyle(color: Color(0xFF808080)),
                  ),
                  Text(
                    '${customFood.fat.toStringAsFixed(1)}g fat',
                    style: const TextStyle(color: Color(0xFF808080)),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF1C2526)),
                    onPressed: () => _editCustomFood(context, customFood, index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFF1C2526)),
                    onPressed: () => _deleteCustomFood(context, customFood, index),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Color(0xFF1C2526))),
        ),
      ],
    );
  }

  void _editCustomFood(BuildContext context, CustomFood customFood, int index) {
    final nameController = TextEditingController(text: customFood.name);
    final caloriesController = TextEditingController(text: customFood.calories.toString());
    final proteinController = TextEditingController(text: customFood.protein.toString());
    final carbsController = TextEditingController(text: customFood.carbs.toString());
    final fatController = TextEditingController(text: customFood.fat.toString());
    final sodiumController = TextEditingController(text: customFood.sodium.toString());
    final fiberController = TextEditingController(text: customFood.fiber.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Custom Food'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
              ),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carbsController,
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fatController,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sodiumController,
                decoration: const InputDecoration(labelText: 'Sodium (mg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fiberController,
                decoration: const InputDecoration(labelText: 'Fiber (g)'),
                keyboardType: TextInputType.number,
              ),
            ],
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
              final calories = double.tryParse(caloriesController.text) ?? 0.0;
              final protein = double.tryParse(proteinController.text) ?? 0.0;
              final carbs = double.tryParse(carbsController.text) ?? 0.0;
              final fat = double.tryParse(fatController.text) ?? 0.0;
              final sodium = double.tryParse(sodiumController.text) ?? 0.0;
              final fiber = double.tryParse(fiberController.text) ?? 0.0;

              if (name.isNotEmpty) {
                final updatedCustomFood = CustomFood(
                  id: customFood.id,
                  name: name,
                  calories: calories,
                  protein: protein,
                  carbs: carbs,
                  fat: fat,
                  sodium: sodium,
                  fiber: fiber,
                );
                // Update in-memory list
                widget.logic.customFoods[index] = updatedCustomFood;
                // Update database
                await widget.logic.customFoodRepository.updateCustomFood(updatedCustomFood);
                // Update allFoods list
                final allFoodsIndex = widget.logic.allFoods.indexWhere(
                      (food) => food['food'] == customFood.name,
                );
                if (allFoodsIndex != -1) {
                  widget.logic.allFoods[allFoodsIndex] = {
                    'food': updatedCustomFood.name,
                    'measurement': 'Per serving',
                    'calories': updatedCustomFood.calories,
                    'protein': updatedCustomFood.protein,
                    'carbs': updatedCustomFood.carbs,
                    'fat': updatedCustomFood.fat,
                    'sodium': updatedCustomFood.sodium,
                    'fiber': updatedCustomFood.fiber,
                    'servings': 1.0,
                    'isRecipe': false,
                  };
                }
                Navigator.pop(context);
                setState(() {}); // Refresh the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Custom food "${updatedCustomFood.name}" updated successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a food name')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomFood(BuildContext context, CustomFood customFood, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Custom Food'),
        content: Text('Are you sure you want to delete "${customFood.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Remove from in-memory list
              widget.logic.customFoods.removeAt(index);
              // Remove from database
              await widget.logic.customFoodRepository.deleteCustomFood(customFood.id);
              // Remove from allFoods list
              widget.logic.allFoods.removeWhere((food) => food['food'] == customFood.name);
              Navigator.pop(context);
              setState(() {}); // Refresh the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Custom food "${customFood.name}" deleted successfully!')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}