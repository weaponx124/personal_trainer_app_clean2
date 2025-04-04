import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';
import 'package:personal_trainer_app_clean/features/diet/diet_state_manager.dart';
import 'package:personal_trainer_app_clean/features/diet/fat_secret_service.dart';

class AddMealDialog extends StatefulWidget {
  final DietStateManager stateManager;
  final Function(Meal) onMealAdded;
  final Meal? initialMeal;

  const AddMealDialog({
    super.key,
    required this.stateManager,
    required this.onMealAdded,
    this.initialMeal,
  });

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  String _selectedMealType = '';
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredItems = [];
  Map<String, dynamic>? _selectedItem;
  double _servings = 1.0;
  final FatSecretService _fatSecretService = FatSecretService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize with local recipes only (we'll fetch foods from FatSecret on search)
    _filteredItems = _combineLocalRecipes();
    if (widget.stateManager.mealNames.value.isNotEmpty) {
      _selectedMealType = widget.stateManager.mealNames.value[0];
    }
    if (widget.initialMeal != null) {
      _selectedMealType = widget.initialMeal!.mealType;
      _servings = widget.initialMeal!.servings;
      if (widget.initialMeal!.isRecipe) {
        // Find the recipe in recipes
        final recipe = widget.stateManager.recipes.value.firstWhere(
              (r) => r.id == widget.initialMeal!.food,
          orElse: () => Recipe(
            id: widget.initialMeal!.food,
            name: widget.initialMeal!.food,
            calories: widget.initialMeal!.calories,
            protein: widget.initialMeal!.protein,
            carbs: widget.initialMeal!.carbs,
            fat: widget.initialMeal!.fat,
            sodium: widget.initialMeal!.sodium,
            fiber: widget.initialMeal!.fiber,
            ingredients: widget.initialMeal!.ingredients ?? [],
            quantityPerServing: 1.0,
          ),
        );
        _selectedItem = {
          'food': recipe.id,
          'name': recipe.name,
          'measurement': recipe.servingSizeUnit ?? 'serving',
          'quantityPerServing': recipe.quantityPerServing,
          'calories': recipe.calories,
          'protein': recipe.protein,
          'carbs': recipe.carbs,
          'fat': recipe.fat,
          'sodium': recipe.sodium,
          'fiber': recipe.fiber,
          'servings': 1.0,
          'isRecipe': true,
          'ingredients': recipe.ingredients,
        };
      } else {
        // Find the food in allFoods
        _selectedItem = widget.stateManager.allFoods.firstWhere(
              (food) => food['food'] == widget.initialMeal!.food,
          orElse: () => {
            'food': widget.initialMeal!.food,
            'measurement': 'serving',
            'quantityPerServing': 1.0,
            'calories': widget.initialMeal!.calories,
            'protein': widget.initialMeal!.protein,
            'carbs': widget.initialMeal!.carbs,
            'fat': widget.initialMeal!.fat,
            'sodium': widget.initialMeal!.sodium,
            'fiber': widget.initialMeal!.fiber,
            'servings': 1.0,
            'isRecipe': widget.initialMeal!.isRecipe,
          },
        );
      }
    }
  }

  List<Map<String, dynamic>> _combineLocalRecipes() {
    print('AddMealDialog: Combining local recipes...');
    print('AddMealDialog: recipes: ${widget.stateManager.recipes.value}');
    final List<Map<String, dynamic>> combinedItems = [];
    // Add recipes from stateManager.recipes
    for (var recipe in widget.stateManager.recipes.value) {
      combinedItems.add({
        'food': recipe.id, // Use the recipe ID as the identifier
        'name': recipe.name, // Display the recipe name
        'measurement': recipe.servingSizeUnit ?? 'serving',
        'quantityPerServing': recipe.quantityPerServing,
        'calories': recipe.calories,
        'protein': recipe.protein,
        'carbs': recipe.carbs,
        'fat': recipe.fat,
        'sodium': recipe.sodium,
        'fiber': recipe.fiber,
        'servings': 1.0,
        'isRecipe': true,
        'ingredients': recipe.ingredients,
      });
    }
    print('AddMealDialog: Combined local recipes: $combinedItems');
    return combinedItems;
  }

  void _searchFoods(String query) async {
    print('AddMealDialog: Search triggered with query: $query');
    if (query.isEmpty) {
      print('AddMealDialog: Query is empty, resetting to local recipes');
      setState(() {
        _filteredItems = _combineLocalRecipes();
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('AddMealDialog: Calling FatSecretService.fetchFoods...');
      final results = await _fatSecretService.fetchFoods(query);
      print('AddMealDialog: FatSecret search results: $results');
      setState(() {
        // Combine local recipes with FatSecret results
        _filteredItems = [
          ..._combineLocalRecipes(),
          ...results,
        ];
        // Filter combined items based on the query
        _filteredItems = _filteredItems
            .where((item) => (item['isRecipe'] ? item['name'] : item['food'])
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
            .toList();
        print('AddMealDialog: Filtered items after search: $_filteredItems');
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('AddMealDialog: Error in _searchFoods: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _filteredItems = _combineLocalRecipes();
        _isLoading = false;
        _errorMessage = 'Failed to fetch foods. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialMeal != null ? 'Edit Meal' : 'Add Meal',
        style: const TextStyle(color: Color(0xFF1C2526)),
      ),
      content: SizedBox(
        height: 500,
        width: 350,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _selectedMealType,
                isExpanded: true,
                items: widget.stateManager.mealNames.value.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMealType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Food or Recipe',
                  labelStyle: TextStyle(color: Color(0xFF1C2526)),
                ),
                style: const TextStyle(color: Color(0xFF1C2526)),
                onChanged: (value) {
                  print('AddMealDialog: TextField onChanged triggered with value: $value');
                  setState(() {
                    _searchQuery = value;
                  });
                  _searchFoods(value);
                },
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage != null)
                Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              else
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = _selectedItem == item;
                      final displayName = item['isRecipe'] ? item['name'] : item['food'];
                      return Card(
                        color: isSelected ? Colors.grey[300] : Colors.white,
                        child: ListTile(
                          title: Text(
                            '$displayName ${item['measurement']}',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          subtitle: Wrap(
                            spacing: 8.0,
                            children: [
                              Text(
                                '${item['calories'].toStringAsFixed(1)} kcal',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                              Text(
                                '${item['protein'].toStringAsFixed(1)}g protein',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                              Text(
                                '${item['carbs'].toStringAsFixed(1)}g carbs',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                              Text(
                                '${item['fat'].toStringAsFixed(1)}g fat',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                              Text(
                                '${item['sodium'].toStringAsFixed(1)}mg sodium',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                              Text(
                                '${item['fiber'].toStringAsFixed(1)}g fiber',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectedItem = item;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Servings',
                  labelStyle: TextStyle(color: Color(0xFF1C2526)),
                ),
                style: const TextStyle(color: Color(0xFF1C2526)),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _servings = double.tryParse(value) ?? 1.0;
                },
                controller: TextEditingController(text: _servings.toString()),
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
            if (_selectedItem != null) {
              final meal = Meal(
                id: widget.initialMeal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                food: _selectedItem!['food'] as String,
                mealType: _selectedMealType,
                calories: _selectedItem!['calories'] as double,
                protein: _selectedItem!['protein'] as double,
                carbs: _selectedItem!['carbs'] as double,
                fat: _selectedItem!['fat'] as double,
                sodium: _selectedItem!['sodium'] as double,
                fiber: _selectedItem!['fiber'] as double,
                timestamp: widget.initialMeal?.timestamp ??
                    DateTime(
                      widget.stateManager.selectedDate.year,
                      widget.stateManager.selectedDate.month,
                      widget.stateManager.selectedDate.day,
                    ).millisecondsSinceEpoch,
                servings: _servings,
                isRecipe: _selectedItem!['isRecipe'] as bool,
                ingredients: _selectedItem!['isRecipe']
                    ? (_selectedItem!['ingredients'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? []
                    : [],
                servingSizeUnit: widget.initialMeal?.servingSizeUnit,
              );
              widget.onMealAdded(meal);
            }
          },
          child: const Text(
            'Add',
            style: TextStyle(color: Color(0xFF1C2526)),
          ),
        ),
      ],
    );
  }
}