import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/appointment_status_set_dialog.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final String name;
  final String age;
  final String gender;
  final String phone;
  final String date;
  final String time;
  final String price;
  final String paymentStatus;
  final int seq;

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
  });

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.paymentStatus;
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () async {
                      final String? status = await showDialog(
                        context: context,
                        builder: (_) => const AppointmentStatusSetDialog(),
                      );
                      if (status != null && mounted) {
                        setState(() => _status = status);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم تعيين الحالة: $status'),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
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
          _row('اسم المريض', widget.name),
          SizedBox(height: 8.h),
          _row('العمر', widget.age),
          SizedBox(height: 8.h),
          _row('الجنس', widget.gender),
          SizedBox(height: 8.h),
          _row('رقم الهاتف', widget.phone, underlineValue: true),
          Divider(color: AppColors.divider, height: 32.h),
          _row('تاريخ الحجز', widget.date),
          SizedBox(height: 8.h),
          _row('وقت الحجز', widget.time),
          SizedBox(height: 8.h),
          _row('سعر الحجز', widget.price),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyText(
                _status,
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2ECC71),
              ),
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
      padding: EdgeInsets.symmetric(vertical: 28.h),
      child: Column(
        children: [
          MyText(
            '${widget.seq}',
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
}
