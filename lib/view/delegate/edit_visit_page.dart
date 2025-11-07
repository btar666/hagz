import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/back_button_widget.dart';
import '../../controller/edit_visit_controller.dart';
import '../../widget/location_picker_widget.dart';

class EditVisitPage extends StatelessWidget {
  const EditVisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditVisitController());

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
                      'تعديل الزيارة',
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
                    _label('الاسم'),
                    SizedBox(height: 8.h),
                    _textField(
                      controller: controller.nameCtrl,
                      hint: 'اكتب الاسم',
                    ),
                    SizedBox(height: 16.h),
                    _label('التخصص'),
                    SizedBox(height: 8.h),
                    _textField(
                      controller: controller.specializationCtrl,
                      hint: 'اكتب التخصص',
                    ),
                    SizedBox(height: 16.h),
                    _label('رقم الهاتف'),
                    SizedBox(height: 8.h),
                    _textField(
                      controller: controller.phoneCtrl,
                      hint: '0000 000 0000',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16.h),
                    _label('العنوان'),
                    SizedBox(height: 8.h),
                    _textField(
                      controller: controller.addressCtrl,
                      hint: 'اكتب العنوان',
                      maxLines: 2,
                    ),
                    SizedBox(height: 12.h),
                    _locationPickerButton(controller),
                    SizedBox(height: 16.h),
                    _label('المحافظة'),
                    SizedBox(height: 8.h),
                    _governorateDropdown(controller),
                    SizedBox(height: 16.h),
                    _label('المنطقة'),
                    SizedBox(height: 8.h),
                    _textField(
                      controller: controller.districtCtrl,
                      hint: 'المنطقة (اختياري)',
                    ),
                    SizedBox(height: 16.h),
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
                                hint: 'اكتب السبب',
                                maxLines: 2,
                              ),
                              SizedBox(height: 16.h),
                            ],
                          )
                        : const SizedBox.shrink()),
                    _label('الملاحظات'),
                    SizedBox(height: 8.h),
                    _textField(
                      controller: controller.notesCtrl,
                      hint: 'اكتب الملاحظات (اختياري)',
                      maxLines: 3,
                    ),
                    SizedBox(height: 32.h),
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
                                  'حفظ التعديلات',
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

  Widget _governorateDropdown(EditVisitController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.governorateCtrl.text.isNotEmpty
            ? controller.governorateCtrl.text
            : null,
        decoration: InputDecoration(
          hintText: 'اضغط للاختيار',
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
        items: controller.iraqiGovernorates.map((gov) {
          return DropdownMenuItem<String>(
            value: gov,
            child: Text(
              gov,
              style: TextStyle(fontSize: 18.sp, fontFamily: 'Expo Arabic'),
              textAlign: TextAlign.right,
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.governorateCtrl.text = value;
          }
        },
      ),
    );
  }

  Widget _statusDropdown(EditVisitController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.selectedStatus.value,
        decoration: InputDecoration(
          hintText: 'اضغط للاختيار',
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

  Widget _locationPickerButton(EditVisitController controller) {
    return Obx(() {
      final hasLocation =
          controller.selectedLatitude.value != null &&
          controller.selectedLongitude.value != null;

      return InkWell(
        onTap: () async {
          final result = await Get.to(() => const LocationPickerWidget());
          if (result != null) {
            final locationData = result as Map<String, dynamic>;
            controller.selectedLatitude.value =
                locationData['latitude'] as double;
            controller.selectedLongitude.value =
                locationData['longitude'] as double;
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: hasLocation ? AppColors.primary : AppColors.textLight,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.map,
                color: hasLocation ? AppColors.primary : AppColors.textLight,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: MyText(
                  hasLocation
                      ? 'تم تحديد الموقع على الخريطة'
                      : 'اضغط لتحديد الموقع على الخريطة',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: hasLocation
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: hasLocation ? AppColors.primary : AppColors.textLight,
                size: 16.sp,
              ),
            ],
          ),
        ),
      );
    });
  }
}
