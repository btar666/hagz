import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';

class StatisticsRangePickerPage extends StatefulWidget {
  const StatisticsRangePickerPage({
    super.key,
    this.initialStart,
    this.initialEnd,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime? initialStart;
  final DateTime? initialEnd;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<StatisticsRangePickerPage> createState() => _StatisticsRangePickerPageState();
}

class _StatisticsRangePickerPageState extends State<StatisticsRangePickerPage> {
  DateTime? _start;
  DateTime? _end;
  bool _selectingStart = true;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    _selectingStart = _start == null; // if no start, default to selecting start
  }

  String _fmt(DateTime? d) => d == null ? '--' : DateFormat('yyyy-MM-dd').format(d);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Compute constraints for the calendar depending on which date is being selected
    final DateTime today = DateTime.now();
    final DateTime initial = _selectingStart
        ? (_start ?? today)
        : (_end ?? _start ?? today);

    DateTime first = widget.firstDate;
    DateTime last = widget.lastDate;

    if (_selectingStart) {
      // Ensure initial is within [first, last]
      if (initial.isBefore(first)) first = initial;
      if (initial.isAfter(last)) last = initial;
    } else {
      // When picking end, it should not be before start
      if (_start != null && _start!.isAfter(first)) first = _start!;
      if (initial.isBefore(first)) first = initial;
      if (initial.isAfter(last)) last = initial;
    }

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
                        'اختر الفترة',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _rangePill(
                              label: 'من',
                              value: _fmt(_start),
                              active: _selectingStart,
                              onTap: () => setState(() => _selectingStart = true),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _rangePill(
                              label: 'الى',
                              value: _fmt(_end),
                              active: !_selectingStart,
                              onTap: () => setState(() => _selectingStart = false),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Divider(color: theme.dividerColor.withValues(alpha: 0.1)),
                      SizedBox(height: 12.h),
                      CalendarDatePicker(
                        initialDate: initial,
                        firstDate: first,
                        lastDate: last,
                        onDateChanged: (d) {
                          setState(() {
                            if (_selectingStart) {
                              _start = DateTime(d.year, d.month, d.day);
                              if (_end != null && _end!.isBefore(_start!)) {
                                _end = null;
                              }
                              _selectingStart = false; // move to end selection
                            } else {
                              _end = DateTime(d.year, d.month, d.day);
                            }
                          });
                        },
                      ),
                      SizedBox(height: 16.h),
                      Align(
                        alignment: Alignment.center,
                        child: MyText(
                          _start != null && _end != null
                              ? '${_fmt(_start)} → ${_fmt(_end)}'
                              : 'اختر تاريخي البداية والنهاية',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
                      child: MyText(
                        'إلغاء',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _start != null && _end != null
                          ? () {
                              Get.back(result: DateTimeRange(start: _start!, end: _end!));
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primaryLight,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: MyText(
                        'تأكيد',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
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

  Widget _rangePill({
    required String label,
    required String value,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          color: active ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          border: Border.all(
            color: active ? AppColors.primary : const Color(0xFFE6F2F1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18.r,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MyText(
                    label,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 2.h),
                  MyText(
                    value,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.right,
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
