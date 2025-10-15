import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/widgets/disaster_alert_card.dart';
import 'package:disaster_awareness_app/widgets/screen_header.dart';

class AlertsScreen extends StatelessWidget {
  final String location;
  const AlertsScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(title: 'Disaster Alerts', subtitle: location),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DisasterAlertCard(
                  title: 'Typhoon Signal No. 3',
                  level: 'SEVERE',
                  description: 'Typhoon "Karding" is directly affecting $location. Expect destructive winds and intense rainfall. Evacuate if in a low-lying area.',
                  levelColor: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                DisasterAlertCard(
                  title: 'Red Rainfall Warning',
                  level: 'SEVERE',
                  description: 'Intense rainfall (30-60mm/hr) observed. Serious flooding is expected in low-lying areas.',
                  levelColor: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                DisasterAlertCard(
                  title: 'Orange Rainfall Warning',
                  level: 'MODERATE',
                  description: 'Heavy rainfall (15-30mm/hr) is affecting nearby areas. Flooding is threatening.',
                  levelColor: Colors.orange.shade700,
                ),
                 const SizedBox(height: 16),
                DisasterAlertCard(
                  title: 'Earthquake Info',
                  level: 'INFO',
                  description: 'Magnitude 4.2 earthquake recorded 102km SE of Manila. No tsunami threat.',
                  levelColor: theme.colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

