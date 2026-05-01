import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool? softWrap;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height; // Added height for Figma line-height compatibility

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.softWrap,
    this.decoration,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // 1. The Magic Fallback:
    // If you don't provide a style, it asks the AppTheme for bodyMedium.
    // This removes the need for ANY hardcoded local typography imports!
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      // Leaving maxLines and overflow as null by default allows text to wrap naturally!
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap ?? true,
      style: baseStyle.copyWith(
        color: color,
        // Only apply ScreenUtil if you are explicitly overriding the font size here
        fontSize: fontSize?.sp,
        fontWeight: fontWeight,
        decoration: decoration,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
      ),
    );
  }
}