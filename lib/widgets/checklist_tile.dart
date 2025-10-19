import 'package:flutter/material.dart';

class ChecklistTile extends StatelessWidget {
  final String title;
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final bool isCustom; // Flag to indicate if it's a custom item
  final VoidCallback? onDelete; // Optional callback for deleting

  const ChecklistTile({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onChanged,
    this.isCustom = false, // Default to false
    this.onDelete, // Nullable
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isChecked = initialValue;

    // Build the delete button widget conditionally
    Widget? deleteButton;
    if (isCustom && onDelete != null) {
      deleteButton = IconButton(
        icon: Icon(Icons.delete_outline,
            color: theme.colorScheme.error.withOpacity(0.7)),
        tooltip: 'Delete Custom Item',
        constraints: const BoxConstraints(), // Keep button compact
        padding: const EdgeInsets.only(
            left: 12.0), // Add padding to separate from text
        visualDensity: VisualDensity.compact,
        onPressed: onDelete,
      );
    } else {
      // If no delete button, add a SizedBox to occupy the same space visually
      deleteButton = const SizedBox(width: 48); // Approx width of an IconButton
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Row(
          children: [
            Expanded(
              // Text takes up available space
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color:
                      isChecked ? Colors.white54 : theme.colorScheme.onSurface,
                  decoration: isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            // Add the delete button (or SizedBox) at the end of the Row
            deleteButton,
          ],
        ),
        value: isChecked,
        onChanged: (bool? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        activeColor: theme.colorScheme.primary,
        checkColor: Colors.white,
      ),
    );
  }
}
