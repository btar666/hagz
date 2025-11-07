import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../controller/doctor_statistics_controller.dart';
import '../../controller/session_controller.dart';
import '../../controller/locale_controller.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import 'statistics_range_picker_page.dart';
import 'statistics_day_picker_page.dart';
import 'statistics_month_picker_page.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionController session = Get.find<SessionController>();
    final DoctorStatisticsController c = Get.put(DoctorStatisticsController());

    // Load initial datasets for old UI (daily, current month, yearly)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = session.currentUser.value?.id ?? '';
      if (uid.isNotEmpty) {
        final now = DateTime.now();
        c.loadDailyAt(now);
        c.loadMonthly(now.year, now.month);
        c.loadYearlyAt(now.year);
        // default range: آخر 7 أيام
        c.rangeStart.value ??= now.subtract(const Duration(days: 7));
        c.rangeEnd.value ??= now;
        c.loadRangeCurrent();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header with consistent design pattern
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 48.h),
                  Expanded(
                    child: GetBuilder<LocaleController>(
                      builder: (localeController) {
                        return Center(
                          child: MyText(
                            'statistics'.tr,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 48.h),
                ],
              ),
            ),
            // Body content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _DailySection(controller: c),
                    SizedBox(height: 20.h),
                    _MonthlySection(controller: c),
                    SizedBox(height: 20.h),
                    _YearlySection(controller: c),
                    SizedBox(height: 20.h),
                    _RangeSection(controller: c),
                    SizedBox(height: 16.h), // Bottom spacing
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailySection extends StatelessWidget {
  const _DailySection({required this.controller, Key? key}) : super(key: key);
  final DoctorStatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final m = controller.daily;
      final loading = controller.isLoadingDaily.value;
      final appointments = (m['appointments'] as Map<String, dynamic>?) ?? {};
      final byStatus =
          (appointments['byStatus'] as Map<String, dynamic>?) ?? {};
      final revenue = (m['revenue'] as Map<String, dynamic>?) ?? {};
      final total = (appointments['total'] as num?)?.toInt() ?? 0;
      final totalRevenue = (revenue['total'] as num?) ?? 0;

      var data = [
        _DonutData(
          'مكتمل',
          (byStatus['مكتمل'] as num?) ?? 0,
          const Color(0xFF658E82),
        ),
        _DonutData(
          'مؤكد',
          (byStatus['مؤكد'] as num?) ?? 0,
          const Color(0xFF69C9D0),
        ),
        _DonutData(
          'ملغي',
          (byStatus['ملغي'] as num?) ?? 0,
          const Color(0xFFF64535),
        ),
        _DonutData(
          'لم يحضر',
          (byStatus['لم يحضر'] as num?) ?? 0,
          const Color(0xFFE0E0E0),
        ),
      ];
      final num sum = data.fold<num>(0, (a, b) => a + b.value);
      final bool allZero = sum == 0;
      if (allZero) {
        // استخدم قطاعات متساوية لتوزيع الملصقات بشكل جميل وعرض 0 بالنص
        data = [
          _DonutData('مكتمل', 1, const Color(0xFF658E82)),
          _DonutData('مؤكد', 1, const Color(0xFF69C9D0)),
          _DonutData('ملغي', 1, const Color(0xFFF64535)),
          _DonutData('لم يحضر', 1, const Color(0xFFE0E0E0)),
        ];
      } else {
        // اجعل الشرائح ذات القيمة صفر تظهر كشرائح رفيعة مع بقاء قيمة العرض 0
        data = data
            .map(
              (d) =>
                  _DonutData(d.label, d.value == 0 ? 0.0001 : d.value, d.color),
            )
            .toList();
      }

      return GetBuilder<LocaleController>(
        builder: (localeController) {
          return _StatCard(
            title: 'daily'.tr,
            dateText: DateFormat('yyyy , M , d').format(controller.date.value),
            onDateTap: () async {
              final picked = await Get.to<DateTime>(
                () => StatisticsDayPickerPage(
                  initialDate: controller.date.value,
                  firstDate: DateTime(2022, 1, 1),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                ),
              );
              if (picked != null) {
                controller.date.value = picked;
                controller.loadDailyAt(picked);
              }
            },
            topStats: [
              _TopStat(
                title: 'total_appointments'.tr,
                value: total.toString(),
                icon: Icons.event_available,
              ),
              _TopStat(
                title: 'total_revenue'.tr,
                value: fmtMoney(totalRevenue),
                icon: Icons.payments_rounded,
              ),
            ],
            child: Skeletonizer(
              enabled: loading,
              child: SfCircularChart(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                series: <DoughnutSeries<_DonutData, String>>[
                  DoughnutSeries<_DonutData, String>(
                    explode: allZero,
                    explodeOffset: '2%',
                    dataSource: data,
                    xValueMapper: (d, _) => d.label,
                    yValueMapper: (d, _) => d.value,
                    pointColorMapper: (d, _) =>
                        allZero ? d.color.withValues(alpha: 0.3) : d.color,
                    innerRadius: '54%',
                    radius: '62%',
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      labelIntersectAction: LabelIntersectAction.shift,
                      connectorLineSettings: const ConnectorLineSettings(
                        type: ConnectorType.line,
                        length: '30%',
                        width: 1.5,
                      ),
                      textStyle: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      builder:
                          (
                            dynamic datum,
                            dynamic point,
                            dynamic series,
                            int pointIndex,
                            int seriesIndex,
                          ) {
                            final d = datum as _DonutData;
                            final display = allZero ? 0 : d.value.round();
                            return MyText(
                              '$display\n${d.label}',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: d.color,
                              textAlign: TextAlign.center,
                            );
                          },
                    ),
                  ),
                ],
                annotations: <CircularChartAnnotation>[
                  CircularChartAnnotation(
                    widget: Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF4FEFF),
                      ),
                      alignment: Alignment.center,
                      child: MyText(
                        total.toString(),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class _MonthlySection extends StatelessWidget {
  const _MonthlySection({required this.controller, Key? key}) : super(key: key);
  final DoctorStatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final m = controller.monthly;
      final loading = controller.isLoadingMonthly.value;
      final appointments = (m['appointments'] as Map<String, dynamic>?) ?? {};
      final byStatus =
          (appointments['byStatus'] as Map<String, dynamic>?) ?? {};

      var data = [
        _DonutData(
          'مكتمل',
          (byStatus['مكتمل'] as num?) ?? 0,
          const Color(0xFF658E82),
        ),
        _DonutData(
          'مؤكد',
          (byStatus['مؤكد'] as num?) ?? 0,
          const Color(0xFFFFE02E),
        ),
        _DonutData(
          'ملغي',
          (byStatus['ملغي'] as num?) ?? 0,
          const Color(0xFFF64535),
        ),
        _DonutData(
          'لم يحضر',
          (byStatus['لم يحضر'] as num?) ?? 0,
          const Color(0xFFE0E0E0),
        ),
      ];
      final num sum = data.fold<num>(0, (a, b) => a + b.value);
      final bool allZero = sum == 0;
      if (allZero) {
        data = [
          _DonutData('مكتمل', 1, const Color(0xFF658E82)),
          _DonutData('مؤكد', 1, const Color(0xFFFFE02E)),
          _DonutData('ملغي', 1, const Color(0xFFF64535)),
          _DonutData('لم يحضر', 1, const Color(0xFFE0E0E0)),
        ];
      } else {
        data = data
            .map(
              (d) =>
                  _DonutData(d.label, d.value == 0 ? 0.0001 : d.value, d.color),
            )
            .toList();
      }

      final selectedMonth = DateTime(
        controller.monthlyYear.value,
        controller.monthlyMonth.value,
        1,
      );
      return GetBuilder<LocaleController>(
        builder: (localeController) {
          return _StatCard(
            title: 'monthly'.tr,
            dateText: DateFormat('yyyy , M').format(selectedMonth),
            onDateTap: () async {
              final picked = await Get.to<DateTime>(
                () => StatisticsMonthPickerPage(
                  initialDate: selectedMonth,
                  firstDate: DateTime(2022, 1, 1),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                ),
              );
              if (picked != null) {
                controller.loadMonthly(picked.year, picked.month);
              }
            },
            child: Skeletonizer(
              enabled: loading,
              child: SfCircularChart(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                series: <DoughnutSeries<_DonutData, String>>[
                  DoughnutSeries<_DonutData, String>(
                    explode: allZero,
                    explodeOffset: '2%',
                    dataSource: data,
                    xValueMapper: (d, _) => d.label,
                    yValueMapper: (d, _) => d.value,
                    pointColorMapper: (d, _) =>
                        allZero ? d.color.withValues(alpha: 0.3) : d.color,
                    innerRadius: '54%',
                    radius: '62%',
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      labelIntersectAction: LabelIntersectAction.shift,
                      connectorLineSettings: const ConnectorLineSettings(
                        type: ConnectorType.line,
                        length: '30%',
                        width: 1.5,
                      ),
                      textStyle: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      builder:
                          (
                            dynamic datum,
                            dynamic point,
                            dynamic series,
                            int pointIndex,
                            int seriesIndex,
                          ) {
                            final d = datum as _DonutData;
                            final display = allZero ? 0 : d.value.round();
                            return MyText(
                              '$display\n${d.label}',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: d.color,
                              textAlign: TextAlign.center,
                            );
                          },
                    ),
                  ),
                ],
                annotations: <CircularChartAnnotation>[
                  CircularChartAnnotation(
                    widget: Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF4FEFF),
                      ),
                      alignment: Alignment.center,
                      child: MyText(
                        ((appointments['total'] as num?) ?? 0).toString(),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class _YearlySection extends StatelessWidget {
  const _YearlySection({required this.controller, Key? key}) : super(key: key);
  final DoctorStatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final y = controller.yearly;
      final loading = controller.isLoadingYearly.value;
      final monthly =
          (y['monthlyBreakdown'] as List?)?.cast<Map<String, dynamic>>() ??
          const [];

      final completed = <_BarData>[];
      final cancelled = <_BarData>[];
      for (final m in monthly) {
        final label = (m['monthName'] ?? m['month']?.toString() ?? '')
            .toString();
        final ap = (m['appointments'] as Map<String, dynamic>? ?? {});
        final by = (ap['byStatus'] as Map<String, dynamic>? ?? {});
        completed.add(_BarData(label, (by['مكتمل'] as num?) ?? 0));
        cancelled.add(_BarData(label, (by['ملغي'] as num?) ?? 0));
      }

      final selectedYear = controller.year.value;
      final currentYear = DateTime.now().year;
      final baseYear = 2025; // تبدأ القائمة من 2025 وتكبر تلقائياً كل سنة
      return GetBuilder<LocaleController>(
        builder: (localeController) {
          return _StatCard(
            title: 'yearly'.tr,
            dateText: null, // السنة في dropdown فلا حاجة للتاريخ
            onDateTap: null,
            child: Column(
              children: [
                // Year dropdown
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: DropdownButton<int>(
                      value: selectedYear,
                      isExpanded: false,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                      dropdownColor: Colors.white,
                      items:
                          List.generate(
                                (currentYear - baseYear) + 1,
                                (i) => baseYear + i,
                              )
                              .map(
                                (y) => DropdownMenuItem<int>(
                                  value: y,
                                  child: MyText(
                                    '$y',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (y) {
                        if (y != null) {
                          controller.loadYearlyAt(y);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Skeletonizer(
                  enabled: loading,
                  child: SizedBox(
                    height: 320.h,
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      primaryXAxis: CategoryAxis(
                        interval: 1,
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        labelStyle: TextStyle(fontSize: 10.sp),
                      ),
                      primaryYAxis: NumericAxis(
                        opposedPosition: true,
                        minimum: 0,
                        labelStyle: TextStyle(fontSize: 10.sp),
                      ),
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        textStyle: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<dynamic, String>>[
                        ColumnSeries<_BarData, String>(
                          name: 'completed_appointments'.tr,
                          dataSource: completed,
                          xValueMapper: (d, _) => d.label,
                          yValueMapper: (d, _) => d.value,
                          color: const Color(0xFF69C9D0),
                          width: 0.35,
                          spacing: 0.1,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        ColumnSeries<_BarData, String>(
                          name: 'cancelled_appointments'.tr,
                          dataSource: cancelled,
                          xValueMapper: (d, _) => d.label,
                          yValueMapper: (d, _) => d.value,
                          color: const Color(0xFFF64535),
                          width: 0.35,
                          spacing: 0.1,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _RangeSection extends StatelessWidget {
  const _RangeSection({required this.controller, Key? key}) : super(key: key);
  final DoctorStatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final m = controller.rangeData;
      final loading = controller.isLoadingRange.value;
      final appointments = (m['appointments'] as Map<String, dynamic>?) ?? {};
      final byStatus =
          (appointments['byStatus'] as Map<String, dynamic>?) ?? {};
      final s = controller.rangeStart.value;
      final e = controller.rangeEnd.value;
      final rangeLabel = (s != null && e != null)
          ? '${DateFormat('yyyy-MM-dd').format(s)} → ${DateFormat('yyyy-MM-dd').format(e)}'
          : '-- → --';

      var data = [
        _DonutData(
          'مكتمل',
          (byStatus['مكتمل'] as num?) ?? 0,
          const Color(0xFF658E82),
        ),
        _DonutData(
          'مؤكد',
          (byStatus['مؤكد'] as num?) ?? 0,
          const Color(0xFF69C9D0),
        ),
        _DonutData(
          'ملغي',
          (byStatus['ملغي'] as num?) ?? 0,
          const Color(0xFFF64535),
        ),
        _DonutData(
          'لم يحضر',
          (byStatus['لم يحضر'] as num?) ?? 0,
          const Color(0xFFE0E0E0),
        ),
      ];
      final num sum = data.fold<num>(0, (a, b) => a + b.value);
      final bool allZero = sum == 0;
      if (allZero) {
        data = [
          _DonutData('مكتمل', 1, const Color(0xFF658E82)),
          _DonutData('مؤكد', 1, const Color(0xFF69C9D0)),
          _DonutData('ملغي', 1, const Color(0xFFF64535)),
          _DonutData('لم يحضر', 1, const Color(0xFFE0E0E0)),
        ];
      } else {
        data = data
            .map(
              (d) =>
                  _DonutData(d.label, d.value == 0 ? 0.0001 : d.value, d.color),
            )
            .toList();
      }

      return GetBuilder<LocaleController>(
        builder: (localeController) {
          return _StatCard(
            title: 'time_period'.tr,
            dateText: rangeLabel,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final picked = await Get.to<DateTimeRange>(
                          () => StatisticsRangePickerPage(
                            initialStart: controller.rangeStart.value,
                            initialEnd: controller.rangeEnd.value,
                            firstDate: DateTime(2022, 1, 1),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          ),
                        );
                        if (picked != null) {
                          controller.rangeStart.value = picked.start;
                          controller.rangeEnd.value = picked.end;
                          controller.loadRangeCurrent();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.date_range,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8.w),
                          MyText(
                            'select_period'.tr,
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Skeletonizer(
                  enabled: loading,
                  child: SfCircularChart(
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    series: <DoughnutSeries<_DonutData, String>>[
                      DoughnutSeries<_DonutData, String>(
                        explode: allZero,
                        explodeOffset: '2%',
                        dataSource: data,
                        xValueMapper: (d, _) => d.label,
                        yValueMapper: (d, _) => d.value,
                        pointColorMapper: (d, _) =>
                            allZero ? d.color.withValues(alpha: 0.3) : d.color,
                        innerRadius: '54%',
                        radius: '62%',
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                          labelIntersectAction: LabelIntersectAction.shift,
                          connectorLineSettings: const ConnectorLineSettings(
                            type: ConnectorType.line,
                            length: '30%',
                            width: 1.5,
                          ),
                          textStyle: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          builder:
                              (
                                dynamic datum,
                                dynamic point,
                                dynamic series,
                                int pointIndex,
                                int seriesIndex,
                              ) {
                                final d = datum as _DonutData;
                                final display = allZero ? 0 : d.value.round();
                                return MyText(
                                  '$display\n${d.label}',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: d.color,
                                  textAlign: TextAlign.center,
                                );
                              },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.child,
    this.dateText,
    this.topStats,
    this.onDateTap,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? dateText;
  final Widget child;
  final List<_TopStat>? topStats;
  final VoidCallback? onDateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12.r,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section with gradient background
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primaryLight.withValues(alpha: 0.05),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyText(
                  title,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
                if (dateText != null) SizedBox(height: 8.h),
                if (dateText != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: onDateTap,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                              size: 16.r,
                            ),
                            SizedBox(width: 6.w),
                            MyText(
                              dateText!,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Stats section
          if (topStats != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  Expanded(child: topStats![0]),
                  SizedBox(width: 16.w),
                  Expanded(child: topStats![1]),
                ],
              ),
            ),
          // Content section
          Container(padding: EdgeInsets.all(20.w), child: child),
        ],
      ),
    );
  }
}

class _TopStat extends StatelessWidget {
  const _TopStat({
    required this.title,
    required this.value,
    required this.icon,
  });
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primaryLight.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 24.sp, color: AppColors.primary),
          ),
          SizedBox(height: 8.h),
          MyText(
            title,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          MyText(
            value,
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DonutData {
  final String label;
  final num value;
  final Color color;
  const _DonutData(this.label, this.value, this.color);
}

class _BarData {
  final String label;
  final num value;
  const _BarData(this.label, this.value);
}

// Top-level money formatter for reuse in sub-widgets
String fmtMoney(num v) => NumberFormat('#,##0').format(v);
