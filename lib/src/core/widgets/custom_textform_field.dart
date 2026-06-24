import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final bool? filled;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;

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
    this.filled,
    this.fillColor,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.contentPadding,
    this.hintStyle,
    this.style,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerText != null && headerText!.isNotEmpty) ...[
          CustomText(
            headerText!,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 14.spMin,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          5.verticalSpace,
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines, // Passwords must be 1 line
          maxLength: maxLength,
          readOnly: readOnly,
          onChanged: onChanged,
          // Automatically uses the base font from AppTheme!
          style: style ?? theme.inputDecorationTheme.labelStyle,
          decoration: InputDecoration(
            filled: filled,
            fillColor: fillColor,
            hintStyle: hintStyle ?? theme.inputDecorationTheme.hintStyle,
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            border: border,
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
            contentPadding: contentPadding,
          ),
        ),
      ],
    );
  }
}

