import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mail/open_mail.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/route/app_route.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_button.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/core/widgets/loading_overlay.dart';
import 'package:sewsafe_mobile/src/features/auth/backend/data/auth_repository.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/application/auth_controller.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/widgets/pin_input.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _showOtpField = false;
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: LoadingOverlay(
          isLoading: isLoading,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_outlined),
                            iconSize: 24.spMin,
                            color: theme.colorScheme.onSurface,
                            onPressed: () => context.pop(),
                          ),
                        ),
                        20.verticalSpace,

                        // Beautiful Circle Envelope Graphic
                        Container(
                          width: 120.r,
                          height: 120.r,
                          decoration: BoxDecoration(
                            color: AppColors.placeholder.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.mark_email_unread_outlined,
                              size: 60.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        30.verticalSpace,

                        // Title
                        CustomText(
                          'Confirm Your Email',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 32.spMin,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        15.verticalSpace,

                        // Subtitle/Description
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'We sent a verification link to \n',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 16.spMin,
                                color: AppColors.textBody,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: widget.email,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 16.spMin,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      '.\nPlease check your inbox and verify your email to log in.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        40.verticalSpace,

                        // Open Mail App Button
                        CustomButton(
                          text: 'Open Mail App',
                          onPressed: () async {
                            final result = await OpenMail.openMailApp();

                            if (!result.didOpen && !result.canOpen) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No mail apps installed on this device.',
                                    ),
                                  ),
                                );
                              }
                            } else if (!result.didOpen && result.canOpen) {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Open Mail App"),
                                      content: const Text(
                                        "Please select your preferred email application:",
                                      ),
                                      actions: [
                                        ...result.options.map((app) {
                                          return TextButton(
                                            child: Text(app.name),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await OpenMail.openSpecificMailApp(
                                                app.name,
                                              );
                                            },
                                          );
                                        }),
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                          fontWeight: FontWeight.w600,
                          buttonTextFontSize: 18.spMin,
                        ),
                        20.verticalSpace,

                        // Manual Check Button
                        CustomButton.outlined(
                          text: 'I have verified my email',
                          onPressed: () async {
                            await ref
                                .read(authControllerProvider.notifier)
                                .checkSessionStatus();
                            if (context.mounted) {
                              final user = ref
                                  .read(authRepositoryProvider)
                                  .currentUser;
                              if (user != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Email confirmed! Welcome to SewSafe.',
                                    ),
                                    backgroundColor: AppColors.ready,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Verification pending. Please verify your email first.',
                                    ),
                                    backgroundColor: AppColors.notification,
                                  ),
                                );
                              }
                            }
                          },
                          fontWeight: FontWeight.w600,
                          buttonTextFontSize: 16.spMin,
                        ),
                        20.verticalSpace,

                        // OTP Toggle Link
                        CustomButton.text(
                          text: _showOtpField
                              ? 'Hide verification code entry'
                              : 'Received a code? Enter it manually',
                          onPressed: () {
                            setState(() {
                              _showOtpField = !_showOtpField;
                            });
                          },
                          buttonTextFontSize: 15.spMin,
                        ),
                        20.verticalSpace,

                        // Collapsible OTP Input Section
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _showOtpField
                              ? Column(
                                  children: [
                                    PinInput(
                                      pinController: _pinController,
                                      focusNode: _focusNode,
                                    ),
                                    30.verticalSpace,
                                    CustomButton(
                                      text: 'Verify Code',
                                      onPressed: () async {
                                        final pin = _pinController.text.trim();
                                        if (pin.length == 6) {
                                          await ref
                                              .read(
                                                authControllerProvider.notifier,
                                              )
                                              .verifySignUpOTP(
                                                widget.email,
                                                pin,
                                              );
                                          if (context.mounted) {
                                            final updatedState = ref.read(
                                              authControllerProvider,
                                            );
                                            if (!updatedState.hasError) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Email verified successfully!',
                                                  ),
                                                  backgroundColor:
                                                      AppColors.ready,
                                                ),
                                              );
                                            }
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please enter a 6-digit code.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      fontWeight: FontWeight.w600,
                                      buttonTextFontSize: 18.spMin,
                                    ),
                                    20.verticalSpace,
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        // Resend Email Button
                        CustomButton.text(
                          text: 'Resend Verification Email',
                          onPressed: () async {
                            await ref
                                .read(authControllerProvider.notifier)
                                .resendVerification(widget.email);
                            if (context.mounted) {
                              final updatedState = ref.read(
                                authControllerProvider,
                              );
                              if (!updatedState.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Verification email resent successfully!',
                                    ),
                                    backgroundColor: AppColors.ready,
                                  ),
                                );
                              }
                            }
                          },
                          buttonTextFontSize: 15.spMin,
                        ),
                        20.verticalSpace,

                        // Back to Login Link
                        TextButton(
                          onPressed: () => context.goNamed(AppRoute.login.name),
                          child: CustomText(
                            'Back to Login',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14.spMin,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        10.verticalSpace,
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
