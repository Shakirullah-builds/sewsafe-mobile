import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvg extends StatelessWidget {
  final String path;
  final Color? color;
  final double? size; // Used for perfect squares (most common for icons)
  final double? width; // Used if the SVG is a rectangle
  final double? height;

  const CustomSvg(
    this.path, {
    super.key,
    this.color,
    this.size,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      // If size is provided, use it for both width and height. Otherwise, check specific width/height.
      width: size?.w ?? width?.w,
      height: size?.h ?? height?.h,
      // Only apply the color filter if a color is explicitly passed!
      // This allows multi-colored SVGs (like the Google logo) to keep their original colors.
      colorFilter: color != null 
          ? ColorFilter.mode(color!, BlendMode.srcIn) 
          : null,
      fit: BoxFit.contain,
    );
  }
}