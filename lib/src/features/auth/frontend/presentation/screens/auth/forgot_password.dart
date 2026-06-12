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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final bool isLoading = authState.isLoading;

    // Listen for error messages
    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (_, state) {
        if (!state.isLoading && state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: AppColors.notification,
            ),
          );
        }
      },
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            iconSize: 24.spMin,
            color: theme.colorScheme.onSurface, // Use primary color for the back button
            onPressed: () => context.pop(),
          ),
        ),
        body: LoadingOverlay(
          isLoading: isLoading,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
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
                              'Forgot Password',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            15.verticalSpace,
                            CustomText(
                              textAlign: TextAlign.center,
                              'Enter your registered email address below. We\'ll send you a verification code to reset your password.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14.spMin,
                                color: theme.colorScheme.onPrimary,
                                height: 1.71.h,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            40.verticalSpace,
                            CustomButton(
                              text: 'Send Code',
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final email = _emailController.text.trim();
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .sendPasswordReset(email);
                                  if (context.mounted) {
                                    final updatedState = ref.read(authControllerProvider);
                                    if (!updatedState.hasError) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Verification code sent! Please check your email.'),
                                          backgroundColor: AppColors.ready,
                                        ),
                                      );
                                      context.pushNamed(
                                        AppRoute.verifyPasswordReset.name,
                                        queryParameters: {'email': email},
                                      );
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
