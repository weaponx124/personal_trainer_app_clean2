import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/custom_food.dart';

class CustomFoodList extends StatelessWidget {
  final List<CustomFood> customFoods;
  final Function(CustomFood) onFoodSelected;

  const CustomFoodList({
    super.key,
    required this.customFoods,
    required this.onFoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 280,
      child: ListView.builder(
        itemCount: customFoods.length,
        itemBuilder: (context, index) {
          final food = customFoods[index];
          return ListTile(
            title: Text(
              food.name,
              style: const TextStyle(color: Color(0xFF1C2526)),
            ),
            subtitle: Text(
              'Calories: ${food.calories}',
              style: const TextStyle(color: Color(0xFF808080)),
            ),
            onTap: () => onFoodSelected(food),
          );
        },
      ),
    );
  }
}