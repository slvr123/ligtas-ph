import 'package:flutter/material.dart';


class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        // Make app bar blend with the background
        backgroundColor: Colors.transparent,
        elevation: 0, // No shadow
      ),
      body: const Center(
        child: Text(
          'Forgot Password Screen',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}



