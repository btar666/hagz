import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/past_appointments_controller.dart';
import '../../controller/session_controller.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> details;
  const AppointmentDetailsPage({super.key, required this.details});

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  late String _statusText;
  late Color _statusColor;

  Color statusColor(String s) {
    switch (s) {
      case 'مكتمل':
        return const Color(0xFF2ECC71);
      case 'قيد الانتظار':
        return const Color(0xFFFFA000);
      case 'ملغي':
        return const Color(0xFFFF3B30);
      case 'مؤكد':
        return const Color(0xFF18A2AE);
      default:
        return AppColors.textSecondary;
    }
  }

  String labelFromCode(String code) {
    // Since we now pass Arabic status directly, just return it
    return code;
  }

  @override
  void initState() {
    super.initState();
    _statusText = (widget.details['statusText'] ?? 'قيد الانتظار') as String;
    _statusColor = (widget.details['statusColor'] as Color?) ?? statusColor(_statusText);
  }

  @override
  Widget build(BuildContext context) {
    final String patient = (widget.details['patient'] ?? 'اسم المريض') as String;
    final int? age = widget.details['age'] as int?;
    final String phone = (widget.details['phone'] ?? '0770 000 0000') as String;
    final String date = (widget.details['date'] ?? _formatDate(DateTime.now())) as String;
    final String time = (widget.details['time'] ?? '6:00 صباحاً') as String;
    final String price = (widget.details['price'] ?? '10,000 د.ع') as String;
    final int? order = widget.details['order'] as int?;
    final String appointmentId = (widget.details['appointmentId'] ?? '') as String;
    
    print('📋 APPOINTMENT DETAILS: appointmentId=$appointmentId');
    print('📋 WIDGET DETAILS: ${widget.details}');

    final role = Get.find<SessionController>().role.value;
    final bool canChange = role == 'doctor' || role == 'secretary';
    print('📋 USER ROLE: $role, canChange: $canChange');
    final pastCtrl = Get.isRegistered<PastAppointmentsController>()
        ? Get.find<PastAppointmentsController>()
        : Get.put(PastAppointmentsController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FEFF),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
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
                        child: MyText(
                          'تفاصيل الموعد',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 48.h),
                  ],
                ),
                SizedBox(height: 16.h),

                // Card 1: Patient and booking info
                _infoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _twoCols('اسم المريض', patient),
                      SizedBox(height: 8.h),
                      _twoCols('العمر', age?.toString() ?? '-'),
                      SizedBox(height: 8.h),
                      _twoCols('رقم الهاتف', phone, underlineValue: true),
                      SizedBox(height: 12.h),
                      const Divider(color: AppColors.divider),
                      SizedBox(height: 12.h),
                      _twoCols('تاريخ الحجز', date),
                      SizedBox(height: 8.h),
                      _twoCols('وقت الحجز', time),
                      SizedBox(height: 8.h),
                      _twoCols('سعر الحجز', price),
                      SizedBox(height: 8.h),
                      _twoCols(
                        'الحالة',
                        _statusText,
                        valueColor: _statusColor,
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Card 2: Order number
                _infoCard(
                  child: Column(
                    children: [
                      MyText(
                        order?.toString() ?? '-',
                        fontSize: 54.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(height: 8.h),
                      MyText(
                        'تسلسل الموعد',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),

                // Change status button at bottom (doctor/secretary only)
                if (canChange && appointmentId.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Container(
                    width: double.infinity,
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: ElevatedButton.icon(
                      onPressed: () => _showChangeStatusSheet(context, onPick: (code) async {
                        print('🔴 BUTTON CLICKED: Trying to change status to $code for appointmentId: $appointmentId');
                        if (appointmentId.isEmpty) {
                          Get.snackbar('فشل', 'معرّف الموعد غير موجود');
                          return;
                        }
                        final ok = await pastCtrl.changeStatus(appointmentId, code);
                        print('🔴 CHANGE STATUS RESULT: $ok');
                        if (ok) {
                          final newLabel = labelFromCode(code);
                          setState(() {
                            _statusText = newLabel;
                            _statusColor = statusColor(newLabel);
                          });
                          Get.snackbar('تم', 'تم تحديث حالة الموعد إلى $newLabel');
                        } else {
                          Get.snackbar('فشل', 'تعذر تغيير الحالة - تحقق من الاتصال');
                        }
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.sync_alt, size: 20),
                      label: MyText(
                        'تغيير حالة الموعد',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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
                    onPick('مؤكد'); // Arabic confirmed
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Color(0xFF2ECC71)),
                  title: const Text('تعيين كمكتمل'),
                  onTap: () {
                    Navigator.pop(context);
                    onPick('مكتمل'); // Arabic completed
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Color(0xFFFF3B30)),
                  title: const Text('تعيين كملغي'),
                  onTap: () {
                    Navigator.pop(context);
                    onPick('ملغي'); // Arabic cancelled
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

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10)],
      ),
      child: child,
    );
  }

  Widget _twoCols(String label, String value, {bool underlineValue = false, Color? valueColor, bool isBold = false}) {
    return Row(
      children: [
        Expanded(
          child: MyText(
            label,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              decoration: underlineValue ? TextDecoration.underline : TextDecoration.none,
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              fontFamily: 'Expo Arabic',
              fontSize: 20.sp,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) => '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}

