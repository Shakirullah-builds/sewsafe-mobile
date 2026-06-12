import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';

class FooterText extends StatelessWidget {
  const FooterText({
    super.key,
  });

@override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text.rich(
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        fontSize: 10.spMin,
        fontWeight: FontWeight.w400,
        color: AppColors.footerText,
        //height: 1.5,
      ),
      TextSpan(
        text: 'By continuing, you agree to our ',
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              fontSize: 11.spMin,
              height: 1.63.h,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                debugPrint('Navigate to Terms'); // Add navigation later
              },
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy.\n',
            style: TextStyle(
              fontSize: 11.spMin,
              height: 1.63.h,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                debugPrint('Navigate to Privacy'); // Add navigation later
              },
          ),
          const TextSpan(
            text: 'All measurements are encrypted.',
            //style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}