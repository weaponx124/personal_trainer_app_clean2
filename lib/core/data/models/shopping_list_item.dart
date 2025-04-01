import 'dart:convert';

class ShoppingListItem {
  final String id;
  final String name;
  final double quantity;
  final bool checked;
  final String? servingSizeUnit; // New field for serving size unit

  ShoppingListItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.checked,
    this.servingSizeUnit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'checked': checked ? 1 : 0,
      'servingSizeUnit': servingSizeUnit,
    };
  }

  factory ShoppingListItem.fromMap(Map<String, dynamic> map) {
    return ShoppingListItem(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as double,
      checked: (map['checked'] as int) == 1,
      servingSizeUnit: map['servingSizeUnit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) => ShoppingListItem.fromMap(json);
}