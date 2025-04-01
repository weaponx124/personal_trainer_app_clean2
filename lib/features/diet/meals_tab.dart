import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './diet_screen_logic.dart';
import './diet_profile.dart';
import '../../core/data/models/meal.dart';
import './widgets/meal_log.dart';

class MealsTab extends StatefulWidget {
  final DietScreenLogic logic;

  const MealsTab({super.key, required this.logic});

  @override
  State<MealsTab> createState() => _MealsTabState();
}

class _MealsTabState extends State<MealsTab> {
  String _selectedMealType = 'Breakfast';

  @override
  void initState() {
    super.initState();
    // Initialize _selectedMealType based on the first meal name
    if (widget.logic.stateManager.mealNames.value.isNotEmpty) {
      _selectedMealType = widget.logic.stateManager.mealNames.value[0];
      widget.logic.setMealType(_selectedMealType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DietProfile>(
      valueListenable: widget.logic.stateManager.dietProfile,
      builder: (context, profile, _) {
        return ValueListenableBuilder<List<Meal>>(
          valueListenable: widget.logic.stateManager.meals,
          builder: (context, meals, _) {
            final calories = widget.logic.stateManager.getEffectiveCalories();
            final loggedProtein = widget.logic.stateManager.getLoggedProtein();
            final loggedCarbs = widget.logic.stateManager.getLoggedCarbs();
            final loggedFat = widget.logic.stateManager.getLoggedFat();
            final proteinProgress = loggedProtein / profile.proteinGrams(calories);
            final carbsProgress = loggedCarbs / profile.carbsGrams(calories);
            final fatProgress = loggedFat / profile.fatGrams(calories);

            print('MealsTab: Logged protein: $loggedProtein / ${profile.proteinGrams(calories)} = $proteinProgress');
            print('MealsTab: Logged carbs: $loggedCarbs / ${profile.carbsGrams(calories)} = $carbsProgress');
            print('MealsTab: Logged fat: $loggedFat / ${profile.fatGrams(calories)} = $fatProgress');

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.scripture,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF1C2526),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Daily Goals (${profile.name})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Protein: ${loggedProtein.toStringAsFixed(1)} / ${profile.proteinGrams(calories).toStringAsFixed(1)}g',
                                      style: const TextStyle(color: Color(0xFF1C2526)),
                                    ),
                                    LinearProgressIndicator(
                                      value: proteinProgress.clamp(0.0, 1.0),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Carbs: ${loggedCarbs.toStringAsFixed(1)} / ${profile.carbsGrams(calories).toStringAsFixed(1)}g',
                                      style: const TextStyle(color: Color(0xFF1C2526)),
                                    ),
                                    LinearProgressIndicator(
                                      value: carbsProgress.clamp(0.0, 1.0),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fat: ${loggedFat.toStringAsFixed(1)} / ${profile.fatGrams(calories).toStringAsFixed(1)}g',
                                      style: const TextStyle(color: Color(0xFF1C2526)),
                                    ),
                                    LinearProgressIndicator(
                                      value: fatProgress.clamp(0.0, 1.0),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ElevatedButton(
                        onPressed: () => widget.logic.addCustomFood(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add Custom Food'),
                      ),
                      ElevatedButton(
                        onPressed: () => widget.logic.manageCustomFoods(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Manage Custom Foods'),
                      ),
                      ElevatedButton(
                        onPressed: () => widget.logic.addRecipe(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Create Recipe'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: MealLog(
                    onAddCustomFood: () => widget.logic.addCustomFood(context),
                    onAddRecipe: () => widget.logic.addRecipe(context),
                    onAddMeal: () => widget.logic.addMeal(context),
                    onEdit: (meal) => widget.logic.editMeal(context, meal),
                    onDelete: (mealId) => widget.logic.deleteMeal(mealId),
                    selectedMealType: _selectedMealType,
                    onMealTypeChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMealType = value;
                        });
                        widget.logic.setMealType(value);
                      }
                    },
                    selectedDate: widget.logic.stateManager.selectedDate,
                    logic: widget.logic,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}