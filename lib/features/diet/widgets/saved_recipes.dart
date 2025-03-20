import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';

class SavedRecipes extends StatelessWidget {
  final List<Recipe> recipes;
  final Function(String) onDelete;

  const SavedRecipes({
    Key? key,
    required this.recipes,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFB0B7BF),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Recipes',
              style: GoogleFonts.oswald(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB22222),
              ),
            ),
            const SizedBox(height: 8),
            recipes.isEmpty
                ? const Text('No recipes saved yet.')
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return ListTile(
                  title: Text(
                    recipe.name,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF1C2526),
                    ),
                  ),
                  subtitle: Text(
                    '${recipe.calories} kcal, ${recipe.protein}g protein',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: const Color(0xFF808080),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFB22222)),
                    onPressed: () => onDelete(recipe.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}