import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/search_widget.dart';
import '../../widget/appointment_status_filter_dialog.dart';
import 'appointment_details_page.dart';

class SecretaryAllAppointmentsPage extends StatefulWidget {
  const SecretaryAllAppointmentsPage({super.key});

  @override
  State<SecretaryAllAppointmentsPage> createState() =>
      _SecretaryAllAppointmentsPageState();
}

class _SecretaryAllAppointmentsPageState
    extends State<SecretaryAllAppointmentsPage> {
  final List<String> _monthsOrder = const [
    'هذا الشهر',
    'الشهر الماضي',
    '7 / 2025',
    '6 / 2025',
    '5 / 2025',
  ];

  final Map<String, List<Map<String, dynamic>>> _monthAppointments = {
    'هذا الشهر': [
      {
        'name': 'اسم المريض',
        'status': 'مكتمل',
        'time': '6:00 صباحاً',
        'seq': '1 : التسلسل',
        'date': '2025 / 10 / 2',
        'color': 0xFF2ECC71,
      },
      {
        'name': 'اسم المريض',
        'status': 'ملغي',
        'time': '6:20 صباحاً',
        'seq': '2 : التسلسل',
        'date': '2025 / 10 / 2',
        'color': 0xFFFF5B5E,
      },
      {
        'name': 'اسم المريض',
        'status': 'قيد الانتظار',
        'time': '6:40 صباحاً',
        'seq': '3 : التسلسل',
        'date': '2025 / 10 / 2',
        'color': 0xFFFFA000,
      },
    ],
    'الشهر الماضي': [
      {
        'name': 'اسم المريض',
        'status': 'قادم',
        'time': '7:00 صباحاً',
        'seq': '4 : التسلسل',
        'date': '2025 / 09 / 10',
        'color': 0xFF18A2AE,
      },
      {
        'name': 'اسم المريض',
        'status': 'مكتمل',
        'time': '7:20 صباحاً',
        'seq': '5 : التسلسل',
        'date': '2025 / 09 / 12',
        'color': 0xFF2ECC71,
      },
    ],
    '7 / 2025': [
      {
        'name': 'اسم المريض',
        'status': 'ملغي',
        'time': '9:00 صباحاً',
        'seq': '6 : التسلسل',
        'date': '2025 / 07 / 22',
        'color': 0xFFFF5B5E,
      },
    ],
    '6 / 2025': [
      {
        'name': 'اسم المريض',
        'status': 'قيد الانتظار',
        'time': '10:00 صباحاً',
        'seq': '7 : التسلسل',
        'date': '2025 / 06 / 15',
        'color': 0xFFFFA000,
      },
    ],
    '5 / 2025': [
      {
        'name': 'اسم المريض',
        'status': 'مكتمل',
        'time': '11:00 صباحاً',
        'seq': '8 : التسلسل',
        'date': '2025 / 05 / 05',
        'color': 0xFF2ECC71,
      },
    ],
  };

  final Set<String> _expandedMonths = {'هذا الشهر'}; // expanded by default
  final List<String> _activeStatuses = [];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: SearchWidget(hint: 'ابحث عن مريض ..')),
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
              for (final month in _monthsOrder) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildMonthBlock(month),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthBlock(String title) {
    final bool isExpanded = _expandedMonths.contains(title);
    if (isExpanded) {
      final items = _monthAppointments[title] ?? [];
      final filtered = _activeStatuses.isEmpty
          ? items
          : items
                .where((e) => _activeStatuses.contains(e['status'] as String))
                .toList();
      return _monthSection(
        title,
        filtered
            .map(
              (e) => _timelineRow(
                e['name'] as String,
                e['status'] as String,
                e['time'] as String,
                e['seq'] as String,
                e['date'] as String,
                statusColor: Color(e['color'] as int),
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
      child: _collapsedMonth(title),
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
        return const Color(0xFF2ECC71);
      case 'قادم':
        return const Color(0xFF18A2AE);
      case 'قيد الانتظار':
        return const Color(0xFFFFA000);
      case 'ملغي':
        return const Color(0xFFFF5B5E);
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
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    const Icon(
                      Icons.keyboard_arrow_up,
                      color: AppColors.textSecondary,
                    ),
                    const Spacer(),
                    MyText(
                      title,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF7CC7D0),
                    ),
                  ],
                ),
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
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AppointmentDetailsPage(
              name: name,
              age: '22',
              gender: 'انثى',
              phone: '0770 000 0000',
              date: date,
              time: time,
              price: '10,000 د.ع',
              paymentStatus: 'تم الدفع',
              seq: int.tryParse(seq.split(' ').first) ?? 1,
            ),
          ),
        );
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
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Wrap(
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

  Widget _collapsedMonth(String title) {
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
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
