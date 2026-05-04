import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_button.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/features/auth/presentation/widgets/pin_input.dart';

class VerifyPasswordResetScreen extends ConsumerStatefulWidget {
  const VerifyPasswordResetScreen({super.key});

  @override
  ConsumerState<VerifyPasswordResetScreen> createState() =>
      _VerifyPasswordResetScreenState();
}

class _VerifyPasswordResetScreenState
    extends ConsumerState<VerifyPasswordResetScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            iconSize: 24.spMin,
            color: theme
                .colorScheme
                .onTertiary, // Use primary color for the back button
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        CustomText(
                          'Verification',
                          style: theme.textTheme.displayMedium?.copyWith(
                            //fontSize: 24.spMin,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        15.verticalSpace,
                        CustomText(
                          textAlign: TextAlign.center,
                          'A verification code has been sent to your email. Enter it below to reset your password.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14.spMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        40.verticalSpace,
                        PinInput(
                          pinController: pinController,
                          focusNode: focusNode,
                        ),
                        60.verticalSpace,
                        CustomButton(
                          text: 'Verify',
                          onPressed: () {
                            // Implement your verification logic here
                          },
                          fontWeight: FontWeight.w700,
                          buttonTextFontSize: 18.spMin,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
