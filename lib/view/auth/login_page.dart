import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/back_button_widget.dart';
import '../../controller/locale_controller.dart';
import 'register_page.dart';
import '../../controller/session_controller.dart';
import '../../controller/auth_controller.dart';
import '../delegate/delegate_terms_page.dart';
import '../../bindings/delegate_terms_binding.dart';
import '../../bindings/register_binding.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.put(AuthController());
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24.h),
              const Align(
                alignment: Alignment.centerLeft,
                child: BackButtonWidget(),
              ),
              SizedBox(height: 24.h),
              Container(
                width: 220.w,
                height: 220.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: 24.h),
              GetBuilder<LocaleController>(
                builder: (localeController) {
                  return MyText(
                    'login'.tr,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                  );
                },
              ),
              SizedBox(height: 24.h),
              GetBuilder<LocaleController>(
                builder: (localeController) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: MyText(
                      'phone_number'.tr,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10.r,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: GetBuilder<LocaleController>(
                  builder: (localeController) {
                    return TextField(
                      key: ValueKey(
                        'phone_field_${localeController.selectedLanguage.value}',
                      ),
                      controller: auth.phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'phone_number_hint'.tr,
                        hintStyle: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 18.sp,
                          fontFamily: 'Expo Arabic',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                      ),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: 'Expo Arabic',
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              GetBuilder<LocaleController>(
                builder: (localeController) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: MyText(
                      'password'.tr,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10.r,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: GetBuilder<LocaleController>(
                  builder: (localeController) {
                    return Obx(
                      () => TextField(
                        key: ValueKey(
                          'password_field_${localeController.selectedLanguage.value}',
                        ),
                        controller: auth.passwordCtrl,
                        obscureText: auth.obscurePassword.value,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'password_hint'.tr,
                          hintStyle: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 18.sp,
                            fontFamily: 'Expo Arabic',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 18.h,
                            horizontal: 20.w,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              auth.obscurePassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textSecondary,
                              size: 24.r,
                            ),
                            onPressed: () {
                              auth.obscurePassword.value =
                                  !auth.obscurePassword.value;
                            },
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: 'Expo Arabic',
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                height: 64.h,
                child: ElevatedButton(
                  onPressed: () => auth.login(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    elevation: 0,
                  ),
                  child: GetBuilder<LocaleController>(
                    builder: (localeController) {
                      return MyText(
                        'login'.tr,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // إخفاء "إنشاء الحساب" للسكرتير
              Builder(
                builder: (context) {
                  final SessionController session =
                      Get.find<SessionController>();
                  if (session.role.value == 'secretary') {
                    return const SizedBox.shrink();
                  }
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        if (session.role.value == 'delegate') {
                          Get.to(
                            () => const DelegateTermsPage(),
                            binding: DelegateTermsBinding(),
                          );
                        } else {
                          Get.to(
                            () => const RegisterPage(),
                            binding: RegisterBinding(),
                          );
                        }
                      },
                      child: GetBuilder<LocaleController>(
                        builder: (localeController) {
                          return RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Expo Arabic',
                                fontSize: 16.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: 'dont_have_account'.tr,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: 'create_account_now'.tr,
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
