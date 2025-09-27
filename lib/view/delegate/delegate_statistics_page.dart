import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DelegateStatisticsPage extends StatelessWidget {
  const DelegateStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: MyText(
                  'الاحصائيات',
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              _scoreCard(),

              SizedBox(height: 16.h),
              _donutSection(title: 'يومياً', dateText: '2026 , 6 , 2'),
              SizedBox(height: 12.h),
              _donutSection(title: 'اسبوعياً', dateText: '2025 , 8'),
              SizedBox(height: 12.h),
              _donutSection(title: 'شهرياً', dateText: '2025 , 8'),
              SizedBox(height: 12.h),
              _barSection(title: 'سنوياً', dateText: '2026'),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _scoreCard() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22.r),
      boxShadow: const [
        BoxShadow(
          color: Color(0x3369C9D0),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title row with star icon
        Row(
          children: [
            Expanded(
              child: MyText(
                'النقاط الحالية : 200 نقطة',
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const Icon(Icons.auto_awesome, color: AppColors.primary),
          ],
        ),
        SizedBox(height: 18.h),

        // Stars row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _starItem(state: _StarState.empty, label: '0'),
            _starItem(state: _StarState.empty, label: '0'),
            _starItem(state: _StarState.half, label: 'متبقي 20'),
            _starItem(state: _StarState.full, label: 'مكتمل'),
            _starItem(state: _StarState.full, label: 'مكتمل'),
          ],
        ),

        SizedBox(height: 18.h),

        // Note strip
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1D8),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            children: [
              const Icon(Icons.diamond, color: Color(0xFFFFA000)),
              SizedBox(width: 8.w),
              Expanded(
                child: MyText(
                  'لكل نجمة 50 نقطة .',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

enum _StarState { empty, half, full }

Widget _starItem({required _StarState state, required String label}) {
  Color border = const Color(0xFFFFC107);
  Color fill = const Color(0xFFFFC107);
  Widget star;
  switch (state) {
    case _StarState.empty:
      star = Icon(Icons.star_border_rounded, color: border, size: 36.sp);
      break;
    case _StarState.half:
      star = Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.star_border_rounded, color: border, size: 36.sp),
          ClipPath(
            clipper: _HalfClipper(),
            child: Icon(Icons.star_rounded, color: fill, size: 28.sp),
          ),
        ],
      );
      break;
    case _StarState.full:
      star = Icon(Icons.star_rounded, color: fill, size: 36.sp);
      break;
  }

  return Column(
    children: [
      star,
      SizedBox(height: 8.h),
      MyText(
        label,
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: state == _StarState.empty
            ? AppColors.textLight
            : AppColors.textPrimary,
      ),
    ],
  );
}

class _HalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width / 2, size.height));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

Widget _statCard({
  required String title,
  required Widget child,
  String? dateText,
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
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
            if (dateText != null) ...[
              const Icon(Icons.expand_more, color: AppColors.textPrimary),
              SizedBox(width: 6.w),
              MyText(
                dateText,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ],
            const Spacer(),
            MyText(
              title,
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        child,
      ],
    ),
  );
}

Widget _donutSection({required String title, required String dateText}) {
  final List<_DonutData> data = const [
    _DonutData('مشترك', 26, Color(0xFF69C9D0)),
    _DonutData('غير مشترك', 6, Color(0xFFF64535)),
    _DonutData('اشتراك بعد رفض', 22, Color(0xFFFFE02E)),
    _DonutData('اشتراك ملغي', 10, Color(0xFF616E7C)),
  ];
  return _statCard(
    title: title,
    dateText: dateText,
    child: SfCircularChart(
      series: <DoughnutSeries<_DonutData, String>>[
        DoughnutSeries<_DonutData, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.label,
          yValueMapper: (d, _) => d.value,
          pointColorMapper: (d, _) => d.color,
          innerRadius: '62%',
          radius: '70%',
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
              '64\nزيارة',
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _barSection({required String title, required String dateText}) {
  final List<_BarData> completed = List.generate(
    12,
    (i) => _BarData('${12 - i}', (i * 7 + 10) % 90 + 5),
  );
  final List<_BarData> cancelled = List.generate(
    12,
    (i) => _BarData('${12 - i}', (i * 3 + 4) % 25),
  );
  return _statCard(
    title: title,
    dateText: dateText,
    child: SizedBox(
      height: 300.h,
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
        series: <CartesianSeries<dynamic, String>>[
          ColumnSeries<_BarData, String>(
            name: 'المشترك',
            dataSource: completed,
            xValueMapper: (d, _) => d.label,
            yValueMapper: (d, _) => d.value,
            color: const Color(0xFF69C9D0),
            width: 0.35,
            spacing: 0.1,
            borderRadius: BorderRadius.circular(6.r),
          ),
          ColumnSeries<_BarData, String>(
            name: 'غير مشترك',
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
