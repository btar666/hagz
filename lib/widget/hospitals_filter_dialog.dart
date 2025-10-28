import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import 'my_text.dart';

class HospitalsFilterDialog extends StatefulWidget {
  const HospitalsFilterDialog({super.key});

  @override
  State<HospitalsFilterDialog> createState() => _HospitalsFilterDialogState();
}

class _HospitalsFilterDialogState extends State<HospitalsFilterDialog> {
  String _selectedCity = '';

  final List<String> _cities = const [
    '',
    'بغداد',
    'البصرة',
    'نينوى',
    'أربيل',
    'النجف',
    'كربلاء',
    'الأنبار',
    'ديالى',
    'صلاح الدين',
    'واسط',
    'ذي قار',
    'بابل',
    'كركوك',
    'السليمانية',
    'المثنى',
    'القادسية',
    'ميسان',
    'دهوك',
  ];

  @override
  Widget build(BuildContext context) {
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
                        'تصفية حسب المحافظة',
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

              // City selector
              MyText(
                'المحافظة',
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 8.h),
              _cityDropdown(),
              SizedBox(height: 20.h),

              // Apply button
              SizedBox(
                width: double.infinity,
                height: 64.h,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: {'city': _selectedCity}),
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

  Widget _cityDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
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
          items: _cities.map((city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(
                city.isEmpty ? 'الكل' : city,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 16.sp, fontFamily: 'Expo Arabic'),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCity = value ?? '';
            });
          },
        ),
      ),
    );
  }
}
