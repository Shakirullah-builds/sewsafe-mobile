import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        onTertiary: AppColors.textTertiaryDark,
        onSecondary: AppColors.textSecondaryDark,
        error: AppColors.error,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.surfaceDark200,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textTertiaryLight,
          fontSize: 57.sp,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: AppColors.textTertiaryLight,
          fontSize: 45.sp,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textTertiaryLight,
          fontSize: 32.sp,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textTertiaryLight,
          fontSize: 22.sp,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          color: AppColors.textTertiaryLight,
          fontSize: 36.sp,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 28.sp,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textTertiaryLight,
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
      //outlinedButtonTheme: ,
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.all(20.r),
        filled: true,
        labelStyle: TextStyle(
          fontSize: 16.spMin,
          color: AppColors.surfaceDark200,
          fontWeight: FontWeight.normal,
          fontFamily: GoogleFonts.lato().fontFamily,
        ),
        hintStyle: TextStyle(
          fontSize: 16.spMin,
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.normal,
          fontFamily: GoogleFonts.lato().fontFamily,
        ),
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(color: AppColors.primarySoft, width: 2.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(color: AppColors.primarySoft, width: 2.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(color: AppColors.primarySoft, width: 2.w),
        ),
        prefixIconColor: AppColors.textTertiaryDark.withValues(alpha: 0.7),
        suffixIconColor: AppColors.textTertiaryDark,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.surfaceDark200,
        thickness: 0.2.w,
        //space: 16.w,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor:
            AppColors.textTertiaryDark, // Dark text/icons on white app bar
        centerTitle: true,
        //elevation: 10,
        titleTextStyle: TextStyle(
          color: AppColors.textTertiaryDark,
          fontSize: 18.spMin,
          fontWeight: FontWeight.w800,
          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),
      // iconButtonTheme: IconButtonThemeData(
      //   style: IconButton.styleFrom(
      //     foregroundColor: AppColors.textSecondaryDark,
      //     iconSize: 24.spMin,
      //     minimumSize: Size.zero,
      //     padding: EdgeInsets.zero,


      //   ),
      // ),
    );
  }

  // You can easily duplicate the above logic for darkTheme later!
}
