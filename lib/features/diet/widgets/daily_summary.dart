import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/core/theme/app_theme.dart';

class DailySummary extends StatelessWidget {
  final double dailyCalories;
  final double calorieGoal;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFat;
  final double dailyWater;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final double waterGoal;
  final DateTime selectedDate;
  final VoidCallback onAddWater;

  const DailySummary({
    super.key,
    required this.dailyCalories,
    required this.calorieGoal,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
    required this.dailyWater,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.waterGoal,
    required this.selectedDate,
    required this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(Theme.of(context).mediumPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Calories
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(Theme.of(context).mediumPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calories',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: Theme.of(context).mediumSpacing),
                        LinearProgressIndicator(
                          value: dailyCalories / calorieGoal,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                        ),
                        SizedBox(height: Theme.of(context).mediumSpacing),
                        Text(
                          '${dailyCalories.toStringAsFixed(1)} / ${calorieGoal.toStringAsFixed(1)} kcal',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Theme.of(context).largeSpacing),
                // Macros
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(Theme.of(context).mediumPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Macros',
                          style: Theme.of(context).textTheme.headlineMedium,
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
                                    'Protein',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  SizedBox(height: Theme.of(context).smallSpacing),
                                  LinearProgressIndicator(
                                    value: dailyProtein / proteinGoal,
                                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.proteinColor),
                                  ),
                                  SizedBox(height: Theme.of(context).smallSpacing),
                                  Text(
                                    '${dailyProtein.toStringAsFixed(1)} / ${proteinGoal.toStringAsFixed(1)} g',
                                    style: Theme.of(context).textTheme.bodySmall,
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
                                    'Carbs',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  SizedBox(height: Theme.of(context).smallSpacing),
                                  LinearProgressIndicator(
                                    value: dailyCarbs / carbsGoal,
                                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.carbsColor),
                                  ),
                                  SizedBox(height: Theme.of(context).smallSpacing),
                                  Text(
                                    '${dailyCarbs.toStringAsFixed(1)} / ${carbsGoal.toStringAsFixed(1)} g',
                                    style: Theme.of(context).textTheme.bodySmall,
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
                                    'Fat',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  SizedBox(height: Theme.of(context).smallSpacing),
                                  LinearProgressIndicator(
                                    value: dailyFat / fatGoal,
                                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.fatColor),
                                  ),
                                  SizedBox(height: Theme.of(context).smallSpacing),
                                  Text(
                                    '${dailyFat.toStringAsFixed(1)} / ${fatGoal.toStringAsFixed(1)} g',
                                    style: Theme.of(context).textTheme.bodySmall,
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
                SizedBox(height: Theme.of(context).largeSpacing),
                // Water Intake
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(Theme.of(context).mediumPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Water Intake',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: Theme.of(context).mediumSpacing),
                        LinearProgressIndicator(
                          value: dailyWater / waterGoal,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                        ),
                        SizedBox(height: Theme.of(context).mediumSpacing),
                        Text(
                          '${dailyWater.toStringAsFixed(1)} / ${waterGoal.toStringAsFixed(1)} oz',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: Theme.of(context).largeSpacing),
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.local_drink),
                            label: const Text('Add Water'),
                            onPressed: onAddWater,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}