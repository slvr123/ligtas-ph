import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/widgets/screen_header.dart';

class HealthSafetyScreen extends StatelessWidget {
  const HealthSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ScreenHeader(
            title: 'First Aid & Safety',
            subtitle: 'Essential Life-Saving Information',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSafetyCard(
                  context,
                  title: 'Basic First Aid: Wounds',
                  content: '1. Stop the bleeding by applying firm pressure with a clean cloth.\n2. Clean the wound with water.\n3. Apply an antibiotic ointment and cover with a sterile bandage.',
                  icon: Icons.medication_liquid,
                ),
                _buildSafetyCard(
                  context,
                  title: 'During an Earthquake: Drop, Cover, Hold On',
                  content: 'DROP to your hands and knees. COVER your head and neck under a sturdy table. HOLD ON to your shelter until the shaking stops.',
                  icon: Icons.personal_injury,
                ),
                _buildSafetyCard(
                  context,
                  title: 'During a Flood: Seek Higher Ground',
                  content: 'Evacuate immediately if advised. Do not walk, swim, or drive through floodwaters. Turn Around, Don\'t Drown!',
                  icon: Icons.house_siding,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard(BuildContext context, {required String title, required String content, required IconData icon}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: theme.colorScheme.secondary),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18))),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
          ],
        ),
      ),
    );
  }
}

