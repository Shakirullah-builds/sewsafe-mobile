import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewsafe_mobile/src/core/constants/color_palette.dart';

void main() {
  DevicePreview(
    tools: [...DevicePreview.defaultTools],
    enabled: !kReleaseMode,
    builder: (context) => ScreenUtilInit(
      designSize: Size(430.w, 932.h),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const SewSafeMobile(),
    ),
  );
}

class SewSafeMobile extends StatelessWidget {
  const SewSafeMobile({super.key});

@override
Widget build (BuildContext context) {
  return MaterialApp.router(
    title: "SewSafe Mobile",
    debugShowCheckedModeBanner: false,
    locale: DevicePreview.locale(context),
    builder: DevicePreview.appBuilder,
    theme: ThemeData(
      useMaterial3: true,
        textTheme: GoogleFonts.playfairDisplayTextTheme(),
        primaryColor: ColorPalette.primary,
    ),
  );
}
}