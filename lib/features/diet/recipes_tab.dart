import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';
import 'package:personal_trainer_app_clean/main.dart';
import './diet_screen_logic.dart';

class RecipesTab extends StatelessWidget {
  final DietScreenLogic logic;

  const RecipesTab({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Recipe>>(
      valueListenable: logic.recipes,
      builder: (context, recipes, _) {
        return SavedRecipes(
          recipes: recipes,
          onDelete: logic.deleteRecipe,
          onAddRecipe: (context) => logic.addRecipe(context),
          onEditRecipe: (context, recipe) => logic.editRecipe(context, recipe),
        );
      },
    );
  }
}

class SavedRecipes extends StatelessWidget {
  final List<Recipe> recipes;
  final Function(String) onDelete;
  final void Function(BuildContext) onAddRecipe;
  final void Function(BuildContext, Recipe) onEditRecipe;

  const SavedRecipes({
    super.key,
    required this.recipes,
    required this.onDelete,
    required this.onAddRecipe,
    required this.onEditRecipe,
  });

  Future<void> _showRecipeDetails(BuildContext context, Recipe recipe) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          recipe.name,
          style: GoogleFonts.oswald(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nutritional Information',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C2526),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Calories: ${recipe.calories.toStringAsFixed(1)} kcal',
                style: GoogleFonts.roboto(fontSize: 14, color: const Color(0xFF808080)),
              ),
              Text(
                'Protein: ${recipe.protein.toStringAsFixed(1)} g',
                style: GoogleFonts.roboto(fontSize: 14, color: const Color(0xFF808080)),
              ),
              Text(
                'Carbs: ${recipe.carbs.toStringAsFixed(1)} g',
                style: GoogleFonts.roboto(fontSize: 14, color: const Color(0xFF808080)),
              ),
              Text(
                'Fat: ${recipe.fat.toStringAsFixed(1)} g',
                style: GoogleFonts.roboto(fontSize: 14, color: const Color(0xFF808080)),
              ),
              Text(
                'Sodium: ${recipe.sodium.toStringAsFixed(1)} mg',
                style: GoogleFonts.roboto(fontSize: 14, color: const Color(0xFF808080)),
              ),
              Text(
                'Fiber: ${recipe.fiber.toStringAsFixed(1)} g',
                style: GoogleFonts.roboto(fontSize: 14, color: const Color(0xFF808080)),
              ),
              const SizedBox(height: 16),
              Text(
                'Ingredients',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C2526),
                ),
              ),
              const SizedBox(height: 8),
              ...recipe.ingredients.map((ingredient) {
                final servings = ingredient['servings'] as double;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '- ${ingredient['food']} ${ingredient['measurement']}: $servings serving${servings == 1 ? '' : 's'}',
                        style: GoogleFonts.roboto(fontSize: 14, color: const Color(0xFF808080)),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: [
                          Text(
                            '${(ingredient['calories'] * servings).toStringAsFixed(1)} kcal',
                            style: GoogleFonts.roboto(fontSize: 12, color: const Color(0xFF808080)),
                          ),
                          Text(
                            '${(ingredient['protein'] * servings).toStringAsFixed(1)}g protein',
                            style: GoogleFonts.roboto(fontSize: 12, color: const Color(0xFF808080)),
                          ),
                          Text(
                            '${(ingredient['carbs'] * servings).toStringAsFixed(1)}g carbs',
                            style: GoogleFonts.roboto(fontSize: 12, color: const Color(0xFF808080)),
                          ),
                          Text(
                            '${(ingredient['fat'] * servings).toStringAsFixed(1)}g fat',
                            style: GoogleFonts.roboto(fontSize: 12, color: const Color(0xFF808080)),
                          ),
                          Text(
                            '${(ingredient['sodium'] * servings).toStringAsFixed(1)}mg sodium',
                            style: GoogleFonts.roboto(fontSize: 12, color: const Color(0xFF808080)),
                          ),
                          Text(
                            '${(ingredient['fiber'] * servings).toStringAsFixed(1)}g fiber',
                            style: GoogleFonts.roboto(fontSize: 12, color: const Color(0xFF808080)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => onAddRecipe(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Recipe'),
                ),
                const SizedBox(height: 16),
                recipes.isEmpty
                    ? const Center(child: Text('No recipes saved.'))
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          recipe.name,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF1C2526),
                          ),
                        ),
                        subtitle: Wrap(
                          spacing: 8.0,
                          children: [
                            Text(
                              '${recipe.calories.toStringAsFixed(1)} kcal',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: const Color(0xFF808080),
                              ),
                            ),
                            Text(
                              '${recipe.protein.toStringAsFixed(1)}g protein',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: const Color(0xFF808080),
                              ),
                            ),
                            Text(
                              '${recipe.carbs.toStringAsFixed(1)}g carbs',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: const Color(0xFF808080),
                              ),
                            ),
                            Text(
                              '${recipe.fat.toStringAsFixed(1)}g fat',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: const Color(0xFF808080),
                              ),
                            ),
                            Text(
                              '${recipe.sodium.toStringAsFixed(1)}mg sodium',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: const Color(0xFF808080),
                              ),
                            ),
                            Text(
                              '${recipe.fiber.toStringAsFixed(1)}g fiber',
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
                              icon: Icon(Icons.edit, color: accentColor),
                              onPressed: () => onEditRecipe(context, recipe),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: accentColor),
                              onPressed: () => onDelete(recipe.id),
                            ),
                          ],
                        ),
                        onTap: () => _showRecipeDetails(context, recipe),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}