import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/shopping_list_item.dart';
import 'package:personal_trainer_app_clean/main.dart';

class ShoppingList extends StatelessWidget {
  final List<ShoppingListItem> shoppingList;
  final Function(String, bool) onToggle;
  final VoidCallback onGenerate;
  final VoidCallback onClear;

  const ShoppingList({
    super.key,
    required this.shoppingList,
    required this.onToggle,
    required this.onGenerate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: onGenerate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Generate List'),
                    ),
                    ElevatedButton(
                      onPressed: onClear,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear List'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                shoppingList.isEmpty
                    ? const Center(child: Text('Shopping list is empty.'))
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: shoppingList.length,
                  itemBuilder: (context, index) {
                    final item = shoppingList[index];
                    return Card(
                      child: CheckboxListTile(
                        title: Text(
                          item.name,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF1C2526),
                          ),
                        ),
                        subtitle: Text(
                          'Quantity: ${item.quantity}',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: const Color(0xFF808080),
                          ),
                        ),
                        value: item.checked,
                        onChanged: (bool? value) {
                          if (value != null) {
                            onToggle(item.id, value);
                          }
                        },
                        activeColor: accentColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}