class ShoppingListItem {
  final String id;
  final String name;
  final double quantity;
  final bool checked;

  ShoppingListItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.checked,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'checked': checked,
    };
  }

  factory ShoppingListItem.fromMap(Map<String, dynamic> map) {
    return ShoppingListItem(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      checked: map['checked'] as bool? ?? false,
    );
  }
}