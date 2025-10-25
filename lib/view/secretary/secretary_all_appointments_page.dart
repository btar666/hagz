import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/search_widget.dart';
import '../../widget/appointment_status_filter_dialog.dart';
import 'appointment_details_page.dart';
import '../../controller/secretary_appointments_controller.dart';

class SecretaryAllAppointmentsPage extends StatefulWidget {
  const SecretaryAllAppointmentsPage({super.key});

  @override
  State<SecretaryAllAppointmentsPage> createState() =>
      _SecretaryAllAppointmentsPageState();
}

class _SecretaryAllAppointmentsPageState
    extends State<SecretaryAllAppointmentsPage> {
  final SecretaryAppointmentsController _controller =
      Get.find<SecretaryAppointmentsController>();
  final Set<String> _expandedMonths = {'هذا الشهر'}; // expanded by default
  final List<String> _activeStatuses = [];

  // إضافة المتغيرات الجديدة
  int _selectedYear = DateTime.now().year;
  final List<String> _monthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FEFF),
        elevation: 0,
        title: MyText(
          'جميع المواعيد',
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        actions: [
          // زر تغيير السنة
          GestureDetector(
            onTap: _showYearPicker,
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFF7CC7D0),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: MyText(
                '$_selectedYear',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: SearchWidget(
                    hint: 'ابحث عن مريض ..',
                    onChanged: (value) {
                      _controller.query.value = value;
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDialog<List<String>>(
                      context: context,
                      builder: (_) => const AppointmentStatusFilterDialog(),
                    );
                    if (picked != null) {
                      setState(() {
                        _activeStatuses
                          ..clear()
                          ..addAll(picked);
                      });
                    }
                  },
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7CC7D0),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ],
            ),
            if (_activeStatuses.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _activeStatuses
                      .map(
                        (s) => _filterTag(
                          s,
                          () => setState(() => _activeStatuses.remove(s)),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            SizedBox(height: 16.h),
            Obx(() {
              final isLoading = _controller.isLoading.value;
              final appointments = _controller.filteredAppointments;

              if (isLoading) {
                return Skeletonizer(
                  enabled: true,
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => _buildMonthBlock('هذا الشهر'),
                    ),
                  ),
                );
              }

              if (appointments.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: MyText(
                      'لا توجد مواعيد',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              // تجميع المواعيد حسب الشهر
              final Map<String, List<Map<String, dynamic>>>
              groupedAppointments = {};
              for (final appointment in appointments) {
                final date = appointment['date'] as DateTime;
                final monthKey = _getMonthKey(date);

                if (!groupedAppointments.containsKey(monthKey)) {
                  groupedAppointments[monthKey] = [];
                }
                groupedAppointments[monthKey]!.add(appointment);
              }

              // إنشاء قائمة الشهور للعرض (من الشهر الحالي إلى 1)
              final List<String> monthsToShow = [];
              final currentMonth = DateTime.now().month;

              if (_selectedYear == DateTime.now().year) {
                // إذا كانت السنة الحالية، اعرض من الشهر الحالي إلى 1
                for (int i = currentMonth; i >= 1; i--) {
                  final monthKey = i == currentMonth
                      ? 'هذا الشهر'
                      : _monthNames[i - 1];
                  monthsToShow.add(monthKey);
                }
              } else {
                // إذا كانت سنة أخرى، اعرض جميع الشهور من 12 إلى 1
                for (int i = 12; i >= 1; i--) {
                  monthsToShow.add(_monthNames[i - 1]);
                }
              }

              return Column(
                children: monthsToShow
                    .map(
                      (month) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildMonthBlock(
                          month,
                          groupedAppointments[month] ?? [],
                        ),
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthBlock(
    String title, [
    List<Map<String, dynamic>>? appointments,
  ]) {
    final bool isExpanded = _expandedMonths.contains(title);
    final appointmentsList = appointments ?? [];

    if (isExpanded) {
      if (appointmentsList.isEmpty) {
        // عرض رسالة "لا يوجد حجوزات في هذا الشهر"
        return _monthSection(title, [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: MyText(
                'لا يوجد حجوزات في هذا الشهر',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ]);
      }

      final filtered = _activeStatuses.isEmpty
          ? appointmentsList
          : appointmentsList
                .where(
                  (e) => _activeStatuses.contains(_getStatusText(e['status'])),
                )
                .toList();
      return _monthSection(
        title,
        filtered
            .asMap()
            .entries
            .map(
              (e) => _timelineRow(
                e.value['title'] ?? 'مريض',
                _getStatusText(e.value['status']),
                e.value['time'] ?? '',
                '${e.key + 1} : التسلسل',
                _formatDate(e.value['date'] as DateTime),
                statusColor: _statusColor(_getStatusText(e.value['status'])),
                appointment: e.value,
              ),
            )
            .toList(),
      );
    }
    return GestureDetector(
      onTap: () => setState(() {
        if (_expandedMonths.contains(title)) {
          _expandedMonths.remove(title);
        } else {
          _expandedMonths.add(title);
        }
      }),
      child: _collapsedMonth(title, appointmentsList.length),
    );
  }

  Widget _filterTag(String status, VoidCallback onClear) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _statusColor(status), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: 16.sp, color: _statusColor(status)),
          ),
          SizedBox(width: 6.w),
          MyText(
            status,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: _statusColor(status),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'مكتمل':
      case 'completed':
        return const Color(0xFF2ECC71);
      case 'قادم':
        return const Color(0xFF18A2AE);
      case 'قيد الانتظار':
      case 'pending':
        return const Color(0xFFFFA000);
      case 'ملغي':
      case 'cancelled':
        return const Color(0xFFFF5B5E);
      case 'مؤكد':
      case 'confirmed':
        return const Color(0xFF18A2AE);
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _monthSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expandedMonths.remove(title)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Row(
                children: [
                  MyText(
                    title,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF7CC7D0),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_up,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _timelineRow(
    String name,
    String status,
    String time,
    String seq,
    String date, {
    required Color statusColor,
    Map<String, dynamic>? appointment,
  }) {
    return InkWell(
      onTap: () {
        if (appointment != null) {
          final price = '${appointment['amount'] ?? 0} د.ع';
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AppointmentDetailsPage(
                name: appointment['patientName'] ?? name,
                age: appointment['patientAge'] ?? '22',
                gender: 'انثى', // يمكن إضافة هذا الحقل لاحقاً
                phone: appointment['patientPhone'] ?? '0770 000 0000',
                date: date,
                time: time,
                price: price,
                paymentStatus: 'تم الدفع',
                seq: int.tryParse(seq.split(' ').first) ?? 1,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    name,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 8.w,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      MyText(
                        seq,
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      const MyText('•', color: AppColors.textSecondary),
                      MyText(
                        time,
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      const MyText('•', color: AppColors.textSecondary),
                      MyText(status, fontSize: 16.sp, color: statusColor),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            const Icon(
              Icons.keyboard_arrow_left,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _collapsedMonth(String title, int count) {
    return Container(
      height: 72.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          MyText(
            title,
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF7CC7D0),
          ),
          if (count > 0) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF7CC7D0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: MyText(
                '$count مواعيد',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7CC7D0),
              ),
            ),
          ],
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  String _getMonthKey(DateTime date) {
    if (date.year != _selectedYear) {
      return _monthNames[date.month - 1];
    }

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final appointmentMonth = DateTime(date.year, date.month);

    if (appointmentMonth.isAtSameMomentAs(thisMonth)) {
      return 'هذا الشهر';
    } else {
      return _monthNames[date.month - 1];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year} / ${date.month} / ${date.day}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'مكتمل';
      case 'pending':
        return 'قيد الانتظار';
      case 'cancelled':
        return 'ملغي';
      case 'confirmed':
        return 'مؤكد';
      default:
        return status;
    }
  }

  void _showYearPicker() {
    int tempSelectedYear = _selectedYear; // متغير مؤقت للاختيار

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
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
                      SizedBox(width: 40.w),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    height: 250.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFFE9ECEF),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: YearPicker(
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: DateTime(tempSelectedYear),
                        selectedDate: DateTime(tempSelectedYear),
                        onChanged: (DateTime date) {
                          setDialogState(() {
                            tempSelectedYear = date.year;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56.h,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.divider,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: MyText(
                              'إلغاء',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: SizedBox(
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedYear = tempSelectedYear;
                              });
                              _controller
                                  .loadAppointments(); // إعادة تحميل المواعيد
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 0,
                            ),
                            child: MyText(
                              'تم',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
