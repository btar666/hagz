import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> details;
  const AppointmentDetailsPage({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    // Extract details with safe defaults
    final String patient = (details['patient'] ?? 'اسم المريض') as String;
    final int? age = details['age'] as int?;
    final String gender = (details['gender'] ?? 'غير محدد') as String;
    final String phone = (details['phone'] ?? '0770 000 0000') as String;
    final String date = (details['date'] ?? _formatDate(DateTime.now())) as String;
    final String time = (details['time'] ?? '6:00 صباحاً') as String;
    final String price = (details['price'] ?? '10,000 د.ع') as String;
    final String status = (details['statusText'] ?? 'تم الدفع') as String;
    final Color statusColor = (details['statusColor'] as Color?) ?? const Color(0xFF2ECC71);
    final int? order = details['order'] as int?;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FEFF),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
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
                      _twoCols('الجنس', gender),
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
                        status,
                        valueColor: statusColor,
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
              ],
            ),
          ),
        ),
      ),
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
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) => '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}

