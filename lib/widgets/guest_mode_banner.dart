import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class GuestModeBanner extends StatelessWidget {
  const GuestModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    if (!authService.isGuest) {
      return const SizedBox.shrink(); // Don't show for registered users
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.withOpacity(0.2),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Guest Mode - Data saved temporarily (will be lost on logout)',
              style: TextStyle(
                color: Colors.orange[300],
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to sign up or show conversion dialog
              _showConversionDialog(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Sign Up', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showConversionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Account'),
        content: const Text(
          'Convert your guest account to a permanent account to save your data and access all features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to sign up page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
            },
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}