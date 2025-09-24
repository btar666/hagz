import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../settings/doctor_profile_manage_page.dart';
import '../../controller/past_appointments_controller.dart';
import '../appointments/appointment_details_page.dart';

class PastAppointmentsPage extends StatelessWidget {
  const PastAppointmentsPage({super.key});

  Color statusColor(String s) {
    switch (s) {
      case 'completed':
        return const Color(0xFF2ECC71);
      case 'pending':
        return const Color(0xFFFFA000);
      case 'cancelled':
        return const Color(0xFFFF3B30);
      default:
        return AppColors.textSecondary;
    }
  }

  String statusLabel(String s) {
    switch (s) {
      case 'completed':
        return 'مكتمل';
      case 'pending':
        return 'قيد الانتظار';
      case 'cancelled':
        return 'ملغي';
      default:
        return s;
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month}/${dt.day}';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PastAppointmentsController());
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
                        child: Text(
                          'المواعيد السابقة',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48.h),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.divider),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: controller.updateQuery,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: 'ابحث عن طبيب ..',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontFamily: 'Expo Arabic'),
                        ),
                      ),
                      const Icon(Icons.search, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
                    itemCount: controller.filtered.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                    itemBuilder: (_, i) {
                      final item = controller.filtered[i];
                      final String doctor = item['doctor'] as String;
                      final int order = item['order'] as int;
                      final DateTime date = item['date'] as DateTime;
                      final String status = item['status'] as String;
                      return InkWell(
                        onTap: () {
                          final sColor = statusColor(status);
                          final sText = statusLabel(status);
                          Get.to(
                            () => AppointmentDetailsPage(
                              details: {
                                'patient': doctor,
                                'order': order,
                                'time': '—',
                                'statusText': sText,
                                'statusColor': sColor,
                                'age': 30,
                                'gender': 'ذكر',
                                'phone': '0770 000 0000',
                                'date': _formatDate(date),
                                'price': '10,000 د.ع',
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // top line: doctor name on right, arrow on left
                              Row(
                                children: [
                                  const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        doctor,
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              // second line: status • date • sequence
                              Wrap(
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10.w,
                                runSpacing: 6.h,
                                children: [
                                  Text(
                                    statusLabel(status),
                                    style: TextStyle(
                                      color: statusColor(status),
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  _dot(),
                                  Text(
                                    _formatDate(date),
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  _dot(),
                                  Text(
                                    'التسلسل : $order',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot() => Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: Color(0xFFFFC107), shape: BoxShape.circle),
      );
}

