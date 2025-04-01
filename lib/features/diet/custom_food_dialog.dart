import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/custom_food.dart';
import 'package:personal_trainer_app_clean/features/diet/custom_food_manager.dart';

class ManageCustomFoodDialog extends StatelessWidget {
  final CustomFoodManager customFoodManager;
  final List<CustomFood> customFoods;

  const ManageCustomFoodDialog({
    super.key,
    required this.customFoodManager,
    required this.customFoods,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Manage Custom Foods',
        style: TextStyle(color: Color(0xFF1C2526)),
      ),
      content: SizedBox(
        height: 300,
        width: 280,
        child: customFoods.isEmpty
            ? const Center(
          child: Text(
            'No custom foods added yet.',
            style: TextStyle(color: Color(0xFF1C2526)),
          ),
        )
            : ListView.builder(
          itemCount: customFoods.length,
          itemBuilder: (context, index) {
            final food = customFoods[index];
            return Card(
              child: ListTile(
                title: Text(
                  food.name,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: const Color(0xFF1C2526),
                  ),
                ),
                subtitle: Wrap(
                  spacing: 8.0,
                  children: [
                    Text(
                      '${food.calories.toStringAsFixed(1)} kcal',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF808080),
                      ),
                    ),
                    Text(
                      '${food.protein.toStringAsFixed(1)}g protein',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF808080),
                      ),
                    ),
                    Text(
                      '${food.carbs.toStringAsFixed(1)}g carbs',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF808080),
                      ),
                    ),
                    Text(
                      '${food.fat.toStringAsFixed(1)}g fat',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF808080),
                      ),
                    ),
                    Text(
                      '${food.sodium.toStringAsFixed(1)}mg sodium',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF808080),
                      ),
                    ),
                    Text(
                      '${food.fiber.toStringAsFixed(1)}g fiber',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF808080),
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF1C2526)),
                      onPressed: () {
                        Navigator.pop(context);
                        customFoodManager.editCustomFood(context, food);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFF1C2526)),
                      onPressed: () async {
                        await customFoodManager.deleteCustomFood(food.id);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(color: Color(0xFF1C2526)),
          ),
        ),
      ],
    );
  }
}