import 'package:flutter/material.dart';

class ChecklistTile extends StatefulWidget {
  final String title;
  const ChecklistTile({super.key, required this.title});

  @override
  State<ChecklistTile> createState() => _ChecklistTileState();
}

class _ChecklistTileState extends State<ChecklistTile> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(
          widget.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: _isChecked ? Colors.white54 : theme.colorScheme.onSurface,
            decoration: _isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        value: _isChecked,
        onChanged: (bool? newValue) {
          setState(() {
            _isChecked = newValue!;
          });
        },
        activeColor: theme.colorScheme.primary,
        checkColor: Colors.white,
      ),
    );
  }
}
