import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'auth_textfield.dart';
import 'forgot_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
// home screen

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      // Attempt to sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      //  Login successful; AuthWrapper will rebuild to Location/ Home automatically.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      // Return to the root so AuthWrapper can rebuild to next screen
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Please check your connection.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please wait and try again.';
      } else {
        message = 'Auth error (${e.code}): ${e.message ?? 'unknown'}';
      }

      //  Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

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
                  'Sign in your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48.0),
                AuthTextField(
                  label: 'Email',
                  controller: _emailController,
                ),
                const SizedBox(height: 16.0),
                AuthTextField(
                  label: 'Password',
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('SIGN IN', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Forgot your Password? ",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Reset Password',
                          style: const TextStyle(
                            color: Color(0xFF2469CD),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'SIGN UP',
                          style: const TextStyle(
                            color: Color(0xFF2469CD),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
