import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/search_widget.dart';
import '../../widget/appointment_status_filter_dialog.dart';
import 'appointment_details_page.dart';
import '../appointments/patient_registration_page.dart';

class SecretaryHomePage extends StatefulWidget {
  const SecretaryHomePage({super.key});

  @override
  State<SecretaryHomePage> createState() => _SecretaryHomePageState();
}

class _SecretaryHomePageState extends State<SecretaryHomePage> {
  bool _openNotifications = false;
  final List<String> _activeStatuses = [];

  final List<Map<String, dynamic>> _appointments = [
    {'name': 'اسم المريض', 'status': 'مكتمل', 'time': '6:00 صباحاً', 'seq': 1},
    {'name': 'اسم المريض', 'status': 'مكتمل', 'time': '6:20 صباحاً', 'seq': 2},
    {'name': 'اسم المريض', 'status': 'مكتمل', 'time': '6:40 صباحاً', 'seq': 3},
    {'name': 'اسم المريض', 'status': 'مكتمل', 'time': '7:00 صباحاً', 'seq': 4},
    {'name': 'اسم المريض', 'status': 'مكتمل', 'time': '7:20 صباحاً', 'seq': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PatientRegistrationPage(
                            doctorId: 'doctor_id_placeholder',
                            doctorName: 'اسم الطبيب',
                            doctorSpecialty: 'التخصص',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7CC7D0),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),
                  Expanded(
                    child: SearchWidget(
                      hint: 'ابحث عن مريض ..',
                      readOnly: true,
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7CC7D0),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Sequence Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 36.h),
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
                  children: [
                    MyText(
                      '22',
                      fontSize: 72.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 8.h),
                    MyText(
                      'تسلسل الموعد',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Daily notifications expandable
              _buildDailyNotifications(),

              SizedBox(height: 16.h),

              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontFamily: 'Expo Arabic'),
                      children: [
                        TextSpan(
                          text: 'مواعيد اليوم ',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF7CC7D0),
                          ),
                        ),
                        TextSpan(
                          text: '(${_filteredAppointments().length} مواعيد)',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
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
                    child: const Icon(
                      Icons.tune,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              if (_activeStatuses.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: _activeStatuses
                        .map(
                          (s) => _filterTag(_statusDisplay(s), () {
                            setState(() {
                              _activeStatuses.remove(s);
                            });
                          }),
                        )
                        .toList(),
                  ),
                ),

              ..._filteredAppointments().asMap().entries.map(
                (e) => _appointmentItem(
                  name: e.value['name'] as String,
                  status: e.value['status'] as String,
                  time: e.value['time'] as String,
                  seq: e.value['seq'] as int,
                  selected: e.key == 0,
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyNotifications() {
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
        children: [
          InkWell(
            onTap: () =>
                setState(() => _openNotifications = !_openNotifications),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  MyText(
                    'التنبيهات اليومية',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  const Spacer(),
                  MyText(
                    '6 مواعيد جديدة',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFF5B5E),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    _openNotifications ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_openNotifications) const Divider(height: 1),
          if (_openNotifications)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _notifRow(
                    time: 'منذ 10 دقائق',
                    title: 'تم حجز موعد جديد !',
                    body: 'اضغط للحصول على المعلومات .',
                    isAlert: true,
                  ),
                  Divider(color: AppColors.divider, height: 24.h),
                  _notifRow(
                    time: 'منذ 10 دقائق',
                    title: 'تم حجز موعد جديد !',
                    body: 'اضغط للحصول على المعلومات .',
                    isAlert: true,
                  ),
                  Divider(color: AppColors.divider, height: 24.h),
                  _notifRow(
                    time: 'منذ 10 دقائق',
                    title: 'تحديث جديد ينتظرك !',
                    body: 'تم اضافة ميزات جديدة , حدث التطبيق و استمتع .',
                    isAlert: false,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _notifRow({
    required String time,
    required String title,
    required String body,
    required bool isAlert,
  }) {
    final Color titleColor = isAlert
        ? const Color(0xFFFF5B5E)
        : const Color(0xFF18A2AE);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MyText(
                      title,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                    SizedBox(width: 12.w),
                    MyText(
                      time,
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              MyText(
                body,
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ],
    );
  }

  List<Map<String, dynamic>> _filteredAppointments() {
    if (_activeStatuses.isEmpty) return _appointments;
    return _appointments
        .where((a) => _activeStatuses.contains(a['status'] as String))
        .toList();
  }

  Widget _filterTag(String text, VoidCallback onClear) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF1),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 6.w),
          MyText(
            text,
            fontSize: 16.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  String _statusDisplay(String status) {
    switch (status) {
      case 'مكتمل':
        return 'المواعيد المكتملة';
      case 'قادم':
        return 'المواعيد القادمة';
      case 'قيد الانتظار':
        return 'المواعيد قيد الانتظار';
      case 'ملغي':
        return 'المواعيد الملغية';
      default:
        return status;
    }
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

  Widget _appointmentItem({
    required String name,
    required String status,
    required String time,
    required int seq,
    required bool selected,
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
              date: '2025 / 10 / 2',
              time: time,
              price: '10,000 د.ع',
              paymentStatus: 'تم الدفع',
              seq: seq,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // circle at the right
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF7CC7D0) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textLight, width: 2),
              ),
            ),
            SizedBox(width: 8.w),
            // middle info RTL
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    name,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 8.h),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Wrap(
                      spacing: 8.w,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        MyText(
                          status,
                          fontSize: 16.sp,
                          color: _statusColor(status),
                        ),
                        const MyText('•', color: AppColors.textSecondary),
                        MyText(
                          time,
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                        const MyText('•', color: AppColors.textSecondary),
                        MyText(
                          '$seq : التسلسل',
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // arrow at far left
            const Icon(
              Icons.keyboard_arrow_left,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
