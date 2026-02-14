import 'package:flutter/material.dart';

class Typography {
  // Private constructor to prevent instantiation
  Typography._();

  // ============================================
  // DISPLAY STYLES - Large prominent text
  // ============================================
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // ============================================
  // HEADLINE STYLES - Section headings
  // ============================================
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // ============================================
  // TITLE STYLES - Smaller headings / list titles
  // ============================================
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ============================================
  // BODY STYLES - Main content text
  // ============================================
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ============================================
  // LABEL STYLES - Buttons, captions, etc.
  // ============================================
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ============================================
  // SEMANTIC ALIASES - Application-specific names
  // ============================================

  // Page and screen titles
  static const TextStyle pageTitle = headlineLarge;
  static const TextStyle sectionTitle = headlineMedium;
  static const TextStyle subsectionTitle = titleLarge;

  // Content text
  static const TextStyle primaryContent = bodyLarge;
  static const TextStyle secondaryContent = bodyMedium;
  static const TextStyle tertiaryContent = bodySmall;

  // UI Elements
  static const TextStyle buttonText = labelLarge;
  static const TextStyle buttonTextSmall = labelMedium;
  static const TextStyle inputText = bodyMedium;
  static const TextStyle inputHint = bodyMedium;
  static const TextStyle inputLabel = labelMedium;

  // Captions and text
  static const TextStyle caption = labelSmall;
  static const TextStyle overline = labelSmall;
  static const TextStyle helperText = bodySmall;

  // Navigation
  static const TextStyle bottomNavLabel = labelMedium;
  static const TextStyle appBarTitle = titleLarge;
  static const TextStyle drawerItem = bodyLarge;

  // Cards and list items
  static const TextStyle cardTitle = titleMedium;
  static const TextStyle cardSubtitle = bodyMedium;
  static const TextStyle listItemTitle = bodyLarge;
  static const TextStyle listItemSubtitle = bodySmall;

  // Messages and notifications
  static const TextStyle snackBarText = bodyMedium;
  static const TextStyle toastMessage = bodySmall;

  // Error and status text
  static const TextStyle errorMessage = bodySmall;
  static const TextStyle successMessage = bodyMedium;
  static const TextStyle warningMessage = bodyMedium;
}
