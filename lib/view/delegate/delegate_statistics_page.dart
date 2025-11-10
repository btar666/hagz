import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/locale_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../controller/delegate_statistics_controller.dart';
import 'package:intl/intl.dart';

class DelegateStatisticsPage extends StatelessWidget {
  const DelegateStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DelegateStatisticsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Obx(() {
              if (controller.isLoading.value) {
                return GetBuilder<LocaleController>(
                  builder: (localeController) {
                    return Skeletonizer(
                      enabled: true,
                      child: Column(
                        children: [
                          _scoreCard(controller),
                          SizedBox(height: 16.h),
                          _donutSection(
                            title: 'daily_period'.tr,
                            dateText: '...',
                            data: [],
                          ),
                          SizedBox(height: 12.h),
                          _donutSection(
                            title: 'weekly_period'.tr,
                            dateText: '...',
                            data: [],
                          ),
                          SizedBox(height: 12.h),
                          _donutSection(
                            title: 'monthly_period'.tr,
                            dateText: '...',
                            data: [],
                          ),
                          SizedBox(height: 12.h),
                          _barSection(
                            title: 'yearly_period'.tr,
                            dateText: '...',
                            data: [],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              final now = DateTime.now();
              return Column(
                children: [
                  GetBuilder<LocaleController>(
                    builder: (localeController) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: MyText(
                          'statistics'.tr,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),

                  _scoreCard(controller),

                  SizedBox(height: 16.h),
                  GetBuilder<LocaleController>(
                    builder: (localeController) {
                      return _donutSection(
                        title: 'daily_period'.tr,
                        dateText: DateFormat('yyyy , M , d').format(now),
                        data: _extractDonutData(controller.stats['daily']),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  GetBuilder<LocaleController>(
                    builder: (localeController) {
                      return _donutSection(
                        title: 'weekly_period'.tr,
                        dateText: DateFormat('yyyy , M').format(now),
                        data: _extractDonutData(controller.stats['weekly']),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  GetBuilder<LocaleController>(
                    builder: (localeController) {
                      return _donutSection(
                        title: 'monthly_period'.tr,
                        dateText: DateFormat('yyyy , M').format(now),
                        data: _extractDonutData(controller.stats['monthly']),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  GetBuilder<LocaleController>(
                    builder: (localeController) {
                      return _barSection(
                        title: 'yearly_period'.tr,
                        dateText: DateFormat('yyyy').format(now),
                        data: _extractBarData(controller.stats['yearly']),
                      );
                    },
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  List<_DonutData> _extractDonutData(Map<String, dynamic>? periodData) {
    if (periodData == null) {
      return [
        _DonutData('subscribed'.tr, 0, const Color(0xFF69C9D0)),
        _DonutData('not_subscribed'.tr, 0, const Color(0xFFF64535)),
        _DonutData('subscribed_after_rejection'.tr, 0, const Color(0xFFFFE02E)),
        _DonutData('cancelled_subscription'.tr, 0, const Color(0xFF616E7C)),
      ];
    }

    return [
      _DonutData(
        'subscribed'.tr,
        periodData['subscribed'] as int? ?? 0,
        const Color(0xFF69C9D0),
      ),
      _DonutData(
        'not_subscribed'.tr,
        periodData['notSubscribed'] as int? ?? 0,
        const Color(0xFFF64535),
      ),
      _DonutData(
        'subscribed_after_rejection'.tr,
        periodData['subscribedAfterRejection'] as int? ?? 0,
        const Color(0xFFFFE02E),
      ),
      _DonutData(
        'cancelled_subscription'.tr,
        periodData['cancelledSubscription'] as int? ?? 0,
        const Color(0xFF616E7C),
      ),
    ];
  }

  List<_BarData> _extractBarData(Map<String, dynamic>? periodData) {
    // للرسم البياني السنوي، يمكن تقسيم البيانات على 12 شهر
    // حالياً نستخدم نفس البيانات لكل شهر كمثال
    if (periodData == null) {
      return List.generate(12, (i) => _BarData('${12 - i}', 0));
    }

    final subscribed = periodData['subscribed'] as int? ?? 0;

    return List.generate(12, (i) {
      // توزيع القيم على الأشهر بشكل متساوٍ كمثال
      return _BarData('${12 - i}', (i * 7 + 10) % (subscribed + 1));
    });
  }
}

Widget _scoreCard(DelegateStatisticsController controller) {
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
              child: GetBuilder<LocaleController>(
                builder: (localeController) {
                  return Obx(
                    () => MyText(
                      'current_points'.tr.replaceAll(
                        '{points}',
                        controller.currentPoints.value.toString(),
                      ),
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ),
            const Icon(Icons.auto_awesome, color: AppColors.primary),
          ],
        ),
        SizedBox(height: 18.h),

        // Stars row
        Obx(() {
          final points = controller.currentPoints.value;
          // كل نجمة = 50 نقطة
          final fullStars = (points / 50).floor();
          final remainder = points % 50;
          final halfStarIndex = remainder > 0 ? fullStars : -1;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              _StarState state;
              String label;

              if (index < fullStars) {
                state = _StarState.full;
                label = 'completed'.tr;
              } else if (index == halfStarIndex) {
                state = _StarState.half;
                label = 'remaining'.tr.replaceAll(
                  '{points}',
                  (50 - remainder).toString(),
                );
              } else {
                state = _StarState.empty;
                label = '0';
              }

              return _starItem(state: state, label: label);
            }),
          );
        }),

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
                child: GetBuilder<LocaleController>(
                  builder: (localeController) {
                    return MyText(
                      'per_star_points'.tr,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
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

Widget _donutSection({
  required String title,
  required String dateText,
  required List<_DonutData> data,
}) {
  final total = data.fold<int>(0, (sum, item) => sum + (item.value as int));
  return _statCard(
    title: title,
    dateText: dateText,
    child: GetBuilder<LocaleController>(
      builder: (localeController) {
        return SfCircularChart(
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
                  '$total\n${'visit'.tr}',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

Widget _barSection({
  required String title,
  required String dateText,
  required List<_BarData> data,
}) {
  // تقسيم البيانات إلى مشترك وغير مشترك (مثال)
  final List<_BarData> completed = data;
  final List<_BarData> cancelled = List.generate(
    12,
    (i) => _BarData('${12 - i}', (i * 3 + 4) % 25),
  );
  return _statCard(
    title: title,
    dateText: dateText,
    child: GetBuilder<LocaleController>(
      builder: (localeController) {
        return SizedBox(
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
              textStyle: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textPrimary,
              ),
            ),
            series: <CartesianSeries<dynamic, String>>[
              ColumnSeries<_BarData, String>(
                name: 'subscribed'.tr,
                dataSource: completed,
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.value,
                color: const Color(0xFF69C9D0),
                width: 0.35,
                spacing: 0.1,
                borderRadius: BorderRadius.circular(6.r),
              ),
              ColumnSeries<_BarData, String>(
                name: 'not_subscribed'.tr,
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
        );
      },
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
