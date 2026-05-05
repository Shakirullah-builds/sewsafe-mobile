import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewsafe_mobile/src/core/constants/app_icons.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_empty_state.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_svg.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: const NetworkImage(
                        'https://avatars.githubusercontent.com/u/258787491?v=4',), // Placeholder avatar
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          'Good Morning,',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 24.spMin,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        CustomText(
                          'Shakirullah',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 24.spMin,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomSvg(
                    AppIcons.notificationBell,
                    width: 24.w,
                    height: 32.h,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
              const Expanded(
                child: Center(
                  child: CustomEmptyState(
                    title: 'No clients or orders yet',
                    subtitle:
                        'Your journey to never losing a measurement starts here.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
