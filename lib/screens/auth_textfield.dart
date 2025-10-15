import 'package:flutter/material.dart';


class AuthTextField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final TextEditingController? controller; // To control the text field
  final bool hasError; // To indicate if there's an error


  const AuthTextField({
    super.key,
    required this.label,
    this.isPassword = false,
    this.controller,
    this.hasError = false,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller, // Use the provided controller
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white), // High contrast on dark
          cursorColor: theme.colorScheme.primary,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF111827), // slate-900 style field bg
            hintStyle: const TextStyle(color: Colors.white60),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            // Define a border that reacts to the hasError state
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: hasError ? Colors.redAccent : const Color(0xFF374151), // slate-700
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: hasError ? Colors.redAccent : theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}



