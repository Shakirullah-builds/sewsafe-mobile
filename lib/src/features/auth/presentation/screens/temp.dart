// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
// import 'package:sewsafe_mobile/src/core/widgets/custom_textform_field.dart';
// import 'package:sewsafe_mobile/src/core/widgets/loading_overlay.dart';
// import 'package:sewsafe_mobile/src/core/widgets/primary_button.dart';
// import 'package:sewsafe_mobile/src/features/auth/presentation/widgets/auth_tab_switcher.dart';

// class SignUpScreen extends ConsumerStatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends ConsumerState<SignUpScreen> {
//   // For tab switcher toggle
//   final bool _isLogin = false; // Defaults to sign up
//   bool _isLogin = false; // Defaults to sign up

//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   // To avoid memory leaks
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     const bool isLoading = false;

//     return Scaffold(
//       body: LoadingOverlay(
//         isLoading: isLoading,
//         child: SafeArea(
//           child: Padding(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Align(
//                   alignment: Alignment.center,
//                   child: Column(
//                     children: [
//                       CustomText(
//                         _isLogin ? 'Welcome Back!' : 'Create Account',
//                         style: theme.textTheme.displayLarge?.copyWith(
//                           fontSize: 48.spMin,
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Align(
//                     alignment: Alignment.center,
//                     child: Column(
//                       children: [
//                         CustomText(
//                           _isLogin ? 'Welcome Back!' : 'Create Account',
//                           style: theme.textTheme.displayLarge?.copyWith(
//                             fontSize: 40.spMin,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         15.verticalSpace,
//                         Padding(
//                           padding: EdgeInsets.only(left: 40.w, right: 40.w),
//                           child: CustomText(
//                             _isLogin
//                                 ? 'Log in to access your measurements'
//                                 : 'Secure measurement tracking for professional artisans',
//                             textAlign: TextAlign.center,
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontSize: 16.spMin,
//                               fontFamily: GoogleFonts.lato().fontFamily,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   30.verticalSpace,
//                   // Note: In a real implementation, you might pass a callback to AuthTabSwitcher
//                   // to sync _isLogin. For now, we follow the UI structure.
//                   const AuthTabSwitcher(),
//                   30.verticalSpace,
//                   CustomTextField(
//                     controller: _emailController,
//                     hintText: 'princess@yahoo.com',
//                     keyboardType: TextInputType.emailAddress,
//                     headerText: 'Email Address',
//                   ),
//                   15.verticalSpace,
//                   CustomTextField(
//                     controller: _passwordController,
//                     hintText: '********',
//                     obscureText: true,
//                     suffixIcon: const Icon(Icons.remove_red_eye),
//                     headerText: 'Password',
//                   ),
//                   if (!_isLogin) ...[
//                     15.verticalSpace,
//                     CustomTextField(
//                       controller: _confirmPasswordController,
//                       hintText: '********',
//                       obscureText: true,
//                       headerText: 'Confirm Password',
//                     ),
//                   ],
//                   if (_isLogin) ...[
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {},
//                         child: const CustomText(
//                           'Forgot Password?',
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       15.verticalSpace,
//                       Padding(
//                         padding: EdgeInsets.only(left: 40.w, right: 40.w),
//                     ),
//                   ],
//                   30.verticalSpace,
//                   PrimaryButton(
//                     text: _isLogin ? 'Login' : 'Create Account',
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         // Handle Auth
//                       }
//                     },
//                   ),
//                   if (!_isLogin) ...[
//                     20.verticalSpace,
//                     Center(
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 20.w),
//                         child: CustomText(
//                           _isLogin
//                               ? 'Log in to access your measurements'
//                               : 'Secure measurement tracking for professonal artisans',
//                           'By signing up, you agree to our Terms of Service and Privacy Policy',
//                           textAlign: TextAlign.center,
//                           style: theme.textTheme.bodyLarge?.copyWith(
//                             fontSize: 16.spMin,
//                             fontFamily: GoogleFonts.lato().fontFamily,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           fontSize: 12.sp,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 30.verticalSpace,
//                 const AuthTabSwitcher(),
//                 30.verticalSpace,
//                 CustomTextField(
//                   controller: _emailController,
//                   hintText: 'princess@yahoo.com',
//                   keyboardType: TextInputType.emailAddress,
//                   headerText: 'Email Address',
//                 ),
//                 15.verticalSpace,
//                 CustomTextField(
//                   controller: _passwordController,
//                   hintText: '********',
//                   obscureText: true,
//                   suffixIcon: const Icon(Icons.remove_red_eye),
//                   headerText: 'Password',
//                 ),
//                 15.verticalSpace,
//                 CustomTextField(controller: _confirmPasswordController, hintText: '********', headerText: 'Confirm Password',)
//               ],
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // class AuthTabSwitcher extends StatelessWidget {
// // AuthTabSwitcher({super.key});




/*

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Make sure to import your legacy UI kit widgets here!
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_overlay.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // 1. The Master Toggle State
  bool _isLogin = false; // Defaults to Sign-up based on your design

  // 2. Form Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    final isLoading = false; // Will hook to Riverpod later

    return Scaffold(
      body: LoadingOverlay(
        isLoading: isLoading,
        child: SafeArea(
          child: SingleChildScrollView( // Allows scrolling if keyboard pops up
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                
                // 3. Dynamic Headers
                CustomText(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  style: theme.textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  _isLogin 
                      ? 'Log in to access your measurements' 
                      : 'Secure measurement tracking for\nprofessional artisans',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                  height: 1.5,
                ),
                SizedBox(height: 32.h),

                // 4. The Custom Tab Switcher
                _buildTabSwitcher(theme),
                SizedBox(height: 32.h),

                // 5. Dynamic Form Fields
                CustomText('Email Address', style: theme.textTheme.labelMedium),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'princess@yahoo.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.h),

                CustomText('Password', style: theme.textTheme.labelMedium),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: _passwordController,
                  hintText: '********',
                  obscureText: true,
                  suffixIcon: Icon(Icons.visibility_off, color: Colors.grey),
                ),
                
                // Smoothly animate the Confirm Password field in and out
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isLogin ? const SizedBox.shrink() : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 16.h),
                      CustomText('Confirm Password', style: theme.textTheme.labelMedium),
                      SizedBox(height: 8.h),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: '********',
                        obscureText: true,
                        suffixIcon: Icon(Icons.visibility_off, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // 6. The "OR" Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: CustomText('or', style: theme.textTheme.bodyMedium),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                  ],
                ),
                SizedBox(height: 24.h),

                // 7. Social Login & Main Action
                CustomButton(
                  text: 'Sign up with Google',
                  backgroundColor: Color(0xFFF1F5F9), // Light grey from design
                  textColor: Colors.black87,
                  icon: Icons.g_mobiledata, // Replace with SVG Google Icon later
                  onPressed: () {},
                ),
                SizedBox(height: 16.h),

                CustomButton(
                  text: _isLogin ? 'Login' : 'Continue',
                  onPressed: () {
                    print(_isLogin ? "Processing Login..." : "Processing Signup...");
                  },
                ),
                SizedBox(height: 24.h),

                // 8. Bottom Text Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      _isLogin ? "Don't have an account? " : "Already have an account? ",
                      style: theme.textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin; // Flips the state!
                        });
                      },
                      child: CustomText(
                        _isLogin ? "Sign up" : "Login",
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER METHOD: The Custom Tab Switcher ---
  Widget _buildTabSwitcher(ThemeData theme) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0), // The light blue/grey background
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Sign-Up Tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !_isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: !_isLogin ? [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ] : [],
                ),
                child: CustomText(
                  'Sign-up',
                  fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal,
                  color: !_isLogin ? theme.colorScheme.primary : Colors.grey.shade600,
                ),
              ),
            ),
          ),
          // Login Tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: _isLogin ? [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ] : [],
                ),
                child: CustomText(
                  'Login',
                  fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal,
                  color: _isLogin ? theme.colorScheme.primary : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

*/