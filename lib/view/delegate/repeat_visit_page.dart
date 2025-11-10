import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/back_button_widget.dart';
import '../../controller/repeat_visit_controller.dart';

class RepeatVisitPage extends StatelessWidget {
  const RepeatVisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RepeatVisitController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Expanded(
                    child: MyText(
                      'تكرار الزيارة',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const BackButtonWidget(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('حالة الاشتراك'),
                    SizedBox(height: 8.h),
                    Obx(() => _statusDropdown(controller)),

                    SizedBox(height: 16.h),

                    Obx(() => controller.selectedStatus.value == 'غير مشترك'
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _label('سبب عدم الاشتراك'),
                              SizedBox(height: 8.h),
                              _textField(
                                controller: controller.reasonCtrl,
                                hint: 'اكتب السبب ..',
                                maxLines: 3,
                              ),
                            ],
                          )
                        : const SizedBox.shrink()),

                    SizedBox(height: 16.h),

                    // Info: visits will be auto-incremented
                    Align(
                      alignment: Alignment.centerRight,
                      child: MyText(
                        'سيتم زيادة عدد الزيارات تلقائياً إلى: ${controller.nextVisits}',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.right,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Obx(() => ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isSubmitting.value
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : MyText(
                                  'حفظ',
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: MyText(
        text,
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 18.sp,
          fontFamily: 'Expo Arabic',
          color: AppColors.textPrimary,
        ),
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textLight,
            fontSize: 18.sp,
            fontFamily: 'Expo Arabic',
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.textLight, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.textLight, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _statusDropdown(RepeatVisitController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.selectedStatus.value,
        decoration: InputDecoration(
          hintText: 'اضغط للاختيار ...',
          hintStyle: TextStyle(
            color: AppColors.textLight,
            fontSize: 18.sp,
            fontFamily: 'Expo Arabic',
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.textLight, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.textLight, width: 1),
          ),
        ),
        isExpanded: true,
        items: controller.subscriptionStatuses.map((status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(
              status,
              style: TextStyle(fontSize: 18.sp, fontFamily: 'Expo Arabic'),
              textAlign: TextAlign.right,
            ),
          );
        }).toList(),
        onChanged: (value) {
          controller.selectedStatus.value = value;
        },
      ),
    );
  }
}
