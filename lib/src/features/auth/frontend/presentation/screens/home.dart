import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/constants/app_icons.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_empty_state.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_svg.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/features/auth/backend/data/auth_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Get current authenticated user
    final authRepository = ref.watch(authRepositoryProvider);
    final user = authRepository.currentUser;
    final email = user?.email ?? '';

    // Cleanly extract and capitalize name from email, or fallback to 'Shakirullah'
    final String displayName = email.isNotEmpty
        ? email
              .split('@')
              .first
              .split('.')
              .map(
                (s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '',
              )
              .join(' ')
        : 'Fashion Designer';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26.r,
                    backgroundColor: AppColors.placeholder,
                    backgroundImage: const NetworkImage(
                      'https://avatars.githubusercontent.com/u/258787491?v=4',
                    ), // Profile avatar
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          _getGreeting(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16.spMin,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        2.verticalSpace,
                        CustomText(
                          displayName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 24.spMin,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell aligned at the extreme end
                  Badge(
                    padding: EdgeInsets.zero,
                    offset: const Offset(4, -4),
                    backgroundColor: AppColors.notification,
                    child: CustomSvg(
                      AppIcons.notificationBell,
                      width: 24.w,
                      height: 32.h,
                      color: AppColors.darkSlate,
                    ),
                  ),
                ],
              ),

              // 2. Empty State View
              Expanded(
                child: Center(
                  child: CustomEmptyState(
                    title: 'No clients or orders yet',
                    titleHeight: 1.2,
                    subtitleHeight: 1.4,
                    imageWidget: Container(
                      width: 140.r,
                      height: 140.r,
                      padding: EdgeInsets.all(24.r),
                      decoration: BoxDecoration(
                        color: AppColors.placeholder.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        width: 200.w,
                        height: 200.h,
                        AppIcons.measuringTape,
                        fit: BoxFit.contain,
                      ),
                    ),
                    buttonText: 'Add Your First Client',
                    onButtonPressed: () {
                      // Action for adding first client
                    },
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
