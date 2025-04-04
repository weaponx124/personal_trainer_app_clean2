import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/theme/app_theme.dart';
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
                  padding: EdgeInsets.all(Theme.of(context).smallPadding),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(Theme.of(context).smallPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.scripture,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: Theme.of(context).mediumSpacing),
                          Text(
                            'Daily Goals (${profile.name})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: Theme.of(context).mediumSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Protein: ${loggedProtein.toStringAsFixed(1)} / ${profile.proteinGrams(calories).toStringAsFixed(1)}g',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    LinearProgressIndicator(
                                      value: proteinProgress.clamp(0.0, 1.0),
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.proteinColor),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: Theme.of(context).mediumSpacing),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Carbs: ${loggedCarbs.toStringAsFixed(1)} / ${profile.carbsGrams(calories).toStringAsFixed(1)}g',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    LinearProgressIndicator(
                                      value: carbsProgress.clamp(0.0, 1.0),
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.carbsColor),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: Theme.of(context).mediumSpacing),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fat: ${loggedFat.toStringAsFixed(1)} / ${profile.fatGrams(calories).toStringAsFixed(1)}g',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    LinearProgressIndicator(
                                      value: fatProgress.clamp(0.0, 1.0),
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.fatColor),
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
                  padding: EdgeInsets.all(Theme.of(context).smallPadding),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: Theme.of(context).mediumSpacing,
                    runSpacing: Theme.of(context).mediumSpacing,
                    children: [
                      ElevatedButton(
                        onPressed: () => widget.logic.addCustomFood(context),
                        child: const Text('Add Custom Food'),
                      ),
                      ElevatedButton(
                        onPressed: () => widget.logic.manageCustomFoods(context),
                        child: const Text('Manage Custom Foods'),
                      ),
                      ElevatedButton(
                        onPressed: () => widget.logic.addRecipe(context),
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