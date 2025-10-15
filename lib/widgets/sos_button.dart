import 'package:flutter/material.dart';

class SosButton extends StatelessWidget {
  const SosButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency SOS Activated (Simulation)'),
              backgroundColor: Colors.blue,
            ),
          );
        },
        icon: const Icon(Icons.sos_rounded, size: 28),
        label: const Text('EMERGENCY SOS'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 18),
        ),
      ),
    );
  }
}
