import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/route/app_route.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_button.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_textform_field.dart';
import 'package:sewsafe_mobile/src/core/widgets/loading_overlay.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/application/auth_controller.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/widgets/pin_input.dart';

class VerifyPasswordResetScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyPasswordResetScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyPasswordResetScreen> createState() =>
      _VerifyPasswordResetScreenState();
}

class _VerifyPasswordResetScreenState
    extends ConsumerState<VerifyPasswordResetScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final bool isLoading = authState.isLoading;

    // Listen for error messages
    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: AppColors.notification,
          ),
        );
      }
    });

    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            iconSize: 24.spMin,
            color: theme.colorScheme.onSurface,
            onPressed: () => context.pop(),
          ),
        ),
        body: LoadingOverlay(
          isLoading: isLoading,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                child: Form(
                  key: _formKey,
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            15.verticalSpace,
                            CustomText(
                              textAlign: TextAlign.center,
                              'A verification code has been sent to your email. Enter it below along with your new password to reset your password.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14.spMin,
                                color: theme.colorScheme.onPrimary,
                                height: 1.71.h,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            30.verticalSpace,

                            // OTP PIN Input
                            PinInput(
                              pinController: pinController,
                              focusNode: focusNode,
                            ),
                            30.verticalSpace,

                            // New Password field
                            CustomTextField(
                              controller: _passwordController,
                              hintText: 'New Password',
                              obscureText: _obscurePassword,
                              headerText: 'New Password',
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color:
                                    theme.inputDecorationTheme.prefixIconColor,
                                size: 24.spMin,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            20.verticalSpace,

                            // Confirm New Password field
                            CustomTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm New Password',
                              obscureText: _obscureConfirmPassword,
                              headerText: 'Confirm New Password',
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color:
                                    theme.inputDecorationTheme.prefixIconColor,
                                size: 24.spMin,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            40.verticalSpace,

                            CustomButton(
                              text: 'Verify & Reset Password',
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final pin = pinController.text.trim();
                                  if (pin.length != 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a valid 6-digit code.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // 1. Verify OTP first
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .verifyPasswordResetOTP(
                                        widget.email,
                                        pin,
                                      );

                                  if (context.mounted) {
                                    final step1State = ref.read(
                                      authControllerProvider,
                                    );
                                    if (!step1State.hasError) {
                                      // 2. OTP is valid, now update password
                                      final newPassword =
                                          _passwordController.text;
                                      await ref
                                          .read(authControllerProvider.notifier)
                                          .updatePassword(newPassword);

                                      if (context.mounted) {
                                        final step2State = ref.read(
                                          authControllerProvider,
                                        );
                                        if (!step2State.hasError) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Password updated successfully! Welcome back.',
                                              ),
                                              backgroundColor: AppColors.ready,
                                            ),
                                          );
                                          // Redirect is handled automatically by the auth status stream!
                                          // But if it doesn't automatically trigger, we navigate to /home.
                                          context.goNamed(AppRoute.home.name);
                                        }
                                      }
                                    }
                                  }
                                }
                              },
                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
