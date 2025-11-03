import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../controller/session_controller.dart';
import '../../service_layer/services/appointments_service.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../widget/back_button_widget.dart';

class AppointmentSequencePage extends StatelessWidget {
  const AppointmentSequencePage({super.key});

  Color statusColor(String s) {
    switch (s) {
      case 'مكتمل':
        return const Color(0xFF2ECC71);
      case 'ملغي':
        return const Color(0xFFFF3B30);
      case 'مؤكد':
        return const Color(0xFF18A2AE);
      case 'لم يحضر':
        return const Color(0xFFE91E63);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppointmentsService service = AppointmentsService();
    final SessionController session = Get.find<SessionController>();
    final user = session.currentUser.value;
    final doctorId = user?.id ?? '';

    // تاريخ اليوم بصيغة YYYY-MM-DD
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FEFF),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    SizedBox(width: 48.w),
                    Expanded(
                      child: Center(
                        child: Text(
                          'appointment_sequence_title'.tr,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const BackButtonWidget(),
                  ],
                ),
              ),
              // Date picker
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 16.w, left: 16.w),
                        child: const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          todayStr,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Appointments list
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: service.getDoctorAppointmentsByDate(
                    doctorId: doctorId,
                    date: todayStr,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Skeletonizer(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          itemCount: 5,
                          itemBuilder: (_, i) => _buildAppointmentItem(
                            sequence: i + 1,
                            patient: 'المريض',
                            time: '--:--',
                            status: 'قيد الانتظار',
                            onTap: () {},
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data?['ok'] != true) {
                      return Center(
                        child: Text(
                          'لا توجد مواعيد اليوم',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16.sp,
                          ),
                        ),
                      );
                    }

                    // استخراج المواعيد من الرد
                    final data = snapshot.data?['data'];
                    final appointments = data?['data'] as List<dynamic>?;

                    if (appointments == null || appointments.isEmpty) {
                      return Center(
                        child: Text(
                          'لا يوجد مواعيد اليوم',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16.sp,
                          ),
                        ),
                      );
                    }

                    // فلترة المواعيد المؤكدة فقط
                    final confirmedAppointments = appointments.where((apt) {
                      final status = apt['status'] as String?;
                      return status == 'مؤكد' || status == 'confirmed';
                    }).toList();

                    if (confirmedAppointments.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد مواعيد مؤكدة اليوم',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16.sp,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      itemCount: confirmedAppointments.length,
                      itemBuilder: (_, i) {
                        final apt = confirmedAppointments[i];
                        return _buildAppointmentItem(
                          sequence:
                              apt['appointmentSequence'] as int? ?? (i + 1),
                          patient: apt['patientName'] as String? ?? 'المريض',
                          time: apt['appointmentTime'] as String? ?? '--:--',
                          status: apt['status'] as String? ?? 'مؤكد',
                          onTap: () {
                            // يمكن فتح تفاصيل الموعد هنا
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentItem({
    required int sequence,
    required String patient,
    required String time,
    required String status,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sequence number
            Container(
              width: 56.h,
              height: 56.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(
                  '$sequence',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Patient info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'الساعة $time',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Status chip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: statusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor(status),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
