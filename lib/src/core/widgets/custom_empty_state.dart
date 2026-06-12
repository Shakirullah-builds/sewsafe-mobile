import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import your legacy kit!
import 'custom_text.dart';
import 'custom_button.dart';

class CustomEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final Color? titleColor;
  final double? titleHeight;
  final double? subtitleHeight;

  // Dual-slot visual system (just like your CustomButton!)
  final IconData? icon;
  final Widget? imageWidget;

  // The Call to Action
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const CustomEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.imageWidget,
    this.buttonText,
    this.onButtonPressed,
    this.subtitleColor,
    this.titleColor,
    this.titleHeight,
    this.subtitleHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centers it vertically
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. The Visual Layer
          if (imageWidget != null) ...[
            imageWidget!,
            24.verticalSpace,
          ] else if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(
                  alpha: 0.05,
                ), // Soft background bubble
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64.sp,
                color: theme.colorScheme.primary.withValues(
                  alpha: 0.5,
                ), // Muted primary color
              ),
            ),
            24.verticalSpace,
          ],

          // 2. The Text Layer
          CustomText(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: titleColor ?? theme.colorScheme.onSurface,
              fontSize: 26.spMin,
              fontWeight: FontWeight.w500,
              height: titleHeight ?? 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          12.verticalSpace,
          CustomText(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subtitleColor ?? theme.colorScheme.onPrimary,
              height: subtitleHeight,
              fontSize: 16.spMin,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          32.verticalSpace,
          // 3. The Action Layer (Only shows if a button text is provided)
          if (buttonText != null && onButtonPressed != null) ...[
            CustomButton(
              text: buttonText!,
              onPressed: onButtonPressed!,
              buttonTextFontSize: 16.spMin,
              width: 250.w, // Keep the button reasonably sized, not full width
              icon: Icons.add, // A nice default icon for empty state actions
            ),
          ],
        ],
      ),
    );
  }
}
