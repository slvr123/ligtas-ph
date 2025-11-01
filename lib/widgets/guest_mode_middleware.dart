import 'package:flutter/material.dart';

/// Middleware/utility class for handling guest mode interactions
class GuestModeMiddleware {
  /// Shows a quick upgrade prompt dialog to encourage guest users to sign up
  static void showQuickUpgradePrompt(
    BuildContext context, {
    String message = 'Sign up to access this feature',
    String title = 'Sign Up Required',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1f2937),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Later',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to signup/login page
              // You can customize this navigation based on your app's routing
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFb91c1c),
            ),
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  /// Shows a banner indicating guest mode restrictions
  static Widget buildGuestModeBanner({
    String message = 'You are in guest mode - limited features available',
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade900.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade700),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade300, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.orange.shade200,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Checks if a feature is restricted for guest users
  static bool isFeatureRestricted(bool isGuest) {
    return isGuest;
  }

  /// Shows a snackbar indicating guest restriction
  static void showGuestRestrictionSnackBar(
    BuildContext context, {
    String message = 'This feature is not available in guest mode',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Sign Up',
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ),
    );
  }
}
