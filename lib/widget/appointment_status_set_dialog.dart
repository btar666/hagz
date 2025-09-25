import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import 'my_text.dart';

class AppointmentStatusSetDialog extends StatefulWidget {
  const AppointmentStatusSetDialog({super.key});

  @override
  State<AppointmentStatusSetDialog> createState() =>
      _AppointmentStatusSetDialogState();
}

class _AppointmentStatusSetDialogState
    extends State<AppointmentStatusSetDialog> {
  final List<String> _statuses = const [
    'قيد الانتظار',
    'مكتمل',
    'ملغي',
    'قادم',
  ];
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        backgroundColor: Colors.white,
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
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  MyText(
                    'تعيين حالة الموعد',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  const Spacer(),
                  SizedBox(width: 24.w),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(child: _chip(_statuses[0])),
                  SizedBox(width: 12.w),
                  Expanded(child: _chip(_statuses[1])),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _chip(_statuses[2])),
                  SizedBox(width: 12.w),
                  Expanded(child: _chip(_statuses[3])),
                ],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 64.h,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () => Navigator.of(context).pop(_selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CC7D0),
                    disabledBackgroundColor: const Color(
                      0xFF7CC7D0,
                    ).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    elevation: 0,
                  ),
                  child: MyText(
                    'تعيين',
                    fontSize: 20.sp,
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
    final bool isSelected = _selected == label;
    return InkWell(
      onTap: () => setState(() => _selected = label),
      borderRadius: BorderRadius.circular(26.r),
      child: Container(
        height: 84.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEFF1),
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFB8C1CC),
            width: 1.4,
          ),
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
