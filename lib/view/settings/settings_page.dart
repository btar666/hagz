import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
// import '../auth/login_page.dart';
import '../../controller/session_controller.dart';
import '../../controller/doctor_profile_manage_controller.dart';
import 'doctor_profile_manage_page.dart';
import 'working_hours_page.dart';
import 'holidays_page.dart';
import 'secretary_accounts_page.dart';
import '../appointments/past_appointments_page.dart';
import '../appointments/appointment_sequence_page.dart';
import 'user_profile_edit_page.dart';
import 'change_password_page.dart';
import '../../bindings/change_password_binding.dart';
import '../onboarding/user_type_selection_page.dart';
import '../../widget/confirm_dialogs.dart';
import '../secretary/secretary_profile_edit_page.dart';
import '../delegate/delegate_profile_edit_page.dart';
import '../../widget/animated_pressable.dart';
import 'about_page.dart';
import '../../controller/about_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SessionController session = Get.find<SessionController>();
    final bool isDoctor = session.role.value == 'doctor';
    final bool isUser = session.role.value == 'user';
    final bool isSecretary = session.role.value == 'secretary';
    final bool isDelegate = session.role.value == 'delegate';
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
                  Get.to(
                    () => const DoctorProfileManagePage(),
                    binding: BindingsBuilder(() {
                      Get.put(DoctorProfileManageController());
                    }),
                  );
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.access_time,
                title: 'إدارة أوقات العمل',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(
                    () => WorkingHoursPage(),
                    binding: BindingsBuilder(() {
                      // يمكن إضافة WorkingHoursController هنا إذا لزم الأمر
                    }),
                  );
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.beach_access,
                title: 'إدارة العطل',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(
                    () => HolidaysPage(),
                    binding: BindingsBuilder(() {
                      // يمكن إضافة HolidaysController هنا إذا لزم الأمر
                    }),
                  );
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.people,
                title: 'إدارة حسابات السكرتارية',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(
                    () => const SecretaryAccountsPage(),
                    binding: BindingsBuilder(() {
                      // يمكن إضافة SecretaryAccountsController هنا إذا لزم الأمر
                    }),
                  );
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.format_list_numbered_rounded,
                title: 'تسلسل المواعيد',
                color: AppColors.primary,
                onTap: () {
                  Get.to(() => const AppointmentSequencePage());
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.event_note_rounded,
                title: 'كل المواعيد',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(
                    () => const PastAppointmentsPage(),
                    binding: BindingsBuilder(() {
                      // يمكن إضافة PastAppointmentsController هنا إذا لزم الأمر
                    }),
                  );
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
                  Get.to(
                    () => const UserProfileEditPage(),
                    binding: BindingsBuilder(() {
                      // يمكن إضافة UserProfileEditController هنا إذا لزم الأمر
                    }),
                  );
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
                title: 'كل المواعيد',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(
                    () => const PastAppointmentsPage(),
                    binding: BindingsBuilder(() {
                      // يمكن إضافة PastAppointmentsController هنا إذا لزم الأمر
                    }),
                  );
                },
              ),
              SizedBox(height: 16.h),
            ],

            if (isSecretary) ...[
              _buildSettingsItem(
                icon: Icons.person,
                title: 'تعديل الملف الشخصي',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(
                    () => const SecretaryProfileEditPage(),
                    binding: BindingsBuilder(() {
                      // يمكن إضافة SecretaryProfileEditController هنا إذا لزم الأمر
                    }),
                  );
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
            ],

            if (isDelegate) ...[
              _buildSettingsItem(
                icon: Icons.person,
                title: 'تعديل الملف الشخصي',
                color: AppColors.secondary,
                onTap: () {
                  Get.to(
                    () => const DelegateProfileEditPage(),
                    binding: BindingsBuilder(() {
                      // يمكن إضافة DelegateProfileEditController هنا إذا لزم الأمر
                    }),
                  );
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
                Get.to(
                  () => const AboutPage(),
                  binding: BindingsBuilder(() {
                    Get.put(AboutController());
                  }),
                );
              },
            ),
            SizedBox(height: 16.h),

            // Help
            _buildSettingsItem(
              icon: Icons.help,
              title: 'المساعدة',
              color: AppColors.secondary,
              onTap: () async {
                // Get support link from AboutController or use default
                final aboutController = Get.put(AboutController());
                await aboutController.loadAboutInfo();
                if (aboutController.supportLink.value.isNotEmpty) {
                  await _openSupportLink(aboutController.supportLink.value);
                } else {
                  // Default support link if not loaded
                  await _openSupportLink('https://wa.me/9647801275675');
                }
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
    return AnimatedPressable(
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
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textLight,
              size: 16.sp,
            ),
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

  Future<void> _openSupportLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'خطأ',
          'لا يمكن فتح رابط الدعم',
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء فتح رابط الدعم',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }
  }
}
