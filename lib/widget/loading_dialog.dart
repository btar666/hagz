import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import 'my_text.dart';

class LoadingDialog {
  static bool _isShowing = false;

  static Future<void> show({String message = 'جاري التحميل...'}) async {
    if (_isShowing) return;
    _isShowing = true;
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        backgroundColor: const Color(0xFFF4FEFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36.w,
                height: 36.w,
                child: const CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: MyText(
                  message,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (_isShowing) {
      _isShowing = false;
      if (Get.isDialogOpen == true) Get.back();
    }
  }
}
