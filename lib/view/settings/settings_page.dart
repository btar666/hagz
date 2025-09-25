import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../auth/login_page.dart';
import '../../widget/confirm_dialogs.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الإعدادات',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Language change
            _buildSettingsItem(
              icon: Icons.language,
              title: 'تغيير اللغة',
              color: AppColors.secondary,
              onTap: () {
                _showLanguageDialog(context);
              },
            ),
            SizedBox(height: 16.h),

            // About app
            _buildSettingsItem(
              icon: Icons.info,
              title: 'حول التطبيق',
              color: AppColors.secondary,
              onTap: () {
                // Handle about app
              },
            ),
            SizedBox(height: 16.h),

            // Help
            _buildSettingsItem(
              icon: Icons.help,
              title: 'المساعدة',
              color: AppColors.secondary,
              onTap: () {
                // Handle help
              },
            ),
            SizedBox(height: 16.h),

            // Development team
            _buildSettingsItem(
              icon: Icons.code,
              title: 'فريق التطوير',
              color: AppColors.secondary,
              onTap: () {
                // Handle development team
              },
            ),
            SizedBox(height: 16.h),

            // Login
            _buildSettingsItem(
              icon: Icons.login,
              title: 'تسجيل الدخول',
              color: AppColors.secondary,
              onTap: () {
                Get.to(() => const LoginPage());
              },
            ),
            SizedBox(height: 32.h),

            // Delete account (red color)
            _buildSettingsItem(
              icon: Icons.delete,
              title: 'حذف الحساب',
              color: AppColors.error,
              onTap: () {
                _showDeleteAccountDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 16.w),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Arrow
            Icon(Icons.arrow_back_ios, color: AppColors.textLight, size: 16.sp),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('العربية'),
              leading: Radio(
                value: 'ar',
                groupValue: 'ar',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio(
                value: 'en',
                groupValue: 'ar',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed logout UI in this version; keep helper available when needed.

  void _showDeleteAccountDialog(BuildContext context) {
    showDeleteAccountConfirmDialog(
      context,
      onConfirm: () {
        // TODO: Handle account deletion
      },
    );
  }
}
