import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';

class CustomTabSwitcher extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final List<IconData>? icons;
  final ValueChanged<int> onChanged;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const CustomTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.labels,
    this.icons,
    required this.onChanged,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: margin,
      height: height ?? 48.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.placeholder.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = selectedIndex == index;
          final hasIcon = icons != null && icons!.length > index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? theme.scaffoldBackgroundColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasIcon) ...[
                      Icon(
                        icons![index],
                        color: isSelected ? theme.colorScheme.primary : AppColors.textBody,
                        size: 18.sp,
                      ),
                      6.horizontalSpace,
                    ],
                    CustomText(
                      labels[index],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.colorScheme.primary : AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
