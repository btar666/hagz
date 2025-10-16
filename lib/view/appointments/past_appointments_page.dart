import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
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
      case 'confirmed':
        return 'مؤكد';
      default:
        return s;
    }
  }

  String _formatDate(DateTime dt) => '${dt.year}/${dt.month}/${dt.day}';

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
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
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
                            hintText: 'ابحث عن مريض ..',
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
              // Doctor date range filter
              Obx(() {
                if (!Get.find<PastAppointmentsController>().isDoctor) {
                  return const SizedBox.shrink();
                }
                final c = Get.find<PastAppointmentsController>();
                final String start = c.startDate.value != null
                    ? _formatDate(c.startDate.value!)
                    : '—';
                final String end = c.endDate.value != null
                    ? _formatDate(c.endDate.value!)
                    : '—';
                return Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primary, size: 18.r),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'الفترة: $start - $end',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              initialDateRange: c.startDate.value != null && c.endDate.value != null
                                  ? DateTimeRange(start: c.startDate.value!, end: c.endDate.value!)
                                  : null,
                              locale: const Locale('ar'),
                            );
                            if (picked != null) {
                              c.setDateRange(picked.start, picked.end);
                            }
                          },
                          child: const Text('تحديد الفترة'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 12.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (controller.filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'لا توجد مواعيد',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextButton(
                            onPressed: controller.loadAppointments,
                            child: const Text('تحديث'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
                    itemCount: controller.filtered.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                    itemBuilder: (_, i) {
                      final item = controller.filtered[i];
                      final String title = item['title'] as String;
                      final DateTime date = item['date'] as DateTime;
                      final String status = item['status'] as String;
                      final String time = item['time'] as String;
                      return InkWell(
                        onTap: () {
                          final sColor = statusColor(status);
                          final sText = statusLabel(status);
                          final String price = '${item['amount'] ?? 0} د.ع';

                          // بناء تفاصيل الصفحة - عرض معلومات المريض دائماً
                          final details = <String, dynamic>{
                            'patient': item['patientName'] ?? title,
                            'order': item['appointmentSequence'],
                            'time': time.isEmpty ? '—' : time,
                            'statusText': sText,
                            'statusColor': sColor,
                            'age': item['patientAge'],
                            'phone': item['patientPhone'] ?? '—',
                            'date': _formatDate(date),
                            'price': price,
                          };

                          Get.to(() => AppointmentDetailsPage(details: details));
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // top line RTL: title on right, arrow on left
                              Row(
                                children: [
                                  const Icon(
                                    Icons.chevron_left,
                                    color: AppColors.textSecondary,
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              // second line RTL: status • date • (sequence) • time
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
                                  if (item['appointmentSequence'] != null) ...[
                                    _dot(),
                                    Text(
                                      'التسلسل : ${item['appointmentSequence']}',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                  _dot(),
                                  Text(
                                    time.isEmpty ? '—' : time,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),

                              // actions row (doctor): change status
                              Obx(() {
                                final c = Get.find<PastAppointmentsController>();
                                if (!c.isDoctor) return const SizedBox.shrink();
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: () => _showChangeStatusSheet(
                                      context,
                                      onPick: (status) async {
                                        final ok = await c.changeStatus(
                                          item['_id'] as String,
                                          status,
                                        );
                                        if (!ok) {
                                          Get.snackbar('فشل', 'تعذر تغيير الحالة');
                                        }
                                      },
                                    ),
                                    icon: const Icon(Icons.sync_alt, size: 18, color: AppColors.primary),
                                    label: const Text('تغيير الحالة'),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
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
    decoration: const BoxDecoration(
      color: Color(0xFFFFC107),
      shape: BoxShape.circle,
    ),
  );
}

void _showChangeStatusSheet(BuildContext context, {required void Function(String) onPick}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.verified, color: AppColors.primary),
                title: const Text('تعيين كمؤكد'),
                onTap: () {
                  Navigator.pop(context);
                  onPick('confirmed');
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Color(0xFF2ECC71)),
                title: const Text('تعيين كمكتمل'),
                onTap: () {
                  Navigator.pop(context);
                  onPick('completed');
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Color(0xFFFF3B30)),
                title: const Text('تعيين كملغي'),
                onTap: () {
                  Navigator.pop(context);
                  onPick('cancelled');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
