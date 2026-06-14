import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewsafe_mobile/src/core/widgets/custom_tab_switcher.dart';

class AuthTabSwitcher extends StatelessWidget {
  final bool isLogin;
  final ValueChanged<bool> onToggle;

  const AuthTabSwitcher({
    super.key,
    required this.isLogin,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: CustomTabSwitcher(
        selectedIndex: isLogin ? 1 : 0,
        labels: const ['Sign-up', 'Login'],
        onChanged: (index) {
          onToggle(index == 1);
        },
      ),
    );
  }
}
