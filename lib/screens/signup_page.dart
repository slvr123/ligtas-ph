/*import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SignUpPage extends StatefulWidget {

  
  const SignUpPage({super.key});


  @override
  State<SignUpPage> createState() => _SignUpPageState();
}


class _SignUpPageState extends State<SignUpPage> {
  // Controllers for all text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();



  // State variable to track if passwords do not match
  bool _passwordsDoNotMatch = false;
  // State variable to track if the user has tried to submit the form
  bool _submitted = false;
  bool _isSubmitting = false;


  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }


  @override
  void dispose() {
    // Clean up all controllers
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.removeListener(_validatePasswords);
    _confirmPasswordController.removeListener(_validatePasswords);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  void _validatePasswords() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final bool shouldShowError =
        confirmPassword.isNotEmpty && password != confirmPassword;
    if (shouldShowError != _passwordsDoNotMatch) {
      setState(() {
        _passwordsDoNotMatch = shouldShowError;
      });
    }
  }


  // Handle the sign-up button press
  void _handleSignUp() async {
      setState(() {
    _submitted = true;
    _validatePasswords();
  });

  if (_nameController.text.isEmpty ||
      _emailController.text.isEmpty ||
      _passwordController.text.isEmpty ||
      _confirmPasswordController.text.isEmpty ||
      _passwordsDoNotMatch ||
      _isSubmitting) {
    return; // stop if invalid or already submitting
  }

  setState(() {
    _isSubmitting = true;
  });

  try {
    // Progress message: creating account
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Creating account...')));
    }

    //  Create user in Firebase Authentication (no aggressive timeout to avoid false negatives)
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Best-effort: save user details to Firestore in the background without blocking UX
    unawaited(FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': Timestamp.now(),
        })
        .timeout(const Duration(seconds: 20))
        .catchError((_) {
          // Silently ignore profile save errors; account creation already succeeded
        }));

    // Stop progress snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    // Stop loading spinner immediately and show explicit success prompt
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Account created'),
        content: const Text('Your account has been created successfully. Please sign in to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Sign out (Firebase signs the user in by default after creation)
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }

  } on FirebaseAuthException catch (e) {
    // Handle Firebase errors
    String message = '';
    if (e.code == 'email-already-in-use') {
      message = 'This email is already registered.';
    } else if (e.code == 'weak-password') {
      message = 'Password is too weak.';
    } else if (e.code == 'invalid-email') {
      message = 'Invalid email address.';
    } else if (e.code == 'operation-not-allowed') {
      message = 'Email/password accounts are disabled in Firebase Auth.';
    } else if (e.code == 'network-request-failed') {
      message = 'Network error. Please check your connection and try again.';
    } else if (e.code == 'too-many-requests') {
      message = 'Too many attempts. Please wait and try again later.';
    } else {
      message = 'Auth error (${e.code}): ${e.message ?? 'unknown'}';
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  } on TimeoutException catch (_) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Request timed out. Please try again.')));
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(e.toString())));
  } finally {
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
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
                  'SIGN UP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Start with creating a\naccount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40.0),
                // Input Fields for Sign Up
                AuthTextField(
                  label: 'Name',
                  controller: _nameController,
                  hasError: _submitted && _nameController.text.isEmpty,
                ),
                const SizedBox(height: 16.0),
                AuthTextField(
                  label: 'Email',
                  controller: _emailController,
                  hasError: _submitted && _emailController.text.isEmpty,
                ),
                const SizedBox(height: 16.0),
                AuthTextField(
                  label: 'Password',
                  isPassword: true,
                  controller: _passwordController,
                  hasError:
                      (_submitted && _passwordController.text.isEmpty) ||
                      _passwordsDoNotMatch,
                ),
                const SizedBox(height: 16.0),
                AuthTextField(
                  label: 'Confirm Password',
                  isPassword: true,
                  controller: _confirmPasswordController,
                  hasError:
                      (_submitted && _confirmPasswordController.text.isEmpty) ||
                      _passwordsDoNotMatch,
                ),
                const SizedBox(height: 32.0),
                // Sign Up Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSignUp,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : const Text('SIGN UP', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 24.0),
                // "Have an account?" text link
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Have an account? ',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'SIGN IN',
                          style: TextStyle(
                            color: _isSubmitting ? Colors.white38 : const Color(0xFF2469CD),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if (_isSubmitting) return;
                              // Navigate back to the login page
                              Navigator.pop(context);
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

*/
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:disaster_awareness_app/screens/user_service.dart';  // Add this import


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}


class _SignUpPageState extends State<SignUpPage> {
  // Controllers for all text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final UserService _userService = UserService();  // Add this

  // State variable to track if passwords do not match
  bool _passwordsDoNotMatch = false;
  // State variable to track if the user has tried to submit the form
  bool _submitted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    // Clean up all controllers
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.removeListener(_validatePasswords);
    _confirmPasswordController.removeListener(_validatePasswords);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final bool shouldShowError =
        confirmPassword.isNotEmpty && password != confirmPassword;
    if (shouldShowError != _passwordsDoNotMatch) {
      setState(() {
        _passwordsDoNotMatch = shouldShowError;
      });
    }
  }

  // Handle the sign-up button press
  void _handleSignUp() async {
    setState(() {
      _submitted = true;
      _validatePasswords();
    });

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _passwordsDoNotMatch ||
        _isSubmitting) {
      return; // stop if invalid or already submitting
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Progress message: creating account
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Creating account...')));
      }

      // Create user in Firebase Authentication
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ⭐ NEW: Create user document using UserService
      try {
        await _userService.createUserDocument(
          email: _emailController.text.trim(),
          displayName: _nameController.text.trim(),
        );
      } catch (e) {
        print('Error creating user document: $e');
        // Continue even if this fails - the auth account is already created
      }

      // Stop progress snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Stop loading spinner immediately and show explicit success prompt
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Account created'),
          content: const Text('Your account has been created successfully. Please sign in to continue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Sign out (Firebase signs the user in by default after creation)
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}

      if (mounted) {
        // Return to the root (AuthWrapper) so it shows LoginPage after sign-out
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } on FirebaseAuthException catch (e) {
      // Handle Firebase errors
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/password accounts are disabled in Firebase Auth.';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Please check your connection and try again.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please wait and try again later.';
      } else {
        message = 'Auth error (${e.code}): ${e.message ?? 'unknown'}';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } on TimeoutException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Request timed out. Please try again.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
                  'SIGN UP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Start with creating a\naccount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40.0),
                // Input Fields for Sign Up
                AuthTextField(
                  label: 'Name',
                  controller: _nameController,
                  hasError: _submitted && _nameController.text.isEmpty,
                ),
                const SizedBox(height: 16.0),
                AuthTextField(
                  label: 'Email',
                  controller: _emailController,
                  hasError: _submitted && _emailController.text.isEmpty,
                ),
                const SizedBox(height: 16.0),
                AuthTextField(
                  label: 'Password',
                  isPassword: true,
                  controller: _passwordController,
                  hasError:
                      (_submitted && _passwordController.text.isEmpty) ||
                      _passwordsDoNotMatch,
                ),
                const SizedBox(height: 16.0),
                AuthTextField(
                  label: 'Confirm Password',
                  isPassword: true,
                  controller: _confirmPasswordController,
                  hasError:
                      (_submitted && _confirmPasswordController.text.isEmpty) ||
                      _passwordsDoNotMatch,
                ),
                const SizedBox(height: 32.0),
                // Sign Up Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSignUp,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : const Text('SIGN UP', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 24.0),
                // "Have an account?" text link
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Have an account? ',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'SIGN IN',
                          style: TextStyle(
                            color: _isSubmitting ? Colors.white38 : const Color(0xFF2469CD),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if (_isSubmitting) return;
                              // Navigate back to the login page
                              Navigator.pop(context);
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