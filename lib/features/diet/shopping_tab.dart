import 'package:flutter/material.dart';
import './diet_screen_logic.dart';
import './widgets/shopping_list.dart';

class ShoppingTab extends StatelessWidget {
  final DietScreenLogic logic;

  const ShoppingTab({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return ShoppingList(
      shoppingList: logic.shoppingList,
      onToggle: logic.toggleShoppingItem,
      onGenerate: logic.generateShoppingList,
      onClear: logic.clearShoppingList,
    );
  }
}