import 'package:flutter/material.dart';

class HotlineCard extends StatelessWidget {
  final String agency;
  final String number;

  const HotlineCard({super.key, required this.agency, required this.number});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.phone, color: Colors.white),
        title: Text(agency, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(number, style: theme.textTheme.bodyMedium),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Simulating call to $agency: $number')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Call'),
        ),
      ),
    );
  }
}
