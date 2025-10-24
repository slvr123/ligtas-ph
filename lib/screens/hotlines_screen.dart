import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/widgets/hotline_card.dart';
import 'package:disaster_awareness_app/widgets/screen_header.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class HotlinesScreen extends StatelessWidget {
  final String location;
  const HotlinesScreen({super.key, required this.location});

  // Helper function to launch phone dialer
  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    // Remove spaces and non-digit characters for the URI
    final String formattedNumber =
        phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: formattedNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching dialer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: 'Emergency Hotlines',
            // Use the location passed to the screen dynamically
            subtitle: 'National & for $location',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- National Hotlines Section ---
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "National Hotlines",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                HotlineCard(
                  agency: 'National Emergency Hotline',
                  number: '911',
                  // Pass the call function to onCall
                  onCall: () => _makePhoneCall(context, '911'),
                ),
                const SizedBox(height: 12),
                HotlineCard(
                  agency: 'NDRRMC',
                  number: '(02) 8911-5061 / 8912-2665', // Added alternate
                  // Pass the call function to onCall
                  onCall: () => _makePhoneCall(context, '(02) 8911-5061'),
                ),
                const SizedBox(height: 12),
                HotlineCard(
                  agency: 'Philippine Red Cross',
                  number: '143 / (02) 8790-2300', // Added alternate
                  // Pass the call function to onCall
                  onCall: () => _makePhoneCall(context, '143'),
                ),
                const SizedBox(height: 12),
                HotlineCard(
                  agency: 'Bureau of Fire Protection (BFP)',
                  number: '(02) 8426-0219 / 8426-0246', // Added alternate
                  // Pass the call function to onCall
                  onCall: () => _makePhoneCall(context, '(02) 8426-0219'),
                ),
                const SizedBox(height: 12),
                // --- Added National Hotlines ---
                HotlineCard(
                  agency: 'Philippine National Police (PNP)',
                  number: '117 / (02) 8722-0650',
                  onCall: () => _makePhoneCall(context, '117'),
                ),
                const SizedBox(height: 12),
                HotlineCard(
                  agency: 'Philippine Coast Guard (PCG)',
                  number: '(02) 8527-8481 / 0917-PCG-DOTC',
                  onCall: () => _makePhoneCall(context, '(02) 8527-8481'),
                ),
                const SizedBox(height: 12),
                HotlineCard(
                  agency: 'Department of Health (DOH)',
                  number: '(02) 8651-7800 local 5003-5005 / 0917-899-4672',
                  onCall: () => _makePhoneCall(context, '0917-899-4672'),
                ),
                const SizedBox(height: 12),
                HotlineCard(
                  agency: 'Metro Manila Development Authority (MMDA)',
                  number: '136',
                  onCall: () => _makePhoneCall(context, '136'),
                ),
                // --- End Added National Hotlines ---

                const SizedBox(height: 24), // Space before local section

                // --- Local Hotlines Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    // Use the location passed to the screen dynamically
                    "Local Hotlines ($location)",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // Assuming Muntinlupa numbers are placeholders; replace/remove if needed
                // Or fetch dynamically based on 'location' variable
                HotlineCard(
                  agency: 'Muntinlupa City Command Center', // Example
                  number: '137-175', // Example
                  onCall: () => _makePhoneCall(context, '137175'), // Example
                ),
                const SizedBox(height: 12),
                HotlineCard(
                  agency: 'Muntinlupa City Health Office', // Example
                  number: '(02) 8862-2525', // Example
                  onCall: () =>
                      _makePhoneCall(context, '(02) 8862-2525'), // Example
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
