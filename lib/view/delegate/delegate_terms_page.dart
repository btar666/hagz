import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import 'delegate_register_page.dart';
import '../../bindings/delegate_register_binding.dart';

class DelegateTermsPage extends StatelessWidget {
  const DelegateTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () => Get.back(),
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
                'شروط العمل',
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              const Spacer(),
              SizedBox(
                height: 64.h,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(
                    () => const DelegateRegisterPage(),
                    binding: DelegateRegisterBinding(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    elevation: 0,
                  ),
                  child: MyText(
                    'التالي',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
