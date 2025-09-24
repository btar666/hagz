import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';

// Generic confirm dialog used for logout/delete
Future<void> showActionConfirmDialog({
  required String title,
  required InlineSpan message,
  required Color primaryColor,
  IconData icon = Icons.warning_amber_rounded,
  String confirmText = 'متأكد',
  String cancelText = 'الغاء',
  VoidCallback? onConfirm,
}) async {
  await Get.dialog(
    Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      backgroundColor: const Color(0xFFF4FEFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primaryColor, size: 72),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8.h),
            RichText(
              textAlign: TextAlign.center,
              text: message,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      foregroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        fontFamily: 'Expo Arabic',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (onConfirm != null) onConfirm();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Expo Arabic',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

InlineSpan _baseMessage({required String prefix, required String underlined}) {
  return TextSpan(
    style: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      fontFamily: 'Expo Arabic',
    ),
    children: [
      TextSpan(text: prefix),
      TextSpan(
        text: underlined,
        style: const TextStyle(decoration: TextDecoration.underline),
      ),
    ],
  );
}

Future<void> showDeleteAccountConfirmDialog(BuildContext context, {VoidCallback? onConfirm}) async {
  return showActionConfirmDialog(
    title: 'حذف حسابك',
    message: _baseMessage(prefix: 'هل أنت متأكد ؟ ', underlined: 'ستفقد كافة بياناتك'),
    primaryColor: const Color(0xFFFF3B30),
    onConfirm: onConfirm,
  );
}

Future<void> showLogoutConfirmDialog(BuildContext context, {VoidCallback? onConfirm}) async {
  return showActionConfirmDialog(
    title: 'تسجيل الخروج',
    message: _baseMessage(prefix: 'هل أنت متأكد ؟ ', underlined: 'لن تفقد بياناتك'),
    primaryColor: const Color(0xFFFFC107),
    onConfirm: onConfirm,
  );
}

