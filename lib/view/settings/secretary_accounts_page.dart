import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/secretary_accounts_controller.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';

class SecretaryAccountsPage extends StatelessWidget {
  const SecretaryAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SecretaryAccountsController());
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FEFF),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 48.h,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: MyText(
                          'ادارة حسابات السكرتارية',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 48.h),
                  ],
                ),
              ),
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                    itemCount: controller.secretaries.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.only(right: 16.w, left: 16.w),
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                    itemBuilder: (_, index) {
                      final item = controller.secretaries[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // info (right)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    item['name'] ?? 'اسم السكرتير',
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    textAlign: TextAlign.right,
                                  ),
                                  SizedBox(height: 6.h),
                                  MyText(
                                    item['phone'] ?? '',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // minus button (left)
                            _minusRedCircle(
                              () => _confirmDelete(context, controller, index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Add new secretary button
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context, controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: MyText(
                      'اضافة سكرتير جديد',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _minusRedCircle(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: const BoxDecoration(
          color: Color(0xFFFF5252),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.remove, color: Colors.white, size: 18.sp),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SecretaryAccountsController controller,
    int index,
  ) {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        backgroundColor: const Color(0xFFF4FEFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF3B30),
                size: 72,
              ),
              SizedBox(height: 12.h),
              MyText(
                'حذف حساب السكرتير',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFF3B30),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              MyText(
                'هل أنت متأكد من ذلك؟',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: MyText(
                        'الغاء',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.removeSecretaryAt(index);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: MyText(
                        'متأكد',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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

  void _showAddDialog(
    BuildContext context,
    SecretaryAccountsController controller,
  ) {
    final phoneCtrl = TextEditingController();
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        backgroundColor: const Color(0xFFF4FEFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: MyText(
                  'اضافة سكرتير جديد',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.h),
              Directionality(
                textDirection: TextDirection.rtl,
                child: MyText(
                  'رقم الهاتف',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: AppColors.divider),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '0000 000 0000',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontFamily: 'Expo Arabic'),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: MyText(
                        'الغاء',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final phone = phoneCtrl.text.trim();
                        if (phone.isNotEmpty) {
                          controller.addSecretary(phone: phone);
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: MyText(
                        'اضافة',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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
}
