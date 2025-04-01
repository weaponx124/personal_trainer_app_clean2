import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/shopping_list_item.dart';
import './diet_screen_logic.dart';
import './widgets/shopping_list.dart';

class ShoppingTab extends StatelessWidget {
  final DietScreenLogic logic;

  const ShoppingTab({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ShoppingListItem>>(
      valueListenable: logic.stateManager.shoppingList,
      builder: (context, shoppingList, _) {
        return ShoppingList(
          shoppingList: shoppingList,
          onToggle: logic.toggleShoppingItem,
          onGenerate: logic.generateShoppingList,
          onClear: logic.clearShoppingList,
        );
      },
    );
  }
}