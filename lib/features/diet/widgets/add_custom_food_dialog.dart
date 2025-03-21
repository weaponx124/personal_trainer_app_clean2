import 'package:flutter/material.dart';

class AddCustomFoodDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const AddCustomFoodDialog({super.key, required this.onSave});

  @override
  _AddCustomFoodDialogState createState() => _AddCustomFoodDialogState();
}

class _AddCustomFoodDialogState extends State<AddCustomFoodDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _sodiumController = TextEditingController();
  final TextEditingController _fiberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Food'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories (kcal)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _proteinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Protein (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Carbs (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fat (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sodiumController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sodium (mg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fiberController,
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
            try {
              if (_nameController.text.isNotEmpty) {
                final customFood = {
                  'name': _nameController.text,
                  'calories': double.tryParse(_caloriesController.text) ?? 0.0,
                  'protein': double.tryParse(_proteinController.text) ?? 0.0,
                  'carbs': double.tryParse(_carbsController.text) ?? 0.0,
                  'fat': double.tryParse(_fatController.text) ?? 0.0,
                  'sodium': double.tryParse(_sodiumController.text) ?? 0.0,
                  'fiber': double.tryParse(_fiberController.text) ?? 0.0,
                  'suitable_for': ['custom'],
                  'allergies': [],
                };
                widget.onSave(customFood);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a food name')),
                );
              }
            } catch (e, stackTrace) {
              print('Error in AddCustomFoodDialog save: $e');
              print('Stack trace: $stackTrace');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save custom food: $e')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}