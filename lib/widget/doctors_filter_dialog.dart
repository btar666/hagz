import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/doctors_filter_controller.dart';
import '../utils/app_colors.dart';
import 'my_text.dart';

class DoctorsFilterDialog extends StatelessWidget {
  const DoctorsFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorsFilterController());
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        backgroundColor: const Color(0xFFF7F8F8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: Get.back,
                  ),
                  Expanded(
                    child: Center(
                      child: MyText(
                        'تصفية الأطباء',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 24.h),

              // Region selector
              MyText(
                'المحافظة',
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 8.h),
              _regionSelector(controller),
              SizedBox(height: 20.h),

              // Alphabetical order selector
              MyText(
                'الترتيب الأبجدي',
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 8.h),
              _alphaSelector(controller),
              SizedBox(height: 20.h),

              // Apply and Cancel buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: SizedBox(
                      height: 64.h,
                      child: OutlinedButton(
                        onPressed: () {
                          // إلغاء الفلاتر وإغلاق النافذة
                          controller.clearAll();
                          Get.back(result: {
                            'region': '',
                            'alpha': '',
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.textSecondary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                        ),
                        child: MyText(
                          'إلغاء',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Apply button
                  Expanded(
                    child: SizedBox(
                      height: 64.h,
                      child: ElevatedButton(
                        onPressed: () => Get.back(
                          result: {
                            'region': controller.selectedRegion.value,
                            'alpha': controller.alphaOrder.value,
                          },
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                          elevation: 0,
                        ),
                        child: MyText(
                          'تصفية',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
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

  Widget _regionSelector(DoctorsFilterController controller) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: controller.isRegionMenuOpen.value
                ? AppColors.primary
                : AppColors.divider,
            width: controller.isRegionMenuOpen.value ? 1.5 : 1,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedRegion.value,
            isExpanded: true,
            hint: MyText(
              'اختر المحافظة',
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
            ),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Expo Arabic',
            ),
            items: controller.regions.map((region) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(
                  region.isEmpty ? 'الكل' : region,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 16.sp, fontFamily: 'Expo Arabic'),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectedRegion.value = value;
              }
            },
            onTap: () {
              controller.isRegionMenuOpen.value = true;
            },
          ),
        ),
      ),
    );
  }

  Widget _alphaSelector(DoctorsFilterController controller) {
    return Obx(
      () => InkWell(
        onTap: controller.toggleAlphaOrder,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: MyText(
            controller.alphaOrder.value,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
