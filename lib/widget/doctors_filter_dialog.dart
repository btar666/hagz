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
                        'تصفية حسب',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 12.h),

              // Filters row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _regionSelector(controller)),
                  SizedBox(width: 16.w),
                  Expanded(child: _alphaSelector(controller)),
                ],
              ),
              SizedBox(height: 20.h),

              // Apply button
              SizedBox(
                width: double.infinity,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipContainer({required Widget child}) {
    return Container(
      height: 84.h,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF1),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: const Color(0xFFB8C1CC), width: 1.6),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: child,
    );
  }

  Widget _regionSelector(DoctorsFilterController controller) {
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          _chipContainer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
                MyText(
                  controller.selectedRegion.value.isEmpty
                      ? 'المنطقة'
                      : controller.selectedRegion.value,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: controller.toggleRegionMenu),
            ),
          ),
          if (controller.isRegionMenuOpen.value)
            Positioned(
              top: 76.h,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF97A1AC)),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Column(
                  children: controller.regions
                      .map(
                        (r) => InkWell(
                          onTap: () => controller.pickRegion(r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: MyText(
                                r,
                                fontSize: 16.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _alphaSelector(DoctorsFilterController controller) {
    return Obx(
      () => Stack(
        children: [
          _chipContainer(
            child: Center(
              child: MyText(
                'الأبجدية (${controller.alphaOrder.value})',
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: controller.toggleAlphaOrder),
            ),
          ),
        ],
      ),
    );
  }
}
