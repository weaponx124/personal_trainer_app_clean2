import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_trainer_app_clean/core/data/models/custom_food.dart';

class AddCustomFoodDialog extends StatelessWidget {
  final Function(Map<String, dynamic>) onSave;
  final CustomFood? initialCustomFood;

  const AddCustomFoodDialog({
    super.key,
    required this.onSave,
    this.initialCustomFood,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: initialCustomFood?.name ?? '');
    final caloriesController = TextEditingController(text: initialCustomFood != null ? initialCustomFood!.calories.toString() : '');
    final proteinController = TextEditingController(text: initialCustomFood != null ? initialCustomFood!.protein.toString() : '');
    final carbsController = TextEditingController(text: initialCustomFood != null ? initialCustomFood!.carbs.toString() : '');
    final fatController = TextEditingController(text: initialCustomFood != null ? initialCustomFood!.fat.toString() : '');
    final sodiumController = TextEditingController(text: initialCustomFood != null ? initialCustomFood!.sodium.toString() : '');
    final fiberController = TextEditingController(text: initialCustomFood != null ? initialCustomFood!.fiber.toString() : '');
    final servingSizeUnitController = TextEditingController(text: initialCustomFood?.servingSizeUnit ?? '');

    return AlertDialog(
      title: Text(
        initialCustomFood != null ? 'Edit Custom Food' : 'Add Custom Food',
        style: const TextStyle(color: Color(0xFF1C2526)),
      ),
      content: SizedBox(
        height: 450, // Increased height to accommodate new field
        width: 280,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
              ),
              TextField(
                controller: servingSizeUnitController,
                decoration: const InputDecoration(labelText: 'Serving Size Unit (e.g., 4 oz)'),
              ),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: carbsController,
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: fatController,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: sodiumController,
                decoration: const InputDecoration(labelText: 'Sodium (mg)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: fiberController,
                decoration: const InputDecoration(labelText: 'Fiber (g)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF1C2526)),
          ),
        ),
        TextButton(
          onPressed: () {
            final customFoodMap = {
              'name': nameController.text,
              'calories': double.tryParse(caloriesController.text) ?? 0.0,
              'protein': double.tryParse(proteinController.text) ?? 0.0,
              'carbs': double.tryParse(carbsController.text) ?? 0.0,
              'fat': double.tryParse(fatController.text) ?? 0.0,
              'sodium': double.tryParse(sodiumController.text) ?? 0.0,
              'fiber': double.tryParse(fiberController.text) ?? 0.0,
              'servingSizeUnit': servingSizeUnitController.text.isNotEmpty ? servingSizeUnitController.text : 'serving',
            };
            onSave(customFoodMap);
          },
          child: const Text(
            'Save',
            style: TextStyle(color: Color(0xFF1C2526)),
          ),
        ),
      ],
    );
  }
}