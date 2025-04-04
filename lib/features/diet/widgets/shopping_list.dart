import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/shopping_list_item.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/core/theme/app_theme.dart'; // Ensure this import is present

class ShoppingList extends StatefulWidget {
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
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  String _sortOption = 'Name'; // Default sort option

  List<ShoppingListItem> _sortShoppingList(List<ShoppingListItem> items) {
    final sortedItems = List<ShoppingListItem>.from(items);
    switch (_sortOption) {
      case 'Name':
        sortedItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Quantity (Asc)':
        sortedItems.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'Quantity (Desc)':
        sortedItems.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'Checked':
        sortedItems.sort((a, b) {
          if (a.checked == b.checked) return 0;
          return a.checked ? 1 : -1; // Checked items at the bottom
        });
        break;
    }
    return sortedItems;
  }

  @override
  Widget build(BuildContext context) {
    print('ShoppingList: Rebuilding with ${widget.shoppingList.length} items');
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        final sortedList = _sortShoppingList(widget.shoppingList);
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(Theme.of(context).mediumPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: widget.onGenerate,
                      child: const Text('Generate List'),
                    ),
                    ElevatedButton(
                      onPressed: widget.onClear,
                      child: const Text('Clear List'),
                    ),
                  ],
                ),
                SizedBox(height: Theme.of(context).mediumSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Sort by: ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    DropdownButton<String>(
                      value: _sortOption,
                      items: const [
                        DropdownMenuItem(value: 'Name', child: Text('Name')),
                        DropdownMenuItem(value: 'Quantity (Asc)', child: Text('Quantity (Asc)')),
                        DropdownMenuItem(value: 'Quantity (Desc)', child: Text('Quantity (Desc)')),
                        DropdownMenuItem(value: 'Checked', child: Text('Checked')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortOption = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: Theme.of(context).mediumSpacing),
                sortedList.isEmpty
                    ? Center(child: Text('Shopping list is empty.', style: Theme.of(context).textTheme.bodyMedium))
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedList.length,
                  itemBuilder: (context, index) {
                    final item = sortedList[index];
                    print('ShoppingList: Rendering item ${item.id}: ${item.toJson()}');
                    return Card(
                      color: item.checked ? Theme.of(context).colorScheme.checkedBackground : null,
                      child: ListTile(
                        key: ValueKey(item.id),
                        leading: GestureDetector(
                          onTap: () {
                            widget.onToggle(item.id, !item.checked);
                          },
                          child: item.checked
                              ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.checkedIcon)
                              : Icon(Icons.circle_outlined, color: Theme.of(context).colorScheme.uncheckedIcon),
                        ),
                        title: Text(
                          '${item.name}: ${item.quantity.toStringAsFixed(1)} ${item.servingSizeUnit ?? 'serving'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            decoration: item.checked ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
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