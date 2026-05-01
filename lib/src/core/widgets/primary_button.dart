import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_text.dart'; // Import the text widget we just made!

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback?
  onPressed; // If null, the button is automatically disabled
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isLoading;
  final bool isOutlined; // Easily switch between filled and outlined buttons

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    // We grab the theme so we can gracefully fall back to your AppColors
    final theme = Theme.of(context);
    final defaultBgColor = backgroundColor ?? theme.colorScheme.primary;
    final defaultTextColor = textColor ?? Colors.white;

    // The content inside the button (Text, Icon + Text, or Loading Spinner)
    Widget buttonContent = isLoading
        ? SizedBox(
            height: 24.h,
            width: 24.h,
            child: CupertinoActivityIndicator(
              color: isOutlined ? defaultBgColor : defaultTextColor,
              radius: 12.r,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20.sp,
                  color: isOutlined ? defaultBgColor : defaultTextColor,
                ),
                SizedBox(width: 8.w),
              ],
              CustomText(
                text,
                color: isOutlined ? defaultBgColor : defaultTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ],
          );

    // Apply the correct button type (Outlined vs Elevated)
    return SizedBox(
      width:
          width ??
          double.infinity, // Defaults to full width (standard for mobile)
      height: height ?? 56.h,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: defaultBgColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius?.r ?? 8.r),
                ),
              ),
              child: buttonContent,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: defaultBgColor,
                // Only override the theme's border radius if one is explicitly passed
                shape: borderRadius != null
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius!.r),
                      )
                    : null,
              ),
              child: buttonContent,
            ),
    );
  }
}
