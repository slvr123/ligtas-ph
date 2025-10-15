import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/widgets/news_update_card.dart';
import 'package:disaster_awareness_app/widgets/screen_header.dart';

class NewsUpdatesScreen extends StatelessWidget {
  const NewsUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ScreenHeader(
            title: 'News Updates',
            subtitle: 'Latest information from official sources',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                NewsUpdateCard(
                  content: 'PAGASA: Typhoon "Karding" maintains strength, expected to make landfall in Central Luzon.',
                  time: 'Today, 6:00 PM PST',
                ),
                NewsUpdateCard(
                  content: 'Muntinlupa City LGU announces forced evacuation for residents in flood-prone areas near Laguna Lake.',
                  time: 'Today, 5:30 PM PST',
                ),
                NewsUpdateCard(
                  content: 'All classes and government work in Metro Manila suspended for Friday, October 10, 2025.',
                  time: 'Today, 3:15 PM PST',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

