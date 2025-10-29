import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/secretary_appointment_details_controller.dart';
import '../../controller/secretary_appointments_controller.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final String name;
  final String age;
  final String gender;
  final String phone;
  final String date;
  final String time;
  final String price;
  final String paymentStatus;
  final int seq;
  final String? appointmentId;

  const AppointmentDetailsPage({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.date,
    required this.time,
    required this.price,
    required this.paymentStatus,
    required this.seq,
    this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    print('🟡 ========== AppointmentDetailsPage Build ==========');
    print('🟡 appointmentId parameter: $appointmentId');
    print('🟡 paymentStatus: $paymentStatus');

    final controller = Get.put(SecretaryAppointmentDetailsController());
    controller.appointmentId = appointmentId;
    controller.status.value = paymentStatus;

    print('🟡 Controller appointmentId set to: ${controller.appointmentId}');
    print('🟡 Controller status set to: ${controller.status.value}');
    print('🟡 ================================================');
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FEFF),
        elevation: 0,
        title: MyText(
          'تفاصيل الموعد',
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _infoCard(),
            SizedBox(height: 16.h),
            _seqCard(),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0xFF7CC7D0)),
                      foregroundColor: const Color(0xFF7CC7D0),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                    ),
                    child: MyText(
                      'طباعة',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7CC7D0),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _showChangeStatusSheet(context, controller: controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CC7D0),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      elevation: 0,
                    ),
                    child: MyText(
                      'تعيين حالة الموعد',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
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
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _row('اسم المريض', name),
          SizedBox(height: 8.h),
          _row('العمر', age),
          SizedBox(height: 8.h),
          _row('الجنس', gender),
          SizedBox(height: 8.h),
          _row('رقم الهاتف', phone, underlineValue: true),
          Divider(color: AppColors.divider, height: 32.h),
          _row('تاريخ الحجز', date),
          SizedBox(height: 8.h),
          _row('وقت الحجز', time),
          SizedBox(height: 8.h),
          _row('سعر الحجز', price),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() {
                final ctrl = Get.find<SecretaryAppointmentDetailsController>();
                return MyText(
                  ctrl.status.value,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2ECC71),
                );
              }),
              SizedBox(width: 8.w),
              MyText(
                'الحالة',
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seqCard() {
    final secretaryCtrl = Get.find<SecretaryAppointmentsController>();

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
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
      child: Obx(() {
        final currentNumber = secretaryCtrl.currentAppointmentNumber.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Current Appointment Number
            Expanded(
              child: Column(
                children: [
                  MyText(
                    currentNumber?.toString() ?? '-',
                    fontSize: 56.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF7CC7D0),
                  ),
                  SizedBox(height: 4.h),
                  MyText(
                    'الموعد الحالي',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7CC7D0),
                  ),
                ],
              ),
            ),

            // Divider
            Container(height: 80.h, width: 2.w, color: AppColors.divider),

            // Appointment Sequence
            Expanded(
              child: Column(
                children: [
                  MyText(
                    '$seq',
                    fontSize: 56.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 4.h),
                  MyText(
                    'تسلسل الموعد',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _row(String label, String value, {bool underlineValue = false}) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: MyText(
              label,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        MyText(
          value,
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  void _showChangeStatusSheet(
    BuildContext context, {
    required SecretaryAppointmentDetailsController controller,
  }) {
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
                    controller.updateStatus('مؤكد');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2ECC71),
                  ),
                  title: const Text('تعيين كمكتمل'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.updateStatus('مكتمل');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Color(0xFFFF3B30)),
                  title: const Text('تعيين كملغي'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.updateStatus('ملغي');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person_off,
                    color: Color(0xFFE91E63),
                  ),
                  title: const Text('تعيين كلم يحضر'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.updateStatus('لم يحضر');
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
}
