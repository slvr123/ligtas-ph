import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/widgets/checklist_tile.dart';
import 'package:disaster_awareness_app/widgets/screen_header.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const goBagItems = [
      'Bottled water (1 gallon per person per day)',
      'Non-perishable food (good for 3 days)',
      'Flashlight with extra batteries',
      'First-aid kit',
      'Whistle to signal for help',
      'Copies of important documents (passports, IDs)',
      'Cash in small denominations',
      'Medications and prescription info',
      'Phone with power bank',
      'Face masks',
    ];

    const homeItems = [
      'Secure heavy furniture to walls',
      'Know location of gas, water, and electricity shutoffs',
      'Check fire extinguisher expiration date',
      'Prepare a family emergency plan',
      'Designate a safe meeting place',
    ];

    return Scaffold(
      body: Column(
        children: [
          const ScreenHeader(
            title: 'Safety Checklist',
            subtitle: 'Prepare your Go Bag and Home',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Emergency Go Bag', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...goBagItems.map((item) => ChecklistTile(title: item)),
                const SizedBox(height: 24),
                const Text('Home Preparation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...homeItems.map((item) => ChecklistTile(title: item)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
