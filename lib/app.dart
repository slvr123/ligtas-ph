/*import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/screens/auth_gate.dart';
import 'package:disaster_awareness_app/theme/app_theme.dart';

class DisasterReadyApp extends StatelessWidget {
  const DisasterReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Ready App',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_page.dart';
import 'screens/location_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/user_service.dart';

class DisasterReadyApp extends StatelessWidget {
  const DisasterReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Ready App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF0c0a09),
        cardColor: const Color(0xFF1f2937),
        fontFamily: 'Inter',
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFb91c1c),
          secondary: Color(0xFFdc2626),
          error: Color(0xFFef4444),
          surface: Color(0xFF1f2937),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFb91c1c),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// Wrapper to handle authentication and location state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          return const LocationChecker();
        }

        // User is NOT logged in
        return const LoginPage();
      },
    );
  }
}

// Check if user has saved location
class LocationChecker extends StatelessWidget {
  const LocationChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: userService.getUserLocation(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Error
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Retry or go to location setup
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationSetupScreen(),
                        ),
                      );
                    },
                    child: const Text('Set Location'),
                  ),
                ],
              ),
            ),
          );
        }

        // Check if location exists
        final locationData = snapshot.data;
        
        if (locationData != null) {
          // User has saved location - go to home
          return HomeScreen(
            location: locationData['location'],
            latitude: locationData['latitude'],
            longitude: locationData['longitude'],
          );
        } else {
          // No saved location - go to location setup
          return const LocationSetupScreen();
        }
      },
    );
  }
}