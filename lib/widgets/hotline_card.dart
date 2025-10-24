import 'package:flutter/material.dart';

class HotlineCard extends StatelessWidget {
  final String agency;
  final String number;
  final VoidCallback? onCall; // Callback for the call action

  const HotlineCard({
    super.key,
    required this.agency,
    required this.number,
    this.onCall, // Make it optional
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.phone_outlined,
            color:
                theme.colorScheme.primary), // Use primary color, outlined icon
        title: Text(agency,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(number, style: theme.textTheme.bodyMedium),
        trailing: ElevatedButton.icon(
          // Changed to ElevatedButton.icon
          onPressed: onCall, // Use the callback here
          icon: const Icon(Icons.call_outlined, size: 18), // Add call icon
          label: const Text('Call'),
          style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8), // Adjust padding if needed
              textStyle:
                  const TextStyle(fontSize: 14) // Adjust text size if needed
              ),
        ),
      ),
    );
  }
}
