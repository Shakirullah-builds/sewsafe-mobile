import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewsafe_mobile/src/core/constants/app_colors.dart';
import 'package:sewsafe_mobile/src/core/constants/app_icons.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_button.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_svg.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_text.dart';
import 'package:sewsafe_mobile/src/features/auth/backend/data/auth_repository.dart';
import 'package:sewsafe_mobile/src/features/auth/frontend/application/auth_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoBackup = true;
  bool _isBackingUp = false;
  String _lastSyncedText = "All data secured. Last synced: 2 hours ago";
  String _selectedUnit = "Inches (in)";
  String _selectedGender = "Unisex";

  void _triggerBackupNow() async {
    if (_isBackingUp) return;

    setState(() {
      _isBackingUp = true;
    });

    // Simulate database backup network latency
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isBackingUp = false;
        _lastSyncedText = "All data secured. Last synced: Just now";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(
            "Cloud backup completed successfully!",
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showUnitSelector() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: CustomText(
          'Select Measurement Unit',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.spMin,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: CustomText(
              'Inches (in)',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16.spMin,
              ),
            ),
            onPressed: () {
              setState(() => _selectedUnit = "Inches (in)");
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: CustomText(
              'Centimeters (cm)',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16.spMin,
              ),
            ),
            onPressed: () {
              setState(() => _selectedUnit = "Centimeters (cm)");
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: CustomText(
            'Cancel',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.red[600],
              fontWeight: FontWeight.bold,
              fontSize: 16.spMin,
            ),
          ),
        ),
      ),
    );
  }

  void _showGenderSelector() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: CustomText(
          'Select Default Gender',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.spMin,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: CustomText(
              'Unisex',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16.spMin,
              ),
            ),
            onPressed: () {
              setState(() => _selectedGender = "Unisex");
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: CustomText(
              'Male',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16.spMin,
              ),
            ),
            onPressed: () {
              setState(() => _selectedGender = "Male");
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: CustomText(
              'Female',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16.spMin,
              ),
            ),
            onPressed: () {
              setState(() => _selectedGender = "Female");
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: CustomText(
            'Cancel',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.red[600],
              fontWeight: FontWeight.bold,
              fontSize: 16.spMin,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            'Sign Out',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'Are you sure you want to sign out of your account?',
              style: GoogleFonts.plusJakartaSans(fontSize: 13.spMin),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(
                'Sign Out',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // pop confirm dialog

                // Show loading spinner
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                await ref.read(authControllerProvider.notifier).logout();

                if (context.mounted) {
                  Navigator.of(context).pop(); // pop loading spinner
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final email = user?.email ?? 'tailor@sewsafe.com';
    final name = email.split('@').first;
    final displayName = '${name[0].toUpperCase()}${name.substring(1)} Designs';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    'Settings',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28.spMin,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: CustomText(
                            'No new notifications',
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                    icon: CustomSvg(
                      AppIcons.notificationBell,
                      size: 24.r,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              24.verticalSpace,

              // 2. Profile Card
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.placeholder.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    // Dynamic Initials Avatar
                    Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CustomText(
                          name[0].toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20.spMin,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    16.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            displayName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.spMin,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          4.verticalSpace,
                          CustomText(
                            'Professional Account',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.spMin,
                              color: AppColors.textBody,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Visual placeholder Edit Profile button using UI Kit CustomButton
                    CustomButton.outlined(
                      text: 'Edit Profile',
                      width: 96.w,
                      height: 36.h,
                      borderRadius: 20.r,
                      buttonTextFontSize: 12.spMin,
                      fontWeight: FontWeight.bold,
                      backgroundColor: AppColors.primary,
                      textColor: AppColors.primary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: CustomText(
                              'Edit Profile coming soon!',
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              24.verticalSpace,

              // 3. Data & Backup Section
              _SettingsSection(
                title: 'DATA & BACKUP',
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_done_outlined,
                              color: Colors.green[600],
                              size: 24.r,
                            ),
                          ),
                          16.horizontalSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  'Cloud Sync Status',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.spMin,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                4.verticalSpace,
                                CustomText(
                                  _lastSyncedText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.spMin,
                                    color: AppColors.textBody,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: CustomButton(
                        text: 'Backup Now',
                        icon: Icons.backup_outlined,
                        isLoading: _isBackingUp,
                        backgroundColor: AppColors.primary,
                        height: 48.h,
                        borderRadius: 12.r,
                        onPressed: _triggerBackupNow,
                      ),
                    ),
                    12.verticalSpace,
                    const Divider(height: 1, color: AppColors.placeholder),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sync,
                                color: AppColors.textBody,
                                size: 20.r,
                              ),
                              12.horizontalSpace,
                              CustomText(
                                'Auto-backup',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.spMin,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          CupertinoSwitch(
                            value: _autoBackup,
                            activeTrackColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() => _autoBackup = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              24.verticalSpace,

              // 4. Customization Section
              _SettingsSection(
                title: 'CUSTOMIZATION',
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.straighten_outlined,
                      title: 'Measurement Units',
                      value: _selectedUnit,
                      onTap: _showUnitSelector,
                    ),
                    const Divider(height: 1, color: AppColors.placeholder),
                    _SettingsTile(
                      icon: Icons.person_outline,
                      title: 'Default Gender',
                      value: _selectedGender,
                      onTap: _showGenderSelector,
                    ),
                  ],
                ),
              ),
              24.verticalSpace,

              // 5. Support Section
              _SettingsSection(
                title: 'SUPPORT',
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      trailingIcon: Icons.open_in_new,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: CustomText(
                              'Launching Help Center...',
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.placeholder),
                    _SettingsTile(
                      icon: Icons.mail_outline,
                      title: 'Contact Us',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: CustomText(
                              'Opening contact form...',
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              24.verticalSpace,

              // 6. Destructive Sign Out Card
              _SettingsSection(
                title: 'ACCOUNT ACTIONS',
                child: _SettingsTile(
                  icon: Icons.logout_outlined,
                  title: 'Sign Out',
                  color: Colors.red[600],
                  onTap: _confirmSignOut,
                ),
              ),
              36.verticalSpace,

              // 7. Footer Version
              Center(
                child: CustomText(
                  'SEWSAFE V2.4.0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.spMin,
                    color: AppColors.textBody.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              8.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: CustomText(
                      'Privacy Policy',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.spMin,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CustomText(
                    '  ·  ',
                    style: TextStyle(
                      color: AppColors.textBody.withValues(alpha: 0.5),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: CustomText(
                      'Terms of Service',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.spMin,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              24.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

/// Private reusable Section Card wrapper to maintain architectural consistency
class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: CustomText(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.spMin,
              fontWeight: FontWeight.bold,
              color: AppColors.textBody.withValues(alpha: 0.8),
              letterSpacing: 1.0,
            ),
          ),
        ),
        8.verticalSpace,
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.placeholder.withValues(alpha: 0.8),
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

/// Private reusable Settings Row item mapping to visual frames
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final IconData trailingIcon;
  final Color? color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    this.trailingIcon = Icons.chevron_right,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = color ?? AppColors.textSecondary;
    final iconColor = color ?? AppColors.textBody;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20.r),
              12.horizontalSpace,
              Expanded(
                child: CustomText(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),
              if (value != null) ...[
                CustomText(
                  value!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.spMin,
                    color: AppColors.textBody,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                4.horizontalSpace,
              ],
              Icon(
                trailingIcon,
                color:
                    color?.withValues(alpha: 0.5) ??
                    AppColors.textBody.withValues(alpha: 0.4),
                size: 20.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
