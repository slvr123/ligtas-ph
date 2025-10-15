import 'package:flutter/material.dart';
import 'auth_textfield.dart';


class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Enter the code sent to your email and your new password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 48.0),
                // Code Field
                const AuthTextField(label: 'Code'),
                const SizedBox(height: 16.0),
                // New Password Field
                const AuthTextField(label: 'New Password', isPassword: true),
                const SizedBox(height: 16.0),
                // Confirm New Password Field
                const AuthTextField(
                  label: 'Confirm New Password',
                  isPassword: true,
                ),
                const SizedBox(height: 32.0),
                // Reset Password Button
                ElevatedButton(
                  child: const Text(
                    'RESET PASSWORD',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    // --- BACKEND LOGIC ---
                    // 1. Validate that passwords match and are strong enough.
                    // 2. Make an API call to your backend with the code and new password.
                    // 3. The backend verifies the code is valid and not expired.
                    // 4. If valid, it updates the user's password.
                    // 5. On success, navigate back to the login page.
                    // Pop until we get back to the login page.
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



