import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/constants/app_icons.dart';
import 'package:sewsafe_mobile/src/core/route/app_route.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_svg.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_textform_field.dart';
import 'package:sewsafe_mobile/src/core/widgets/loading_overlay.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_button.dart';
import 'package:sewsafe_mobile/src/features/auth/presentation/widgets/auth_tab_switcher.dart';
import 'package:sewsafe_mobile/src/features/auth/presentation/widgets/footer_text.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  // 1. Removed 'final' so we can actually change it!
  bool _isLogin = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const bool isLoading = false;

    return GestureDetector(
      onTap: () => FocusScope.of(
        context,
      ).unfocus(), // TO - DO: Tapping the scaffold to remove the keyboard hasnt worked still
      child: Scaffold(
        body: LoadingOverlay(
          isLoading: isLoading,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
              child: Form(
                key: _formKey,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                CustomText(
                                  _isLogin ? 'Welcome!' : 'Create Account',
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontSize: 48.spMin,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                15.verticalSpace,
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 40.w,
                                    right: 40.w,
                                  ),
                                  child: CustomText(
                                    _isLogin
                                        ? 'Access your professional tailoring workspace.'
                                        : 'Secure measurement tracking for professional artisans',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 16.spMin,
                                      color: theme.colorScheme.onPrimary,
                                      fontFamily: GoogleFonts.lato().fontFamily,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          40.verticalSpace,

                          // 2. We pass the state AND the function to change the state down to the child
                          AuthTabSwitcher(
                            isLogin: _isLogin,
                            onToggle: (bool newValue) {
                              setState(() {
                                _isLogin =
                                    newValue; // This rebuilds the whole screen!
                              });
                            },
                          ),
                          40.verticalSpace,
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'princess@gmail.com',
                            keyboardType: TextInputType.emailAddress,
                            headerText: 'Email Address',
                          ),
                          20.verticalSpace,
                          CustomTextField(
                            controller: _passwordController,
                            hintText: '********',
                            obscureText: true,
                            suffixIcon: Icon(
                              Icons.visibility_off,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7), // Muted color for the icon
                            ),
                            headerText: 'Password',
                          ),

                          // 3. Smoothly hide Confirm Password if they are Logging in
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: _isLogin
                                ? const SizedBox.shrink() // Takes up zero space when logging in
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      20.verticalSpace,
                                      CustomTextField(
                                        controller: _confirmPasswordController,
                                        hintText: '********',
                                        headerText: 'Confirm Password',
                                        obscureText: true,
                                        suffixIcon: Icon(
                                          Icons.visibility_off,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7), // Muted color for the icon
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: _isLogin
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      10.verticalSpace,
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: CustomButton.text(
                                          text: 'Forgot password?',
                                          onPressed: () => context.pushNamed(
                                            AppRoute.forgotPassword.name,
                                          ),
                                          buttonTextFontSize: 14.spMin,
                                        ),
                                      ),
                                    ],
                                  ) // Takes up zero space when logging in
                                : const SizedBox.shrink(),
                          ),
                          20.verticalSpace,
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: theme.dividerTheme.color,
                                  thickness: theme.dividerTheme.thickness,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: CustomText(
                                  'or',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 15.spMin,
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: GoogleFonts.lato().fontFamily,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: theme.dividerTheme.color,
                                  thickness: theme.dividerTheme.thickness,
                                ),
                              ),
                            ],
                          ),
                          30.verticalSpace,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 60.w),
                            child: CustomButton(
                              text: _isLogin
                                  ? 'Continue with Google'
                                  : 'Sign up with Google',
                              backgroundColor: AppColors
                                  .placeholder, // Light grey from design
                              textColor: theme.colorScheme.onSurface,
                              iconWidget: CustomSvg(
                                AppIcons.google,
                                size: 40.sp,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          30.verticalSpace,
                          CustomButton(
                            text: _isLogin ? 'Login' : 'Continue',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Handle Auth
                              }
                            },
                            fontWeight: FontWeight.w700,
                            buttonTextFontSize: 18.spMin,
                          ),
                          20.verticalSpace,
                          Align(
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                text: _isLogin
                                    ? 'Don\'t have an account? '
                                    : 'Already have an account? ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14.spMin,
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: GoogleFonts.lato().fontFamily,
                                ),
                                children: [
                                  TextSpan(
                                    text: _isLogin ? 'Sign up' : 'Login',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 13.spMin,
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: GoogleFonts.lato().fontFamily,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        setState(() {
                                          _isLogin =
                                              !_isLogin; // Toggle the state
                                        });
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.all(20.h),
                          child: !_isLogin
                              ? const FooterText() // Show footer only on Sign-up
                              : const SizedBox.shrink(), // Takes up zero space when logging in
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
