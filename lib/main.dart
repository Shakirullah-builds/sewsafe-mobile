import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Ensure Flutter engine is initialized before running native code
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  DevicePreview(
    tools: const [...DevicePreview.defaultTools],
    enabled: !kReleaseMode,
    builder: (context) => ScreenUtilInit(
      designSize: Size(430.w, 932.h),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const ProviderScope(child: SewSafeMobile()),
    ),
  );
}

class SewSafeMobile extends StatelessWidget {
  const SewSafeMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SewSafe",
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme,
      home: const Scaffold(body: Center(child: Text('SewSafe Mobile Loaded Successfully!'),),),
      // theme: ThemeData(
      //   useMaterial3: true,
      //   textTheme: GoogleFonts.playfairDisplayTextTheme(),
      //   primaryColor: AppColors.primary,
      // ),
    );
  
  }
}
