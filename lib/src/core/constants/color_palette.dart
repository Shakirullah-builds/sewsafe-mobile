import 'package:flutter/material.dart';

class ColorPalette {
  // Private constructor to prevent instantiation
  ColorPalette._();

  // Primary Colors
  static final Color primary = Color.fromRGBO(25, 54, 107, 100);
  //static const Color primaryDark = Color(0xFF19366B);
  static const Color primaryLight = Color(0xFFBBDEFB);

  // Secondary Colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF388E3C);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Error Colors
  static const Color error = Color(0xFFB00020);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
}
