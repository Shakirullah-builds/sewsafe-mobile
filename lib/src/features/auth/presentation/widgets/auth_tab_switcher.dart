import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';

class AuthTabSwitcher extends StatelessWidget {
  final bool isLogin;
  final ValueChanged<bool> onToggle; // This is the secret sauce!

  const AuthTabSwitcher({
    super.key,
    required this.isLogin,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),

      child: Container(
        height: 48.h,
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Sign-Up Tab
            Expanded(
              child: GestureDetector(
                // When tapped, tell the parent to set isLogin to FALSE
                onTap: () => onToggle(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !isLogin ? theme.colorScheme.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: !isLogin
                        ? [
                            const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: CustomText(
                    'Sign-up',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14.spMin,
                       fontFamily: GoogleFonts.lato().fontFamily,
                    fontWeight: !isLogin ? FontWeight.bold : FontWeight.normal,
                    color: !isLogin
                        ? theme.colorScheme.primary
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            ),
            // Login Tab
            Expanded(
              child: GestureDetector(
                // When tapped, tell the parent to set isLogin to TRUE
                onTap: () => onToggle(true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isLogin ? theme.colorScheme.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: isLogin
                        ? [
                            const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: CustomText(
                    'Login',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14.spMin,
                       fontFamily: GoogleFonts.lato().fontFamily,
                      fontWeight: isLogin ? FontWeight.bold : FontWeight.normal,
                      color: isLogin
                        ? theme.colorScheme.primary
                        : Colors.grey.shade600,
                    ),
                    // fontWeight: isLogin ? FontWeight.bold : FontWeight.normal,
                    // color: isLogin
                    //     ? theme.colorScheme.primary
                    //     : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
