import 'package:flutter/material.dart';

class DisasterAlertCard extends StatelessWidget {
  final String title;
  final String level;
  final String description;
  final Color levelColor;

  const DisasterAlertCard({
    super.key,
    required this.title,
    required this.level,
    required this.description,
    required this.levelColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: levelColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18, color: levelColor)),
                ),
                Chip(
                  label: Text(level, style: theme.textTheme.labelLarge?.copyWith(fontSize: 12, color: Colors.white)),
                  backgroundColor: levelColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
