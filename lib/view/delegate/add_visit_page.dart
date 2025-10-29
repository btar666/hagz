import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/back_button_widget.dart';
import '../../controller/add_visit_controller.dart';
import '../../service_layer/services/specialization_service.dart';
import '../../model/specialization_model.dart';
import '../../widget/location_picker_widget.dart';

class AddVisitPage extends StatelessWidget {
  const AddVisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddVisitController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Obx(
                      () => MyText(
                        controller.pageTitle,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),

                  const BackButtonWidget(),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name field
                    _buildLabel('اسم ${_getNameLabel(controller)}'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.nameCtrl,
                      hint: 'اكتب ${_getNamePlaceholder(controller)}',
                    ),

                    SizedBox(height: 16.h),

                    // Specialization (only for doctors)
                    Obx(() {
                      if (controller.visitType.value == 'doctor') {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildLabel('الاختصاص'),
                            SizedBox(height: 8.h),
                            _buildSpecializationDropdown(controller),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // Number of doctors (only for hospitals and complexes)
                    Obx(() {
                      if (controller.visitType.value != 'doctor') {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(height: 16.h),
                            _buildLabel('عدد الأطباء'),
                            SizedBox(height: 8.h),
                            _buildTextField(
                              controller: controller.numberOfDoctorsCtrl,
                              hint: 'اكتب الرقم',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    SizedBox(height: 16.h),

                    // Address section
                    _buildLabel('العنوان'),
                    SizedBox(height: 8.h),

                    // Governorate dropdown
                    _buildGovernorateDropdown(controller),
                    SizedBox(height: 12.h),

                    // District field
                    _buildTextField(
                      controller: controller.districtCtrl,
                      hint: 'المنطقة (اختياري)',
                    ),
                    SizedBox(height: 12.h),

                    // Manual address
                    _buildTextField(
                      controller: controller.addressCtrl,
                      hint: 'اكتب العنوان كتابة ...',
                      maxLines: 2,
                    ),
                    SizedBox(height: 12.h),

                    // Location picker button
                    _buildLocationPickerButton(controller),

                    SizedBox(height: 16.h),

                    // Phone number
                    _buildLabel('رقم الهاتف'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.phoneCtrl,
                      hint: '0000 000 0000',
                      keyboardType: TextInputType.phone,
                    ),

                    SizedBox(height: 16.h),

                    // Subscription status
                    _buildLabel('حالة الاشتراك'),
                    SizedBox(height: 8.h),
                    _buildSubscriptionStatusDropdown(controller),

                    SizedBox(height: 16.h),

                    // Notes
                    _buildLabel('ملاحظات'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.notesCtrl,
                      hint: 'اكتب ملاحظاتك ..',
                      maxLines: 4,
                    ),

                    SizedBox(height: 32.h),

                    // Submit button
                    Obx(() => _buildSubmitButton(controller)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
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

  Widget _buildTextField({
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

  Widget _buildGovernorateDropdown(AddVisitController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.selectedGovernorate.value,
        decoration: InputDecoration(
          hintText: 'المحافظة',
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
          controller.selectedGovernorate.value = value;
        },
      ),
    );
  }

  Widget _buildSpecializationDropdown(AddVisitController controller) {
    final specializationService = SpecializationService();

    return FutureBuilder<List<SpecializationModel>>(
      future: specializationService.getSpecializationsList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: MyText(
              'جاري التحميل...',
              fontSize: 18.sp,
              color: AppColors.textLight,
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: MyText(
              'لا توجد اختصاصات',
              fontSize: 18.sp,
              color: AppColors.textLight,
            ),
          );
        }

        final specializations = snapshot.data!;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: DropdownButtonFormField<String>(
            value: controller.selectedSpecialization.value,
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
            items: specializations.map((spec) {
              return DropdownMenuItem<String>(
                value: spec.name,
                child: Text(
                  spec.name,
                  style: TextStyle(fontSize: 18.sp, fontFamily: 'Expo Arabic'),
                  textAlign: TextAlign.right,
                ),
              );
            }).toList(),
            onChanged: (value) {
              controller.selectedSpecialization.value = value;
            },
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionStatusDropdown(AddVisitController controller) {
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

  Widget _buildSubmitButton(AddVisitController controller) {
    return ElevatedButton(
      onPressed: controller.isSubmitting.value ? null : controller.submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 18.h),
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : MyText(
              'تسجيل جديد',
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
    );
  }

  String _getNameLabel(AddVisitController controller) {
    switch (controller.visitType.value) {
      case 'hospital':
        return 'المستشفى';
      case 'complex':
        return 'المجمع';
      default:
        return 'الطبيب';
    }
  }

  String _getNamePlaceholder(AddVisitController controller) {
    switch (controller.visitType.value) {
      case 'hospital':
        return 'اسم المستشفى';
      case 'complex':
        return 'اسم المجمع';
      default:
        return 'اسم الطبيب الثلاثي';
    }
  }

  Widget _buildLocationPickerButton(AddVisitController controller) {
    return Obx(() {
      final hasLocation =
          controller.selectedLatitude.value != null &&
          controller.selectedLongitude.value != null;

      return InkWell(
        onTap: () async {
          final result = await Get.to(() => const LocationPickerWidget());
          if (result != null) {
            final locationData = result as Map<String, dynamic>;
            controller.setLocation(
              latitude: locationData['latitude'] as double,
              longitude: locationData['longitude'] as double,
              address: locationData['address'] as String? ?? '',
            );
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
