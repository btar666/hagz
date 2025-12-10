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
import '../../controller/locale_controller.dart';
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
          'settings'.tr,
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
                title: 'manage_personal_account'.tr,
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
                title: 'manage_working_hours'.tr,
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
                title: 'manage_holidays'.tr,
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
                title: 'manage_secretary_accounts'.tr,
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
                title: 'appointment_sequence_menu'.tr,
                color: AppColors.primary,
                onTap: () {
                  Get.to(() => const AppointmentSequencePage());
                },
              ),
              SizedBox(height: 16.h),
              _buildSettingsItem(
                icon: Icons.event_note_rounded,
                title: 'all_appointments'.tr,
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
                title: 'edit_profile'.tr,
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
                title: 'change_password'.tr,
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
                title: 'all_appointments'.tr,
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
                title: 'edit_profile'.tr,
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
                title: 'change_password'.tr,
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
                title: 'edit_profile'.tr,
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
                title: 'change_password'.tr,
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
              title: 'change_language'.tr,
              color: AppColors.secondary,
              onTap: () {
                _showLanguageDialog(context);
              },
            ),
            SizedBox(height: 16.h),

            // About app
            _buildSettingsItem(
              icon: Icons.info,
              title: 'about_app'.tr,
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
              title: 'help'.tr,
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
              title: 'development_team'.tr,
              color: AppColors.secondary,
              onTap: () {
                // Handle development team
              },
            ),
            SizedBox(height: 32.h),

            // Logout for all roles
            _buildSettingsItem(
              icon: Icons.logout,
              title: 'logout'.tr,
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
            SizedBox(height: 16.h),

            // Delete account (red color)
            _buildSettingsItem(
              icon: Icons.delete,
              title: 'delete_account'.tr,
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
              child: Icon(icon, color: color, size: 24.sp),
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
    final currentLanguage = Get.locale?.languageCode ?? 'ar';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        // Use a ValueNotifier to hold the selected language state
        final selectedLanguageNotifier = ValueNotifier<String>(currentLanguage);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ValueListenableBuilder<String>(
            valueListenable: selectedLanguageNotifier,
            builder: (context, selectedLanguage, _) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FEFF),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        margin: EdgeInsets.only(bottom: 20.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    // Title
                    Text(
                      'select_language'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Expo Arabic',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Language options
                    _buildLanguageOption(
                      context: context,
                      languageCode: 'ar',
                      languageName: 'العربية',
                      isSelected: selectedLanguage == 'ar',
                      onTap: () {
                        selectedLanguageNotifier.value = 'ar';
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildLanguageOption(
                      context: context,
                      languageCode: 'en',
                      languageName: 'English',
                      isSelected: selectedLanguage == 'en',
                      onTap: () {
                        selectedLanguageNotifier.value = 'en';
                      },
                    ),
                    SizedBox(height: 24.h),
                    // Confirm button
                    ElevatedButton(
                      onPressed: () {
                        final finalLanguage = selectedLanguageNotifier.value;
                        Navigator.pop(context);

                        if (finalLanguage != currentLanguage) {
                          // Get the LocaleController and change language
                          final localeController = Get.find<LocaleController>();

                          // Change language (this will trigger updates)
                          localeController.changeLanguage(finalLanguage);

                          // Force immediate app update to refresh all pages
                          Get.forceAppUpdate();

                          // Use Future.microtask to ensure update happens after current frame
                          // This is especially important when switching to English
                          Future.microtask(() {
                            // Force another update to ensure all widgets rebuild
                            Get.forceAppUpdate();
                            localeController.update(['locale_builder']);
                            localeController.update();

                            // Additional update after a short delay to ensure English switch works
                            Future.delayed(
                              const Duration(milliseconds: 50),
                              () {
                                Get.forceAppUpdate();
                                localeController.update(['locale_builder']);
                                localeController.update();
                              },
                            );
                          });

                          // Show success message
                          Get.snackbar(
                            'success'.tr,
                            'language_changed'.tr,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'confirm'.tr,
                        style: TextStyle(
                          fontFamily: 'Expo Arabic',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          fontFamily: 'Expo Arabic',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Language name
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontFamily: 'Expo Arabic',
                  fontSize: 18.sp,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            // Radio indicator
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                  : null,
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
          'error'.tr,
          'error_loading_support_link'.tr,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error_opening_support_link'.tr,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }
  }
}
