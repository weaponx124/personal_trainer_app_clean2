import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCustomFoodDialog extends StatelessWidget {
  final Function(Map<String, dynamic>) onSave;

  const AddCustomFoodDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    final TextEditingController proteinController = TextEditingController();
    final TextEditingController carbsController = TextEditingController();
    final TextEditingController fatController = TextEditingController();
    final TextEditingController sodiumController = TextEditingController();
    final TextEditingController fiberController = TextEditingController();

    return AlertDialog(
      title: const Text('Add Custom Food'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories (kcal)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: proteinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Protein (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: carbsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Carbs (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fat (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sodiumController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sodium (mg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fiberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fiber (g)',
                border: OutlineInputBorder(),
              ),
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
            if (nameController.text.isNotEmpty) {
              final customFood = {
                'name': nameController.text,
                'calories': double.tryParse(caloriesController.text) ?? 0.0,
                'protein': double.tryParse(proteinController.text) ?? 0.0,
                'carbs': double.tryParse(carbsController.text) ?? 0.0,
                'fat': double.tryParse(fatController.text) ?? 0.0,
                'sodium': double.tryParse(sodiumController.text) ?? 0.0,
                'fiber': double.tryParse(fiberController.text) ?? 0.0,
                'suitable_for': ['custom'],
              };
              onSave(customFood);
              Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a food name')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}