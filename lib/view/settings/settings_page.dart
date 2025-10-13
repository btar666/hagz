import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
// import '../auth/login_page.dart';
import '../../controller/session_controller.dart';
import 'doctor_profile_manage_page.dart';
import 'working_hours_page.dart';
import 'holidays_page.dart';
import 'secretary_accounts_page.dart';
import '../appointments/past_appointments_page.dart';
import 'user_profile_edit_page.dart';
import 'change_password_page.dart';
import '../../bindings/change_password_binding.dart';
import '../onboarding/user_type_selection_page.dart';
import '../../widget/confirm_dialogs.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SessionController session = Get.find<SessionController>();
    final bool isDoctor = session.role.value == 'doctor';
    final bool isUser = session.role.value == 'user';
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
            if (isDoctor) ...[
              _buildSettingsItem(
                icon: Icons.person,
                title: 'إدارة حسابك الشخصي',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(() => DoctorProfileManagePage());
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.access_time,
                title: 'إدارة أوقات العمل',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(() => WorkingHoursPage());
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.beach_access,
                title: 'إدارة العطل',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(() => HolidaysPage());
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.people,
                title: 'إدارة حسابات السكرتارية',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(() => const SecretaryAccountsPage());
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.event_note_rounded,
                title: 'المواعيد السابقة',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(() => const PastAppointmentsPage());
                },
              ),
              SizedBox(height: 16.h),
            ],

            if (isUser) ...[
              _buildSettingsItem(
                icon: Icons.person,
                title: 'تعديل ملفك الشخصي',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(() => const UserProfileEditPage());
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.lock,
                title: 'تغيير كلمة السر',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(
                    () => const ChangePasswordPage(),
                    binding: ChangePasswordBinding(),
                  );
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.event_note_rounded,
                title: 'المواعيد السابقة',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(() => const PastAppointmentsPage());
                },
              ),
              SizedBox(height: 16.h),
            ],

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

            // Logout for all roles
            _buildSettingsItem(
              icon: Icons.logout,
              title: 'تسجيل الخروج',
              color: AppColors.secondary,
              onTap: () {
                showLogoutConfirmDialog(
                  context,
                  onConfirm: () {
                    session.clearSession();
                    Get.offAll(() => const UserTypeSelectionPage());
                  },
                );
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
