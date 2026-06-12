import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/presentation/screens/home.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PlaceholderScreen(title: 'Clients', icon: Icons.people_outline),
    const PlaceholderScreen(title: 'Orders', icon: Icons.inventory_2_outlined),
    const PlaceholderScreen(title: 'Settings', icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: Container(
        height: 60.r,
        width: 60.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Action for FAB
          },
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const CircleBorder(),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 28.spMin,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surfaceWhite,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.r,
        elevation: 10,
        height: 72.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              activeIcon: Icons.home,
              inactiveIcon: Icons.home_outlined,
              label: 'Home',
              theme: theme,
            ),
            _buildNavItem(
              index: 1,
              activeIcon: Icons.people,
              inactiveIcon: Icons.people_outlined,
              label: 'Clients',
              theme: theme,
            ),
            SizedBox(width: 48.w), // Clear space for center FAB
            _buildNavItem(
              index: 2,
              activeIcon: Icons.inventory_2,
              inactiveIcon: Icons.inventory_2_outlined,
              label: 'Orders',
              theme: theme,
            ),
            _buildNavItem(
              index: 3,
              activeIcon: Icons.settings,
              inactiveIcon: Icons.settings_outlined,
              label: 'Settings',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required ThemeData theme,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textPrimary;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: color,
              size: 24.spMin,
            ),
            2.verticalSpace,
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12.spMin,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: AppColors.placeholder.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              16.verticalSpace,
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 22.spMin,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.verticalSpace,
              Text(
                'This feature is coming soon.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.spMin,
                  color: AppColors.textBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
