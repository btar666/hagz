import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../auth/login_page.dart';

class UserTypeSelectionPage extends StatefulWidget {
  const UserTypeSelectionPage({super.key});

  @override
  State<UserTypeSelectionPage> createState() => _UserTypeSelectionPageState();
}

class _UserTypeSelectionPageState extends State<UserTypeSelectionPage> {
  final List<String> _roles = const ['مستخدم', 'دكتور', 'سكرتير', 'مندوب'];
  int _selectedIndex = 1; // default like screenshot: Doctor selected

  void _onNext() {
    // navigate to login after choosing type; keep back to selection
    Get.to(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 48.h),
              // top circle avatar placeholder
              Container(
                width: 260.w,
                height: 260.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: 40.h),
              MyText(
                'اختر نوع المستخدم',
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),

              // role buttons
              ...List.generate(_roles.length, (index) {
                final bool isSelected = index == _selectedIndex;
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28.r),
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      height: 64.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primaryLight.withOpacity(0.75),
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

              const Spacer(),

              // next button
              SizedBox(
                height: 64.h,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 12.w),
                      MyText(
                        'التالي',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      Container(
                        width: 48.h,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                      ),
                    ],
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
