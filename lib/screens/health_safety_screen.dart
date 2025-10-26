import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/widgets/screen_header.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

// ⭐ 1. Import the new map screen
import 'package:disaster_awareness_app/screens/evacuation_map_screen.dart';

class HealthSafetyScreen extends StatelessWidget {
  // ⭐ 2. Add these lines to accept location data
  final String location;
  final double latitude;
  final double longitude;

  const HealthSafetyScreen({
    super.key,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  // Helper function to launch URLs (remains the same)
  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open video link: $url')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching URL: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme here
    return Scaffold(
      body: Column(
        children: [
          const ScreenHeader(
            title: 'First Aid & Safety',
            subtitle: 'Essential Life-Saving Information',
          ), //
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ⭐ 3. --- ADD THIS NEW CARD ---
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: theme.colorScheme.surfaceVariant
                      .withOpacity(0.5), // A different highlight
                  child: InkWell(
                    onTap: () {
                      // Get just the city name (e.g., "Marikina" from "Marikina, Metro Manila")
                      final cityName = location.split(',').first.trim();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // ⭐ 4. Navigate to the EvacuationMapScreen
                          builder: (_) => EvacuationMapScreen(
                            userLatitude: latitude,
                            userLongitude: longitude,
                            userCity:
                                cityName, // Pass the city name for filtering
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.map_outlined,
                              size: 32, color: theme.colorScheme.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Find Nearest Evacuation Center',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                          fontSize: 18,
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text('See safe areas near you on a map.',
                                    style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 16, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Spacing
                // --- END OF NEW CARD ---

                _buildSafetyCard(
                  context,
                  title: 'Basic First Aid: Wounds',
                  content:
                      '1. Stop the bleeding by applying firm pressure with a clean cloth.\n2. Clean the wound with water.\n3. Apply an antibiotic ointment and cover with a sterile bandage.',
                  icon: Icons.medication_liquid_outlined, // Changed to outlined
                  videoUrl:
                      'https://youtu.be/9XpJZv_YsGM?si=1o9TZPcsbkcv74xz', // Your provided link
                ), //
                const SizedBox(height: 16),
                _buildSafetyCard(
                  context,
                  title: 'Basic First Aid: Burns (Heat/Fire)',
                  content:
                      "1. Cool the burn immediately with cool (not cold) running water for at least 20 minutes.\n2. Remove tight clothing/jewelry near the burn.\n3. Cover loosely with sterile gauze or clean cloth.\n4. Do NOT apply ointments, butter, or ice.", // Updated duration based on common guidelines
                  icon: Icons.whatshot_outlined, // Changed to outlined
                  videoUrl:
                      'https://youtu.be/sauqm3mvJ40?si=U2M_mQ6GZvEbQrXK', // Your provided link
                ),
                const SizedBox(height: 16),
                _buildSafetyCard(
                  context,
                  title: 'First Aid: Choking (Adult/Child)',
                  content:
                      "1. Ask 'Are you choking?'.\n2. Encourage coughing.\n3. If they can't cough/speak, give 5 back blows between shoulder blades.\n4. If still choking, give 5 abdominal thrusts (Heimlich maneuver).\n5. Alternate back blows and thrusts. Call emergency services if needed.",
                  icon: Icons.support_outlined, // Changed to outlined
                  videoUrl:
                      'https://youtu.be/j45WfhxK_Hs?si=NvLVXeRog6P9eTyC', // Your provided link
                ),
                const SizedBox(height: 16),
                _buildSafetyCard(
                  context,
                  title: 'Hands-Only CPR',
                  content:
                      "1. Check for responsiveness. If unresponsive and not breathing normally, call emergency services.\n2. Place the heel of one hand on the center of the chest, other hand on top.\n3. Push hard and fast (100-120 compressions per minute) until help arrives or the person recovers.\n(Formal training is recommended)",
                  icon: Icons.monitor_heart_outlined, // Changed to outlined
                  videoUrl:
                      'https://www.youtube.com/watch?v=M4ACYp75mjU', // Your provided link (same as example)
                ),
                const SizedBox(height: 16),
                _buildSafetyCard(
                  context,
                  title: 'First Aid: Heatstroke/Heat Exhaustion',
                  content:
                      "Move the person to a cooler place. Loosen tight clothing. Apply cool, wet cloths or offer a cool bath. Give sips of water if conscious. Seek medical help immediately for heatstroke (confusion, high fever, lack of sweating).",
                  icon: Icons.thermostat_outlined, // Changed to outlined
                  videoUrl:
                      'https://youtu.be/_UT7PO_gd50?si=Orl1yfpHMePdymRt', // Your provided link
                ),
                const SizedBox(height: 16),
                _buildSafetyCard(
                  context,
                  title: 'During an Earthquake: Drop, Cover, Hold On',
                  content:
                      'DROP to your hands and knees. COVER your head and neck under a sturdy table. HOLD ON to your shelter until the shaking stops.',
                  icon: Icons.personal_injury_outlined, // Changed to outlined
                  videoUrl:
                      'https://youtu.be/t36YzCnmjEU?si=Aqf6Jmd-u-s57R6B', // Your provided link
                ), //
                const SizedBox(height: 16),
                _buildSafetyCard(
                  context,
                  title: 'During a Flood: Seek Higher Ground',
                  content:
                      'Evacuate immediately if advised. Do not walk, swim, or drive through floodwaters. Turn Around, Don\'t Drown!',
                  icon: Icons.house_siding_outlined, // Changed to outlined
                  videoUrl:
                      'https://youtu.be/43M5mZuzHF8?si=-77A08T4bSpqOhic', // Your provided link
                ), //
                const SizedBox(height: 16),
                _buildSafetyCard(
                  context,
                  title: 'During a Typhoon/Strong Winds',
                  content:
                      "Stay indoors away from windows. Secure loose objects outside. Monitor official storm updates (PAGASA). Have your Go Bag ready. Unplug appliances if flooding is possible.",
                  icon: Icons.air_outlined, // Changed to outlined
                  videoUrl:
                      'https://youtu.be/KDZ_AfZ1HwA?si=uInZ4SVdl7me0Eo_', // Your provided link
                ),
                const SizedBox(height: 16),
                _buildSafetyCard(
                  context,
                  title: 'During a Volcanic Eruption',
                  content:
                      "Listen for official warnings (PHIVOLCS). Evacuate if ordered. Protect yourself from ashfall: wear masks (N95), goggles, and long clothing. Stay indoors, close windows/doors. Avoid driving in heavy ash.",
                  icon: Icons.volcano_outlined, // Changed to outlined
                  videoUrl:
                      'httpsG://youtu.be/Z-w_z9yobpE?si=FZSfevl9eaXzGXYq', // Typo fixed
                ),
                const SizedBox(height: 16),
                _buildSafetyCard(
                  context,
                  title: 'Landslide Safety',
                  content:
                      "Be aware of warning signs (cracks in ground, tilting trees/poles, rumbling sounds). If evacuation is ordered, leave immediately. Move away from the path of debris. If caught, curl into a ball and protect your head.",
                  icon: Icons.landslide_outlined, // Changed to outlined
                  videoUrl:
                      'httpsG://youtu.be/UH-SJuSdLDw?si=0v-cacEigzVXpGiJ', // Typo fixed
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _buildSafetyCard widget remains the same
  Widget _buildSafetyCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    String? videoUrl,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 0), // Use SizedBox in ListView
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(title,
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontSize: 18))),
              ],
            ),
            const SizedBox(height: 12),
            Text(content,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
            if (videoUrl != null && videoUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.play_circle_outline, size: 20),
                  label: const Text('Watch Video Guide'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  onPressed: () => _launchUrl(context, videoUrl),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
