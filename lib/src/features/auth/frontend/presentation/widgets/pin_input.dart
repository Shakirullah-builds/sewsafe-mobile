import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';

class PinInput extends StatelessWidget {
  final TextEditingController pinController;
  final FocusNode focusNode;

  @override
  const PinInput({
    super.key,
    required this.pinController,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPinTheme = PinTheme(
      //margin: EdgeInsets.symmetric(horizontal: 8.w),
      width: 64.w,
      height: 64.h,
      textStyle: theme.textTheme.headlineMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white, // The white boxes from your design
        borderRadius: BorderRadius.circular(12.r),
        // Optional: Add a subtle border or shadow to make them pop off the grey background
        border: Border.all(color: AppColors.placeholder, width: 1.w),
      ),
    );
    return Pinput(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      length: 4,
      controller: pinController,
      focusNode: focusNode,
      defaultPinTheme: defaultPinTheme,
      // Design tip: Change the border color when a box is focused
      focusedPinTheme: defaultPinTheme.copyDecorationWith(
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
          width: 2,
        ),
      ),
      // PRO TIP: Force numeric keyboard (even though Figma shows a text keyboard,
      // users hate typing numbers on a full keyboard)
      keyboardType: TextInputType.number,

      // Automatically trigger verification when the 4th digit is typed!
      onCompleted: (pin) {
        debugPrint('User typed: $pin - Ready to verify!');
        // Trigger your Riverpod auth verification method here
      },
    );
  }
}
