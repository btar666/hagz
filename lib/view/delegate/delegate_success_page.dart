import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../onboarding/user_type_selection_page.dart';

class DelegateSuccessPage extends StatelessWidget {
  const DelegateSuccessPage({super.key});

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
              SizedBox(height: 40.h),
              MyText(
                'بانتظار الموافقة ..',
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60.h),
              Container(
                width: 110.w,
                height: 110.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F5F8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.secondary,
                  size: 56.sp,
                ),
              ),
              SizedBox(height: 24.h),
              MyText(
                'تم التسجيل بنجاح !',
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 8.h),
              MyText(
                'بانتظار الموافقة على طلبك ..',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
              const Spacer(),
              SizedBox(
                height: 56.h,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      Get.offAll(() => const UserTypeSelectionPage()),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: const Text('العودة إلى البداية'),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
