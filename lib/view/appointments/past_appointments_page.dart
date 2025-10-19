import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../controller/past_appointments_controller.dart';
import '../appointments/appointment_details_page.dart';
import '../../controller/session_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
              // Doctor/Secretary date range filter
              Obx(() {
                final role = Get.find<SessionController>().role.value;
                final showFilter = role == 'doctor' || role == 'secretary';
                if (!showFilter) {
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
                        TextButton.icon(
                          onPressed: () => _showDateRangeFilterSheet(context),
                          icon: const Icon(Icons.tune, color: AppColors.primary, size: 18),
                          label: const Text('تحديد الفترة'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 12.h),
              Expanded(
                child: Obx(() {
                  final isLoading = controller.isLoading.value;
                  final items = controller.filtered;

                  if (!isLoading && items.isEmpty) {
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

                  return Skeletonizer(
                    enabled: isLoading,
                    child: ListView.separated(
                      padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
                      itemCount: isLoading ? 8 : items.length,
                      separatorBuilder: (_, __) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                      itemBuilder: (_, i) {
                        final hasReal = !isLoading && i < items.length;
                        final item = hasReal
                            ? items[i]
                            : {
                                'title': '—',
                                'date': DateTime.now(),
                                'status': 'pending',
                                'time': '',
                                'amount': 0,
                              };
                        final String title = item['title'] as String;
                        final DateTime date = item['date'] as DateTime;
                        final String status = item['status'] as String;
                        final String time = item['time'] as String;
                        return InkWell(
                          onTap: hasReal
                              ? () {
                                  final sColor = statusColor(status);
                                  final sText = statusLabel(status);
                                  final String price = '${item['amount'] ?? 0} د.ع';

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
                                    'appointmentId': item['_id'],
                                    'doctorId': item['doctorId'] ?? '',
                                  };

                                  Get.to(() => AppointmentDetailsPage(details: details));
                                }
                              : null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
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
                                      time.isEmpty ? '—' : time,
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

void _showDateRangeFilterSheet(BuildContext context) {
  final c = Get.find<PastAppointmentsController>();
  DateTime tempStart = c.startDate.value ?? DateTime.now().subtract(const Duration(days: 30));
  DateTime tempEnd = c.endDate.value ?? DateTime.now();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            Widget _chip(String label, VoidCallback onTap) {
              return GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Expo Arabic',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }

            Future<void> pickStart() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: tempStart,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                locale: const Locale('ar'),
              );
              if (picked != null) {
                setModalState(() {
                  tempStart = picked;
                  if (tempEnd.isBefore(tempStart)) tempEnd = tempStart;
                });
              }
            }

            Future<void> pickEnd() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: tempEnd,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                locale: const Locale('ar'),
              );
              if (picked != null) {
                setModalState(() {
                  tempEnd = picked;
                  if (tempStart.isAfter(tempEnd)) tempStart = tempEnd;
                });
              }
            }

            void applyQuickRange(String key) {
              final now = DateTime.now();
              switch (key) {
                case 'today':
                  tempStart = DateTime(now.year, now.month, now.day);
                  tempEnd = DateTime(now.year, now.month, now.day);
                  break;
                case 'last7':
                  tempEnd = DateTime(now.year, now.month, now.day);
                  tempStart = tempEnd.subtract(const Duration(days: 6));
                  break;
                case 'thisMonth':
                  tempStart = DateTime(now.year, now.month, 1);
                  tempEnd = now;
                  break;
                case 'lastMonth':
                  final firstThisMonth = DateTime(now.year, now.month, 1);
                  final lastMonthEnd = firstThisMonth.subtract(const Duration(days: 1));
                  tempStart = DateTime(lastMonthEnd.year, lastMonthEnd.month, 1);
                  tempEnd = DateTime(lastMonthEnd.year, lastMonthEnd.month, lastMonthEnd.day);
                  break;
                case 'last30':
                  tempEnd = DateTime(now.year, now.month, now.day);
                  tempStart = tempEnd.subtract(const Duration(days: 29));
                  break;
              }
              setModalState(() {});
            }

            String fmt(DateTime d) => '${d.year}/${d.month}/${d.day}';

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.date_range, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'تحديد الفترة',
                          style: TextStyle(
                            fontFamily: 'Expo Arabic',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip('اليوم', () => applyQuickRange('today')),
                        _chip('آخر 7 أيام', () => applyQuickRange('last7')),
                        _chip('هذا الشهر', () => applyQuickRange('thisMonth')),
                        _chip('الشهر الماضي', () => applyQuickRange('lastMonth')),
                        _chip('آخر 30 يوم', () => applyQuickRange('last30')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.login, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              const Text('بداية الفترة', style: TextStyle(fontFamily: 'Expo Arabic', fontWeight: FontWeight.w700)),
                              const Spacer(),
                              TextButton(
                                onPressed: pickStart,
                                child: Text(fmt(tempStart)),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Icon(Icons.logout, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              const Text('نهاية الفترة', style: TextStyle(fontFamily: 'Expo Arabic', fontWeight: FontWeight.w700)),
                              const Spacer(),
                              TextButton(
                                onPressed: pickEnd,
                                child: Text(fmt(tempEnd)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            c.setDateRange(null, null);
                            Navigator.pop(context);
                          },
                          child: const Text('مسح'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            c.setDateRange(tempStart, tempEnd);
                            Navigator.pop(context);
                          },
                          child: const Text('تطبيق'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
