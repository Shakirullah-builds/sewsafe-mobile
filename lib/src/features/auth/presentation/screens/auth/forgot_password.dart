import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_button.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_textform_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            iconSize: 24.spMin,
            color: theme
                .colorScheme
                .onTertiary, // Use primary color for the back button
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
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
                      'Forgot Password',
                      style: theme.textTheme.displayMedium?.copyWith(
                        //fontSize: 24.spMin,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    15.verticalSpace,
                    CustomText(
                      'Kindly reset password from registered email address.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    20.verticalSpace,
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.email_rounded,
                        color: theme.inputDecorationTheme.prefixIconColor,
                        size: 24.spMin,
                      ),
                    ),
                    40.verticalSpace,
                    CustomButton(
                      text: 'Send Code',
                      onPressed: () {
                        // Implement password reset logic here
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
    );
  }
}
