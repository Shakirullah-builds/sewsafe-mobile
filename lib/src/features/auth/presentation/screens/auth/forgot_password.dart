import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          iconSize: 24.spMin,
           color: theme.colorScheme.onTertiary, // Use primary color for the back button
           onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              'Forgot Password',
              style: theme.textTheme.displayMedium?.copyWith(
                //fontSize: 24.spMin,
                fontWeight: FontWeight.w600,
              ),
            ),
            10.verticalSpace,
            CustomText(
              'Kindly reset password from registered email address.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}