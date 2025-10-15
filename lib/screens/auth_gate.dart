import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_screen.dart';
import 'login_page.dart';
import 'location_setup_screen.dart';

/// Decides which screen to show based on Firebase auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While Firebase initializes, show Splash
          return const SplashScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          // Not signed in -> Login
          return const LoginPage();
        }

        // Signed in -> Location setup (or home screen)
        return const LocationSetupScreen();
      },
    );
  }
}
