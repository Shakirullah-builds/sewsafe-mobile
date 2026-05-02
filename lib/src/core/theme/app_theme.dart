import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surfaceLight,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textPrimaryLight,
          fontSize: 57.sp,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: AppColors.textPrimaryLight,
          fontSize: 45.sp,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textPrimaryLight,
          fontSize: 32.sp,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textPrimaryLight,
          fontSize: 22.sp,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 36.sp,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 28.sp,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 24.sp,
          fontWeight: FontWeight.w400,
        ),
        titleMedium: const TextStyle(color: AppColors.textPrimaryLight),
        titleSmall: const TextStyle(color: AppColors.textPrimaryLight),
        bodyLarge: const TextStyle(color: AppColors.textPrimaryLight),
        bodyMedium: const TextStyle(color: AppColors.textPrimaryLight),
        bodySmall: const TextStyle(color: AppColors.textPrimaryLight),
        labelLarge: const TextStyle(color: AppColors.textPrimaryLight),
        labelMedium: const TextStyle(color: AppColors.textPrimaryLight),
        labelSmall: const TextStyle(color: AppColors.textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.textSecondaryLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2.w),
        ),
      ),
    );
  }

  // You can easily duplicate the above logic for darkTheme later!
}
