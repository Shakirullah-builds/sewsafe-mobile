import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_text.dart'; // Uses your generic text widget!

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final Color? barrierColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.barrierColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // 1. Always render the main screen content at the bottom
        child,

        // 2. If loading, drop the overlay on top
        if (isLoading) ...[
          // This ModalBarrier completely blocks the user from tapping anything behind it
          ModalBarrier(
            dismissible: false,
            color: barrierColor ?? Colors.black.withValues(alpha: 0.5), // Darkens the screen
          ),
          
          // The visual loading spinner card
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 24.h),
              decoration: BoxDecoration(
                // Uses the surface color (white) from your AppTheme
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoActivityIndicator(
                    // Automatically uses your brand's primary blue!
                    color: theme.colorScheme.primary,
                    radius: 15.r,
                  ),
                  if (loadingText != null) ...[
                    SizedBox(height: 16.h),
                    CustomText(
                      loadingText!,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: theme.colorScheme.primary,
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}