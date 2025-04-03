import 'dart:convert';

class ShoppingListItem {
  final String id;
  final String name;
  final double quantity;
  final bool checked;
  final String? servingSizeUnit;
  final double quantityPerServing; // New field for quantity per serving

  ShoppingListItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.checked,
    this.servingSizeUnit,
    this.quantityPerServing = 1.0, // Default to 1 unit per serving
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'checked': checked ? 1 : 0,
      'servingSizeUnit': servingSizeUnit,
      'quantityPerServing': quantityPerServing,
    };
  }

  factory ShoppingListItem.fromMap(Map<String, dynamic> map) {
    return ShoppingListItem(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as double,
      checked: (map['checked'] as int) == 1,
      servingSizeUnit: map['servingSizeUnit'] as String?,
      quantityPerServing: map['quantityPerServing'] as double? ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) => ShoppingListItem.fromMap(json);
}