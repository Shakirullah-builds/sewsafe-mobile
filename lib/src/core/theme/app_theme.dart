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
      // 1. Set the Global Background
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      
      // 2. The Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.background,
        error: AppColors.notification, // Maps to your red!
        onSurface: AppColors.textSecondary, 
        outline: AppColors.stroke, // Native outline color
        onPrimary: AppColors.textBody,
        
      ),
      textTheme: GoogleFonts.latoTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textSecondary,
          fontSize: 57.sp,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: AppColors.textSecondary,
          fontSize: 45.sp,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textSecondary,
          fontSize: 32.sp,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textSecondary,
          fontSize: 22.sp,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 36.sp,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 28.sp,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 24.sp,
          fontWeight: FontWeight.w400,
        ),
        titleMedium: const TextStyle(color: AppColors.textPrimary),
        titleSmall: const TextStyle(color: AppColors.textPrimary),
        bodyLarge: const TextStyle(color: AppColors.textPrimary),
        bodyMedium: const TextStyle(color: AppColors.textPrimary),
        bodySmall: const TextStyle(color: AppColors.textPrimary),
        labelLarge: const TextStyle(color: AppColors.textPrimary),
        labelMedium: const TextStyle(color: AppColors.textPrimary),
        labelSmall: const TextStyle(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r), // Standard Figma button radius
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),

      // 5. Input Fields
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.all(16.r),
        filled: true,
        fillColor: AppColors.background, // Or background, depending on Figma
        
        // Use your new Placeholder color!
        hintStyle: GoogleFonts.lato(
          fontSize: 16.spMin,
          color: AppColors.textSecondary.withValues(alpha: 0.5), 
        ),
        labelStyle: GoogleFonts.lato(
          fontSize: 16.spMin,
          color: AppColors.textSecondary, 
          fontWeight: FontWeight.w500,
        ),

        // theme.textTheme.bodyLarge?.copyWith(
        //     fontSize: 14.spMin,
        //     fontFamily: GoogleFonts.lato().fontFamily,
        //     color: AppColors.textSecondary,
        //     fontWeight: FontWeight.w500,
        //   ),

        
        // Use your new Stroke color!
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r), // 12 is standard
          borderSide: BorderSide(color: AppColors.placeholder, width: 1.0.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.placeholder, width: 1.0.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.6), width: 1.3.w), // Lights up Primary on tap!
        ),
      ),
      
      // 6. App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textSecondary,
        centerTitle: true,
        elevation: 0, // Flat app bars are standard now
        titleTextStyle: GoogleFonts.lato(
          color: AppColors.textSecondary,
          fontSize: 18.spMin,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.textSecondary.withValues(alpha: 0.5),
        thickness: 0.5.sp,
      ),
    );
  }

  // You can easily duplicate the above logic for darkTheme later!
}
