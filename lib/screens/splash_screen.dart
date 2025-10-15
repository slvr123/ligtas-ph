import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Splash is visual only now; AuthGate controls navigation.
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              'Disaster Ready',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              'Your partner in safety.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
