import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';

class StatisticsMonthPickerPage extends StatefulWidget {
  const StatisticsMonthPickerPage({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate; // any day in initial month
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<StatisticsMonthPickerPage> createState() => _StatisticsMonthPickerPageState();
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.year,
    required this.firstDate,
    required this.lastDate,
    required this.selectedMonth,
    required this.onChanged,
    required this.onYearChanged,
  });

  final int year;
  final DateTime firstDate;
  final DateTime lastDate;
  final int selectedMonth;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onYearChanged;

  bool _isEnabledMonth(int y, int m) {
    final first = DateTime(firstDate.year, firstDate.month, 1);
    final last = DateTime(lastDate.year, lastDate.month + 1, 0);
    final start = DateTime(y, m, 1);
    final end = DateTime(y, m + 1, 0);
    if (end.isBefore(first)) return false;
    if (start.isAfter(last)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final monthsLabels = const [
      'يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'
    ];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => onYearChanged(year - 1),
              icon: const Icon(Icons.chevron_left),
            ),
            MyText(
              '$year',
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            IconButton(
              onPressed: () => onYearChanged(year + 1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          itemCount: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (_, i) {
            final m = i + 1;
            final enabled = _isEnabledMonth(year, m);
            final selected = m == selectedMonth;
            final bg = selected ? AppColors.primary.withValues(alpha: 0.15) : Colors.white;
            final border = selected ? AppColors.primary : const Color(0xFFE6F2F1);
            final textColor = enabled ? AppColors.textPrimary : AppColors.textLight;
            return InkWell(
              onTap: enabled ? () => onChanged(m) : null,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: border, width: 1),
                ),
                alignment: Alignment.center,
                child: MyText(
                  monthsLabels[i],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatisticsMonthPickerPageState extends State<StatisticsMonthPickerPage> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
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
                        'اختر الشهر',
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
              child: SingleChildScrollView(
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
                  child: _MonthGrid(
                    year: _selected.year,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate,
                    selectedMonth: _selected.month,
                    onChanged: (m) => setState(() => _selected = DateTime(_selected.year, m, 1)),
                    onYearChanged: (y) => setState(() => _selected = DateTime(y, _selected.month, 1)),
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
                      onPressed: () => Get.back(result: _selected),
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
