import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/past_appointments_controller.dart';
import '../../controller/session_controller.dart';
import '../../controller/appointment_details_controller.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> details;
  const AppointmentDetailsPage({super.key, required this.details});

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

  String labelFromCode(String code) {
    // Since we now pass Arabic status directly, just return it
    return code;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentDetailsController());
    final String patient = (details['patient'] ?? 'اسم المريض') as String;
    final int? age = details['age'] as int?;
    final String phone = (details['phone'] ?? '0770 000 0000') as String;
    final String date =
        (details['date'] ?? _formatDate(DateTime.now())) as String;
    final String time = (details['time'] ?? '6:00 صباحاً') as String;
    final String price = (details['price'] ?? '10,000 د.ع') as String;
    final int? order = details['order'] as int?;
    final String appointmentId = (details['appointmentId'] ?? '') as String;

    final String statusText =
        (details['statusText'] ?? 'قيد الانتظار') as String;
    final Color statusColor =
        (details['statusColor'] as Color?) ?? this.statusColor(statusText);

    print('📋 APPOINTMENT DETAILS: appointmentId=$appointmentId');
    print('📋 WIDGET DETAILS: $details');

    final role = Get.find<SessionController>().role.value;
    final bool canChange = role == 'doctor' || role == 'secretary';
    print('📋 USER ROLE: $role, canChange: $canChange');
    final pastCtrl = Get.isRegistered<PastAppointmentsController>()
        ? Get.find<PastAppointmentsController>()
        : Get.put(PastAppointmentsController());

    // تحميل التقييم مرة واحدة فقط عند الدخول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.triedLoadRating.value) return;
      final role = Get.find<SessionController>().role.value;
      if (role == 'user' && statusText == 'مكتمل' && appointmentId.isNotEmpty) {
        controller.triedLoadRating.value = true;
        controller.loadAppointmentRating(appointmentId);
      }
    });

    // تحميل رقم الموعد الحالي
    final String doctorId = (details['doctorId'] ?? '') as String;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (doctorId.isNotEmpty &&
          controller.currentAppointmentNumber.value == null &&
          !controller.isLoadingCurrentAppointment.value) {
        controller.loadCurrentAppointmentNumber(doctorId);
      }
    });

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
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
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
                        statusText,
                        valueColor: statusColor,
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Ratings card (user only when completed)
                if (role == 'user' && statusText == 'مكتمل')
                  _buildRatingsCard(
                    appointmentId: appointmentId,
                    doctorId: (details['doctorId'] ?? '') as String,
                    controller: controller,
                  ),

                SizedBox(height: 16.h),

                // Card 2: Order number and current appointment
                _infoCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
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
                          Container(
                            width: 1,
                            height: 80.h,
                            color: AppColors.divider,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Obx(
                                  () => MyText(
                                    controller.isLoadingCurrentAppointment.value
                                        ? '...'
                                        : (controller
                                                  .currentAppointmentNumber
                                                  .value
                                                  ?.toString() ??
                                              '-'),
                                    fontSize: 54.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                MyText(
                                  'الموعد الحالي',
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
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
                      onPressed: () => _showChangeStatusSheet(
                        context,
                        onPick: (code) async {
                          print(
                            '🔴 BUTTON CLICKED: Trying to change status to $code for appointmentId: $appointmentId',
                          );
                          if (appointmentId.isEmpty) {
                            Get.snackbar('فشل', 'معرّف الموعد غير موجود');
                            return;
                          }
                          final ok = await pastCtrl.changeStatus(
                            appointmentId,
                            code,
                          );
                          print('🔴 CHANGE STATUS RESULT: $ok');
                          if (ok) {
                            final newLabel = labelFromCode(code);

                            // إعادة جلب رقم الموعد الحالي بعد تغيير الحالة
                            final String doctorId =
                                (details['doctorId'] ?? '') as String;
                            if (doctorId.isNotEmpty) {
                              controller.loadCurrentAppointmentNumber(doctorId);
                            }

                            Get.snackbar(
                              'تم',
                              'تم تحديث حالة الموعد إلى $newLabel',
                            );
                          } else {
                            Get.snackbar(
                              'فشل',
                              'تعذر تغيير الحالة - تحقق من الاتصال',
                            );
                          }
                        },
                      ),
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

  void _showChangeStatusSheet(
    BuildContext context, {
    required void Function(String) onPick,
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
                    onPick('مؤكد'); // Arabic confirmed
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

  Widget _twoCols(
    String label,
    String value, {
    bool underlineValue = false,
    Color? valueColor,
    bool isBold = false,
  }) {
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
              decoration: underlineValue
                  ? TextDecoration.underline
                  : TextDecoration.none,
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

  Widget _buildRatingsCard({
    required String appointmentId,
    required String doctorId,
    required AppointmentDetailsController controller,
  }) {
    return Obx(
      () => _infoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  'تقييم الموعد',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                if (controller.isLoadingRating.value)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            if (controller.ratingId.value != null &&
                controller.ratingValue.value != null) ...[
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: _starsRow(controller.ratingValue.value!),
              ),
              if ((controller.ratingComment.value ?? '').isNotEmpty) ...[
                SizedBox(height: 10.h),
                MyText(
                  controller.ratingComment.value!,
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.right,
                ),
              ],
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _openRatingDialog(
                        appointmentId: appointmentId,
                        doctorId: doctorId,
                        initialRating: controller.ratingValue.value!,
                        controller: controller,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: MyText(
                        'تعديل التقييم',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await controller.deleteRating();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFFF3B30),
                          width: 1.5,
                        ),
                        foregroundColor: const Color(0xFFFF3B30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: MyText(
                        'حذف',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFF3B30),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: controller.isLoadingRating.value
                      ? null
                      : () => _openRatingDialog(
                          appointmentId: appointmentId,
                          doctorId: doctorId,
                          controller: controller,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: MyText(
                    'قيّم هذا الموعد',
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
    );
  }

  Widget _starsRow(int rating, {void Function(int)? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: onTap == null ? null : () => onTap(i + 1),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: const Color(0xFFFFB800),
            size: 28.r,
          ),
        );
      }),
    );
  }

  Future<void> _openRatingDialog({
    required String appointmentId,
    required String doctorId,
    AppointmentDetailsController? controller,
    int initialRating = 5,
  }) async {
    final ratingCtrl = ValueNotifier<int>(initialRating);
    await Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        backgroundColor: const Color(0xFFF4FEFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Icon(
                  Icons.star_rounded,
                  color: AppColors.primary,
                  size: 48.r,
                ),
              ),
              SizedBox(height: 10.h),
              MyText(
                'تقييم الموعد',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              ValueListenableBuilder<int>(
                valueListenable: ratingCtrl,
                builder: (_, value, __) =>
                    _starsRow(value, onTap: (v) => ratingCtrl.value = v),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: MyText(
                        'إلغاء',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final int r = ratingCtrl.value.clamp(1, 5);
                        Get.back();
                        if (controller != null) {
                          await controller.saveRating(
                            appointmentId: appointmentId,
                            rating: r,
                            comment: null,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: MyText(
                        'حفظ',
                        fontSize: 16.sp,
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
      ),
      barrierDismissible: false,
    );
  }
}
