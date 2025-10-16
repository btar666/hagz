import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/session_controller.dart';
import '../appointments/missed_appointments_page.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الاحصائيات',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final sessionController = Get.find<SessionController>();
              final userId = sessionController.currentUser.value?.id ?? '';
              if (userId.isNotEmpty) {
                Get.to(() => MissedAppointmentsPage(doctorId: userId));
              }
            },
            icon: Icon(
              Icons.event_busy,
              color: AppColors.error,
              size: 24.r,
            ),
            tooltip: 'المواعيد المفقودة',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _DailySection(),
            SizedBox(height: 16.h),
            _MonthlySection(),
            SizedBox(height: 16.h),
            _YearlySection(),
          ],
        ),
      ),
    );
  }
}

class _DailySection extends StatelessWidget {
  _DailySection({Key? key}) : super(key: key);

  final List<_DonutData> _data = const [
    _DonutData('المنجزة', 40, Color(0xFF658E82)),
    _DonutData('في الانتظار', 300, Color(0xFFFFE02E)),
    _DonutData('الملغية', 120, Color(0xFFF64535)),
    _DonutData('المتاحة', 200, Color(0xFFE0E0E0)),
  ];

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      title: 'اليومي',
      dateText: '2026 , 6 , 2',
      topStats: const [
        _TopStat(title: 'المواعيد الكلية', value: '20', icon: Icons.event_available),
        _TopStat(title: 'الأرباح الكلية', value: '600,000', icon: Icons.payments_rounded),
      ],
      child: SfCircularChart(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        series: <DoughnutSeries<_DonutData, String>>[
          DoughnutSeries<_DonutData, String>(
            dataSource: _data,
            xValueMapper: (d, _) => d.label,
            yValueMapper: (d, _) => d.value,
            pointColorMapper: (d, _) => d.color,
            innerRadius: '60%',
            radius: '68%',
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              connectorLineSettings: const ConnectorLineSettings(
                type: ConnectorType.line,
                length: '18%',
                width: 1.2,
              ),
              textStyle: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                return MyText(
                  '${point.y}\n${point.x}',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: (data as _DonutData).color,
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
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF4FEFF)),
              alignment: Alignment.center,
              child: MyText(
                '60',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlySection extends StatelessWidget {
  _MonthlySection({Key? key}) : super(key: key);

  final List<_DonutData> _data = const [
    _DonutData('المنجزة', 140, Color(0xFF658E82)),
    _DonutData('في الانتظار', 180, Color(0xFFFFE02E)),
    _DonutData('الملغية', 60, Color(0xFFF64535)),
    _DonutData('المتاحة', 120, Color(0xFFE0E0E0)),
  ];

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      title: 'الشهري',
      dateText: '2025 , 8',
      child: SfCircularChart(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        series: <DoughnutSeries<_DonutData, String>>[
          DoughnutSeries<_DonutData, String>(
            dataSource: _data,
            xValueMapper: (d, _) => d.label,
            yValueMapper: (d, _) => d.value,
            pointColorMapper: (d, _) => d.color,
            innerRadius: '60%',
            radius: '68%',
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              connectorLineSettings: const ConnectorLineSettings(
                type: ConnectorType.line,
                length: '18%',
                width: 1.2,
              ),
              textStyle: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                return MyText(
                  '${point.y}\n${point.x}',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: (data as _DonutData).color,
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
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF4FEFF)),
              alignment: Alignment.center,
              child: MyText(
                '60',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YearlySection extends StatelessWidget {
  _YearlySection({Key? key}) : super(key: key);

  final List<_BarData> completed = List.generate(12, (i) => _BarData('${12 - i}', (i * 7 + 10) % 90 + 5));
  final List<_BarData> cancelled = List.generate(12, (i) => _BarData('${12 - i}', (i * 3 + 4) % 25));

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      title: 'السنوي',
      dateText: '2026',
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
            textStyle: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries<dynamic, String>>[
            ColumnSeries<_BarData, String>(
              name: 'المواعيد المكتملة',
              dataSource: completed,
              xValueMapper: (d, _) => d.label,
              yValueMapper: (d, _) => d.value,
              color: const Color(0xFF69C9D0),
              width: 0.35,
              spacing: 0.1,
              borderRadius: BorderRadius.circular(6.r),
            ),
            ColumnSeries<_BarData, String>(
              name: 'المواعيد الملغية',
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
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.child,
    this.dateText,
    this.topStats,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? dateText;
  final Widget child;
  final List<_TopStat>? topStats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (dateText != null)
                Row(
                  children: [
                    const Icon(Icons.expand_more, color: AppColors.textPrimary),
                    SizedBox(width: 6.w),
                    MyText(
                      dateText!,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              const Spacer(),
              MyText(
                title,
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          if (topStats != null) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(child: topStats![0]),
                SizedBox(width: 12.w),
                Expanded(child: topStats![1]),
              ],
            ),
          ],
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _TopStat extends StatelessWidget {
  const _TopStat({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.primaryLight.withOpacity(0.35),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22.sp, color: AppColors.primaryDark),
          SizedBox(height: 6.h),
          MyText(title, fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          SizedBox(height: 4.h),
          MyText(value, fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
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

