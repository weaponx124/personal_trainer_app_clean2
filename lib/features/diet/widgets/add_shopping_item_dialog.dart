import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added import
import 'package:personal_trainer_app_clean/core/data/models/shopping_list_item.dart';

class AddShoppingItemDialog extends StatelessWidget {
  final Function(ShoppingListItem) onItemAdded;

  const AddShoppingItemDialog({
    super.key,
    required this.onItemAdded,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final servingSizeUnitController = TextEditingController();
    final quantityPerServingController = TextEditingController(text: '1.0');

    return AlertDialog(
      title: const Text(
        'Add Shopping Item',
        style: TextStyle(color: Color(0xFF1C2526)),
      ),
      content: SizedBox(
        height: 250,
        width: 280,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  labelStyle: TextStyle(color: Color(0xFF1C2526)),
                ),
                style: const TextStyle(color: Color(0xFF1C2526)),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Total Quantity',
                  labelStyle: TextStyle(color: Color(0xFF1C2526)),
                ),
                style: const TextStyle(color: Color(0xFF1C2526)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              ),
              TextField(
                controller: servingSizeUnitController,
                decoration: const InputDecoration(
                  labelText: 'Unit (e.g., oz, cup)',
                  labelStyle: TextStyle(color: Color(0xFF1C2526)),
                ),
                style: const TextStyle(color: Color(0xFF1C2526)),
              ),
              TextField(
                controller: quantityPerServingController,
                decoration: const InputDecoration(
                  labelText: 'Quantity per Unit (e.g., 4 for 4 oz)',
                  labelStyle: TextStyle(color: Color(0xFF1C2526)),
                ),
                style: const TextStyle(color: Color(0xFF1C2526)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF1C2526)),
          ),
        ),
        TextButton(
          onPressed: () {
            final name = nameController.text;
            final quantity = double.tryParse(quantityController.text) ?? 1.0;
            final servingSizeUnit = servingSizeUnitController.text;
            final quantityPerServing = double.tryParse(quantityPerServingController.text) ?? 1.0;
            if (name.isNotEmpty) {
              final item = ShoppingListItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                quantity: quantity,
                checked: false,
                servingSizeUnit: servingSizeUnit.isNotEmpty ? servingSizeUnit : 'serving',
                quantityPerServing: quantityPerServing,
              );
              onItemAdded(item);
              Navigator.pop(context);
            }
          },
          child: const Text(
            'Add',
            style: TextStyle(color: Color(0xFF1C2526)),
          ),
        ),
      ],
    );
  }
}