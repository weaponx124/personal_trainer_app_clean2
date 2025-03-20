import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/shopping_list_item.dart';

class ShoppingList extends StatelessWidget {
  final List<ShoppingListItem> shoppingList;
  final Function(String, bool) onToggle;
  final VoidCallback onGenerate;
  final VoidCallback onClear;

  const ShoppingList({
    Key? key,
    required this.shoppingList,
    required this.onToggle,
    required this.onGenerate,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFB0B7BF),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shopping List',
                  style: GoogleFonts.oswald(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB22222),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFFB22222)),
                      onPressed: onGenerate,
                      tooltip: 'Generate Shopping List',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFB22222)),
                      onPressed: onClear,
                      tooltip: 'Clear Shopping List',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            shoppingList.isEmpty
                ? const Text('No items in shopping list. Generate a list from your logged meals.')
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shoppingList.length,
              itemBuilder: (context, index) {
                final item = shoppingList[index];
                final isChecked = item.checked;
                return CheckboxListTile(
                  title: Text(
                    item.name,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF1C2526),
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    '${item.quantity} servings',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: const Color(0xFF808080),
                    ),
                  ),
                  value: isChecked,
                  onChanged: (bool? value) {
                    if (value != null) {
                      onToggle(item.id, value);
                    }
                  },
                  activeColor: const Color(0xFFB22222),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}