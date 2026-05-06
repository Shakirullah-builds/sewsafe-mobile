import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_text.dart';

/// Private enum to track the button type safely
enum _ButtonType { elevated, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? iconWidget;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isLoading;
  final double? buttonTextFontSize;
  final FontWeight? fontWeight;

  // 2. The private type tracker
  final _ButtonType _type;

  // 3. The Default Constructor (Elevated)
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconWidget,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.buttonTextFontSize,
    this.fontWeight,
  }) : _type = _ButtonType.elevated;

  // 4. The Outlined Constructor
  const CustomButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconWidget,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.buttonTextFontSize,
    this.fontWeight,
  }) : _type = _ButtonType.outlined;

  // 5. The Text Constructor
  const CustomButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconWidget,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.buttonTextFontSize,
    this.fontWeight,
  }) : _type = _ButtonType.text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultPrimaryColor = backgroundColor ?? theme.colorScheme.primary;

    // Text buttons usually use the primary color for their text, not white!
    final defaultTextColor =
        textColor ??
        (_type == _ButtonType.elevated ? Colors.white : defaultPrimaryColor);

    // The shared internal content (Loading Spinner or Text+Icon)
    Widget buttonContent = isLoading
        ? SizedBox(
            height: 24.h,
            width: 24.h,
            child: CupertinoActivityIndicator(
              color: defaultTextColor,
              radius: 15.r,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Check for the SVG / Widget first!
              if (iconWidget != null) ...[
                iconWidget!,
                8.horizontalSpace,
              ]
              // 2. If no widget, check for a standard native icon
              else if (icon != null) ...[
                Icon(icon, size: 20.sp, color: defaultTextColor),
                8.horizontalSpace,
              ],
              CustomText(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: defaultTextColor,
                  fontWeight: fontWeight ?? FontWeight.w500,
                  fontSize: buttonTextFontSize ?? 16.spMin,
                  fontFamily: GoogleFonts.lato().fontFamily,
                ),
              ),
            ],
          );

    final buttonWidth = width ?? double.infinity;
    final buttonHeight = height ?? 56.h;

    // 6. The Switch Statement to render the correct Flutter button
    switch (_type) {
      case _ButtonType.outlined:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: defaultPrimaryColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius?.r ?? 20.r),
              ),
            ),
            child: buttonContent,
          ),
        );

      case _ButtonType.text:
        return SizedBox(
          width:
              width, // Text buttons usually shouldn't be double.infinity by default
          height: height, // Let them size naturally unless specified
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              minimumSize: Size.zero, // No minimum size for text buttons
              
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: defaultPrimaryColor, // The ripple color
              padding: EdgeInsets.symmetric(vertical: 5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius?.r ?? 20.r),
              ),
            ),
            child: buttonContent,
          ),
        );

      case _ButtonType.elevated:
     // default:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: defaultPrimaryColor,
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
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'custom_text.dart'; // Import the text widget we just made!

// class PrimaryButton extends StatelessWidget {
//   final String text;
//   final VoidCallback?
//   onPressed; // If null, the button is automatically disabled
//   final IconData? icon;
//   final Color? backgroundColor;
//   final Color? textColor;
//   final double? width;
//   final double? height;
//   final double? borderRadius;
//   final bool isLoading;
//   final bool isOutlined; // Easily switch between filled and outlined buttons

//   const PrimaryButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.icon,
//     this.backgroundColor,
//     this.textColor,
//     this.width,
//     this.height,
//     this.borderRadius,
//     this.isLoading = false,
//     this.isOutlined = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // We grab the theme so we can gracefully fall back to your AppColors
//     final theme = Theme.of(context);
//     final defaultBgColor = backgroundColor ?? theme.colorScheme.primary;
//     final defaultTextColor = textColor ?? Colors.white;

//     // The content inside the button (Text, Icon + Text, or Loading Spinner)
//     Widget buttonContent = isLoading
//         ? SizedBox(
//             height: 24.h,
//             width: 24.h,
//             child: CupertinoActivityIndicator(
//               color: isOutlined ? defaultBgColor : defaultTextColor,
//               radius: 12.r,
//             ),
//           )
//         : Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (icon != null) ...[
//                 Icon(
//                   icon,
//                   size: 20.sp,
//                   color: isOutlined ? defaultBgColor : defaultTextColor,
//                 ),
//                 SizedBox(width: 8.w),
//               ],
//               CustomText(
//                 text,
//                 color: isOutlined ? defaultBgColor : defaultTextColor,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16.sp,
//               ),
//             ],
//           );

//     // Apply the correct button type (Outlined vs Elevated)
//     return SizedBox(
//       width:
//           width ??
//           double.infinity, // Defaults to full width (standard for mobile)
//       height: height ?? 56.h,
//       child: isOutlined
//           ? OutlinedButton(
//               onPressed: isLoading ? null : onPressed,
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: defaultBgColor, width: 1.5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(borderRadius?.r ?? 8.r),
//                 ),
//               ),
//               child: buttonContent,
//             )
//           : ElevatedButton(
//               onPressed: isLoading ? null : onPressed,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: defaultBgColor,
//                 // Only override the theme's border radius if one is explicitly passed
//                 shape: borderRadius != null
//                     ? RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(borderRadius!.r),
//                       )
//                     : null,
//               ),
//               child: buttonContent,
//             ),
//     );
//   }
// }
