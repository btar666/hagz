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
    'الكل': true, // مفعل افتراضياً
    'مكتمل': false,
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
                  Expanded(child: _chip('الكل')),
                  SizedBox(width: 12.w),
                  Expanded(child: _chip('قيد الانتظار')),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _chip('مكتمل')),
                  SizedBox(width: 12.w),
                  Expanded(child: _chip('ملغي')),
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

                    // إذا كان "الكل" مختار، إرجاع قائمة فارغة (لإظهار جميع المواعيد)
                    if (picked.contains('الكل')) {
                      Get.back(result: <String>[]);
                    } else {
                      Get.back(result: picked);
                    }
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
      onTap: () => setState(() {
        if (label == 'الكل') {
          // إذا تم اختيار "الكل"، إلغاء جميع الفلاتر الأخرى
          _selected['الكل'] = true;
          _selected['مكتمل'] = false;
          _selected['قيد الانتظار'] = false;
          _selected['ملغي'] = false;
        } else {
          // إذا تم اختيار فلتر آخر، إلغاء "الكل"
          _selected[label] = !isSelected;
          _selected['الكل'] = false;
        }
      }),
      borderRadius: BorderRadius.circular(26.r),
      child: Container(
        height: 68.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFEDEFF1),
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFB8C1CC),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: MyText(
          label,
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
