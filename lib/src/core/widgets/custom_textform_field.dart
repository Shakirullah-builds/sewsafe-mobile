import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator; // Unlocks form validation!
  final TextInputType keyboardType;
  final bool obscureText; // For passwords
  final Widget? suffixIcon; // For the "eye" icon on passwords
  final Widget? prefixIcon; // For email or user icons
  final int maxLines;
  final int? maxLength;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines, // Passwords must be 1 line
      maxLength: maxLength,
      readOnly: readOnly,
      // Automatically uses the base font from AppTheme!
      style: Theme.of(context).textTheme.bodyLarge, 
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        // Notice we DO NOT define borders, fill colors, or padding here.
        // Flutter will automatically reach into your AppTheme and apply 
        // the perfect inputDecorationTheme you already wrote!
      ),
    );
  }
}