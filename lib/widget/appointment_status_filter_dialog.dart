import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import 'my_text.dart';

class AppointmentStatusFilterDialog extends StatefulWidget {
  const AppointmentStatusFilterDialog({super.key});

  @override
  State<AppointmentStatusFilterDialog> createState() =>
      _AppointmentStatusFilterDialogState();
}

class _AppointmentStatusFilterDialogState
    extends State<AppointmentStatusFilterDialog> {
  final Map<String, bool> _selected = {
    'مكتمل': false,
    'قادم': false,
    'قيد الانتظار': false,
    'ملغي': false,
  };

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
                        'تصفية حسب حالة الموعد',
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

              Row(
                children: [
                  Expanded(child: _chip('قيد الانتظار')),
                  SizedBox(width: 12.w),
                  Expanded(child: _chip('مكتمل')),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _chip('ملغي')),
                  SizedBox(width: 12.w),
                  Expanded(child: _chip('قادم')),
                ],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 64.h,
                child: ElevatedButton(
                  onPressed: () {
                    final picked = _selected.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .toList();
                    Get.back(result: picked);
                  },
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

  Widget _chip(String label) {
    final bool isSelected = _selected[label] ?? false;
    return InkWell(
      onTap: () => setState(() => _selected[label] = !isSelected),
      borderRadius: BorderRadius.circular(26.r),
      child: Container(
        height: 68.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : const Color(0xFFEDEFF1),
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(color: const Color(0xFFB8C1CC), width: 1),
        ),
        child: MyText(
          label,
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
