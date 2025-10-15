import 'package:flutter/material.dart';

class NewsUpdateCard extends StatelessWidget {
  final String content;
  final String time;

  const NewsUpdateCard({super.key, required this.content, required this.time});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
