import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/locale_controller.dart';
import '../auth/login_page.dart';
import '../../controller/session_controller.dart';

class UserTypeSelectionPage extends StatefulWidget {
  const UserTypeSelectionPage({super.key});

  @override
  State<UserTypeSelectionPage> createState() => _UserTypeSelectionPageState();
}

class _UserTypeSelectionPageState extends State<UserTypeSelectionPage> {
  List<String> get _roles => [
    'user_type'.tr,
    'doctor_type'.tr,
    'secretary_type'.tr,
    'delegate_type'.tr,
  ];
  int? _selectedIndex; // لا توجد قيمة افتراضية - المستخدم يجب أن يختار

  void _onNext() {
    // التحقق من أن المستخدم اختار نوعاً
    if (_selectedIndex == null) {
      Get.snackbar(
        'error'.tr,
        'please_select_user_type'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final session = Get.find<SessionController>();
    switch (_selectedIndex) {
      case 0:
        session.setRole('user');
        break;
      case 1:
        session.setRole('doctor');
        break;
      case 2:
        session.setRole('secretary');
        break;
      case 3:
        session.setRole('delegate');
        break;
    }
    Get.to(
      () => const LoginPage(),
      binding: BindingsBuilder(() {
        // LoginPage لا يحتاج binding خاص
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 24.h),
                      // top circle avatar - medicine icon
                      Container(
                        width: 240.w,
                        height: 240.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icons/home/medicine_icon.jpg',
                            width: 240.w,
                            height: 240.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 240.w,
                                height: 240.w,
                                color: const Color(0xFFD9D9D9),
                                child: const Icon(
                                  Icons.medical_services_outlined,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      GetBuilder<LocaleController>(
                        builder: (localeController) {
                          return MyText(
                            'select_user_type'.tr,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      SizedBox(height: 24.h),

                      // role buttons
                      GetBuilder<LocaleController>(
                        builder: (localeController) {
                          return Column(
                            children: List.generate(_roles.length, (index) {
                              final bool isSelected = index == _selectedIndex;
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(28.r),
                                  onTap: () =>
                                      setState(() => _selectedIndex = index),
                                  child: Container(
                                    height: 56.h,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.primaryLight.withOpacity(
                                              0.75,
                                            ),
                                      borderRadius: BorderRadius.circular(28.r),
                                    ),
                                    child: MyText(
                                      _roles[index],
                                      fontSize: 20.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),

                      SizedBox(height: 24.h),

                      // next button
                      SizedBox(
                        height: 56.h,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedIndex != null ? _onNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.textLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 12.w),
                              GetBuilder<LocaleController>(
                                builder: (localeController) {
                                  return MyText(
                                    'next'.tr,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w900,
                                    color: _selectedIndex != null
                                        ? Colors.white
                                        : Colors.white70,
                                  );
                                },
                              ),
                              Container(
                                width: 40.h,
                                height: 40.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.primary,
                                  size: 18.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
