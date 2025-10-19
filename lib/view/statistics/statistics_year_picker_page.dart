import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';

class StatisticsYearPickerPage extends StatefulWidget {
  const StatisticsYearPickerPage({
    super.key,
    required this.initialYear,
    required this.firstYear,
    required this.lastYear,
  });

  final int initialYear;
  final int firstYear;
  final int lastYear;

  @override
  State<StatisticsYearPickerPage> createState() => _StatisticsYearPickerPageState();
}

class _StatisticsYearPickerPageState extends State<StatisticsYearPickerPage> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
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
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: MyText(
                        'اختر السنة',
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
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(color: AppColors.shadow, blurRadius: 12.r, offset: const Offset(0, 4)),
                    ],
                  ),
                  padding: EdgeInsets.all(16.w),
                  child: YearPicker(
                    firstDate: DateTime(widget.firstYear),
                    lastDate: DateTime(widget.lastYear),
                    selectedDate: DateTime(_selectedYear),
                    onChanged: (d) {
                      setState(() => _selectedYear = d.year);
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: MyText('إلغاء', fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: _selectedYear),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: MyText('تأكيد', fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
