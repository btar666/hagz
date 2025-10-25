import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/search_widget.dart';
import '../../widget/appointment_status_filter_dialog.dart';
import 'appointment_details_page.dart';
import '../appointments/patient_registration_page.dart';
import '../../controller/session_controller.dart';
import '../../controller/secretary_appointments_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SecretaryHomePage extends StatefulWidget {
  const SecretaryHomePage({super.key});

  @override
  State<SecretaryHomePage> createState() => _SecretaryHomePageState();
}

class _SecretaryHomePageState extends State<SecretaryHomePage> {
  bool _openNotifications = false;
  final List<String> _activeStatuses = [];
  final SessionController _sessionController = Get.find<SessionController>();
  final SecretaryAppointmentsController _appointmentsController = Get.put(
    SecretaryAppointmentsController(),
  );

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
                      final user = _sessionController.currentUser.value;

                      if (user?.associatedDoctor.isNotEmpty == true) {
                        Get.to(
                          () => PatientRegistrationPage(
                            doctorId: user!.associatedDoctor,
                            doctorName: user.name,
                            doctorSpecialty: 'طبيب', // يمكن تحسين هذا لاحقاً
                          ),
                        );
                      } else {
                        Get.snackbar(
                          'خطأ',
                          'لا يمكن العثور على معلومات الطبيب المرتبط',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7CC7D0),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
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

              Obx(() {
                final isLoading = _appointmentsController.isLoading.value;
                final appointments = _filteredAppointments();

                if (isLoading) {
                  return Skeletonizer(
                    enabled: true,
                    child: Column(
                      children: List.generate(
                        3,
                        (index) => _appointmentItem(
                          name: 'اسم المريض',
                          status: 'مكتمل',
                          time: '6:00 صباحاً',
                          seq: index + 1,
                          selected: false,
                        ),
                      ),
                    ),
                  );
                }

                if (appointments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: MyText(
                        'لا توجد مواعيد اليوم',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return Column(
                  children: appointments
                      .asMap()
                      .entries
                      .map(
                        (e) => _appointmentItem(
                          name: e.value['title'] ?? 'مريض',
                          status: _getStatusText(e.value['status']),
                          time: e.value['time'] ?? '',
                          seq: e.key + 1,
                          selected: e.key == 0,
                          appointment: e.value,
                        ),
                      )
                      .toList(),
                );
              }),
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
    final appointments = _appointmentsController.appointments;

    // فلترة المواعيد لليوم الحالي فقط
    final today = DateTime.now();
    final todayAppointments = appointments.where((appointment) {
      final appointmentDate = appointment['date'] as DateTime;
      return appointmentDate.year == today.year &&
          appointmentDate.month == today.month &&
          appointmentDate.day == today.day;
    }).toList();

    // تطبيق فلتر الحالة إذا كان موجود
    if (_activeStatuses.isEmpty) return todayAppointments;
    return todayAppointments
        .where(
          (a) =>
              _activeStatuses.contains(_getStatusText(a['status'] as String)),
        )
        .toList();
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
    Map<String, dynamic>? appointment,
  }) {
    return InkWell(
      onTap: () {
        if (appointment != null) {
          final date = appointment['date'] as DateTime;
          final formattedDate = '${date.year} / ${date.month} / ${date.day}';
          final price = '${appointment['amount'] ?? 0} د.ع';

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AppointmentDetailsPage(
                name: appointment['patientName'] ?? name,
                age: appointment['patientAge'] ?? '22',
                gender: 'انثى', // يمكن إضافة هذا الحقل لاحقاً
                phone: appointment['patientPhone'] ?? '0770 000 0000',
                date: formattedDate,
                time: time,
                price: price,
                paymentStatus: 'تم الدفع',
                seq: seq,
              ),
            ),
          );
        }
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
