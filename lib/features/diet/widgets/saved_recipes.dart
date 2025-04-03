import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';
import 'package:personal_trainer_app_clean/main.dart';

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
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nutritional Information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Calories: ${recipe.calories.toStringAsFixed(1)} kcal',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                'Protein: ${recipe.protein.toStringAsFixed(1)} g',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                'Carbs: ${recipe.carbs.toStringAsFixed(1)} g',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                'Fat: ${recipe.fat.toStringAsFixed(1)} g',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                'Sodium: ${recipe.sodium.toStringAsFixed(1)} mg',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                'Fiber: ${recipe.fiber.toStringAsFixed(1)} g',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleMedium,
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
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: [
                          Text(
                            '${(ingredient['calories'] * servings).toStringAsFixed(1)} kcal',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
                          ),
                          Text(
                            '${(ingredient['protein'] * servings).toStringAsFixed(1)}g protein',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
                          ),
                          Text(
                            '${(ingredient['carbs'] * servings).toStringAsFixed(1)}g carbs',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
                          ),
                          Text(
                            '${(ingredient['fat'] * servings).toStringAsFixed(1)}g fat',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
                          ),
                          Text(
                            '${(ingredient['sodium'] * servings).toStringAsFixed(1)}mg sodium',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
                          ),
                          Text(
                            '${(ingredient['fiber'] * servings).toStringAsFixed(1)}g fiber',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
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
                  child: const Text('Add Recipe'),
                ),
                const SizedBox(height: 16),
                recipes.isEmpty
                    ? Center(child: Text('No recipes saved.', style: Theme.of(context).textTheme.bodyMedium))
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: Wrap(
                          spacing: 8.0,
                          children: [
                            Text(
                              '${recipe.calories.toStringAsFixed(1)} kcal',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${recipe.protein.toStringAsFixed(1)}g protein',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${recipe.carbs.toStringAsFixed(1)}g carbs',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${recipe.fat.toStringAsFixed(1)}g fat',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${recipe.sodium.toStringAsFixed(1)}mg sodium',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${recipe.fiber.toStringAsFixed(1)}g fiber',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => onEditRecipe(context, recipe),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
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