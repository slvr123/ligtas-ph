import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/widgets/hotline_card.dart';
import 'package:disaster_awareness_app/widgets/screen_header.dart';

class HotlinesScreen extends StatelessWidget {
  final String location;
  const HotlinesScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
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
              children: const [
                HotlineCard(agency: 'National Emergency Hotline', number: '911'),
                SizedBox(height: 12),
                HotlineCard(agency: 'NDRRMC', number: '(02) 8911-5061'),
                SizedBox(height: 12),
                HotlineCard(agency: 'Philippine Red Cross', number: '143'),
                SizedBox(height: 12),
                HotlineCard(agency: 'Bureau of Fire Protection (BFP)', number: '(02) 8426-0219'),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Local Hotlines (Muntinlupa City)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                HotlineCard(agency: 'Muntinlupa City Command Center', number: '137-175'),
                SizedBox(height: 12),
                HotlineCard(agency: 'Muntinlupa City Health Office', number: '(02) 8862-2525'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
