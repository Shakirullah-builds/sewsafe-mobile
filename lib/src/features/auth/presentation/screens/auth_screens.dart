import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    CustomText(
                      'Create Account',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 48.spMin,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    15.verticalSpace,
                    Padding(
                      padding: EdgeInsets.only(left: 40.w, right: 40.w),
                      child: CustomText(
                        'Secure measurement tracking for professonal artisans',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16.spMin,
                          fontFamily: GoogleFonts.lato().fontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              30.verticalSpace,
              
            ],
          ),
        ),
      ),
    );
  }
}
