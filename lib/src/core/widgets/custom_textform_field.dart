import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';

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
  final String? headerText;

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
    this.headerText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          headerText ?? '',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 14.spMin,
            fontFamily: GoogleFonts.lato().fontFamily,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        5.verticalSpace,
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines, // Passwords must be 1 line
          maxLength: maxLength,
          readOnly: readOnly,
          // Automatically uses the base font from AppTheme!
          style: theme.inputDecorationTheme.labelStyle,
          decoration: InputDecoration(
            hintStyle: theme.inputDecorationTheme.hintStyle,
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            // Notice we DO NOT define borders, fill colors, or padding here.
            // Flutter will automatically reach into your AppTheme and apply 
            // the perfect inputDecorationTheme you already wrote!
          ),
        ),
      ],
    );
  }
}