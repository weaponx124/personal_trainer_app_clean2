import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/shopping_list_item.dart';

class ShoppingListRepository {
  static const String _shoppingListKey = 'shoppingList';

  Future<List<ShoppingListItem>> getShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    final shoppingListJson = prefs.getString(_shoppingListKey);
    if (shoppingListJson == null) return [];
    final shoppingList = jsonDecode(shoppingListJson) as List<dynamic>;
    return shoppingList.map((item) {
      if (item == null) return null;
      return ShoppingListItem.fromMap(item as Map<String, dynamic>);
    }).whereType<ShoppingListItem>().toList();
  }

  Future<void> saveShoppingList(List<ShoppingListItem> shoppingList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shoppingListKey, jsonEncode(shoppingList.map((item) => item.toMap()).toList()));
    print('Saved shopping list: ${shoppingList.map((item) => item.toMap()).toList()}');
  }

  Future<void> clearShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shoppingListKey, jsonEncode([]));
    print('Cleared shopping list');
  }
}