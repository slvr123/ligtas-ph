import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/widgets/hotline_card.dart';
import 'package:disaster_awareness_app/widgets/screen_header.dart';
import 'package:disaster_awareness_app/services/hotline_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final hotlineService = HotlineService();
    // Fetch local hotlines outside the ListView for clarity
    final localHotlines = hotlineService.getLocalHotlines(location);

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: 'Emergency Hotlines',
            subtitle: 'National & for $location',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- 1. Local Hotlines Section (MOVED TO TOP) ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Local Hotlines ($location)",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Show local hotlines or message if none available
                if (localHotlines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No specific local hotlines available for $location yet. Using national hotlines below.',
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...localHotlines.map((hotline) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HotlineCard(
                        agency: hotline.agency,
                        number: hotline.number,
                        onCall: () => _makePhoneCall(context, hotline.number),
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 24), // Separator

                // --- 2. National Hotlines Section (MOVED TO BOTTOM) ---
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
                  onCall: () => _makePhoneCall(context, '911'),
                ),
                const SizedBox(height: 12),
                HotlineCard(
                  agency: 'NDRRMC',
                  number: '(02) 8911-5061 / 8912-2665',
                  onCall: () => _makePhoneCall(context, '(02) 8911-5061'),
                ),
                const SizedBox(height: 12),
                HotlineCard(
                  agency: 'Philippine Red Cross',
                  number: '143 / (02) 8790-2300',
                  onCall: () => _makePhoneCall(context, '143'),
                ),
                const SizedBox(height: 12),
                HotlineCard(
                  agency: 'Bureau of Fire Protection (BFP)',
                  number: '(02) 8426-0219 / 8426-0246',
                  onCall: () => _makePhoneCall(context, '(02) 8426-0219'),
                ),
                const SizedBox(height: 12),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}