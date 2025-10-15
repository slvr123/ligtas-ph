import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/screens/splash_screen.dart';
import 'package:disaster_awareness_app/theme/app_theme.dart';

class DisasterReadyApp extends StatelessWidget {
  const DisasterReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Ready App',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
