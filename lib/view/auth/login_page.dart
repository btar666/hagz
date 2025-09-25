import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import 'register_page.dart';
import '../main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 48.h,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                ),
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
              MyText(
                'تسجيل الدخول',
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
              ),
              SizedBox(height: 24.h),
              Align(
                alignment: Alignment.centerRight,
                child: MyText(
                  'رقم الهاتف',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.right,
                ),
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
                child: TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0000 000 0000',
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
                  style: TextStyle(fontSize: 18.sp, fontFamily: 'Expo Arabic'),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                height: 64.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Here we could branch to different initial pages per role if needed.
                    // For now, both roles land on MainPage; role affects visible items.
                    // role already set in SessionController from user type selection
                    Get.offAll(() => const MainPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    elevation: 0,
                  ),
                  child: MyText(
                    'تسجيل الدخول',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: GestureDetector(
                  onTap: () => Get.to(() => const RegisterPage()),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Expo Arabic',
                        fontSize: 16.sp,
                      ),
                      children: [
                        TextSpan(
                          text: 'ليس لديك حساب؟ ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: 'أنشئ حسابك الآن',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
