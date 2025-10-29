import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widget/my_text.dart';
import '../../controller/secretary_appointments_controller.dart';
import '../../controller/session_controller.dart';

class AppointmentSuccessPage extends StatelessWidget {
  const AppointmentSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSuccessIcon(),
                    SizedBox(height: 40.h),
                    _buildSuccessMessage(),
                    SizedBox(height: 20.h),
                    _buildSubMessage(),
                    SizedBox(height: 60.h),
                  ],
                ),
              ),
            ),
            _buildHomeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // تحديث بيانات السكرتير إذا كان مسجل دخول
              final session = Get.find<SessionController>();
              if (session.role.value == 'secretary') {
                try {
                  final secretaryController =
                      Get.find<SecretaryAppointmentsController>();
                  secretaryController.loadAppointments();
                  print('✅ Secretary appointments refreshed after booking');
                } catch (e) {
                  print(
                    '⚠️ Could not find SecretaryAppointmentsController: $e',
                  );
                }
              }

              // العودة للصفحة الرئيسية
              Get.until((route) => route.isFirst);
            },
            child: Icon(Icons.close, size: 24.r, color: Colors.black54),
          ),
          const Spacer(),
          MyText(
            'حجز موعد',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          const Spacer(),
          SizedBox(width: 24.w),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        color: const Color(0xFF7FC8D6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7FC8D6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(Icons.check, color: Colors.white, size: 60.r),
    );
  }

  Widget _buildSuccessMessage() {
    return MyText(
      'تم حجز الموعد بنجاح !',
      fontSize: 28.sp,
      fontWeight: FontWeight.w800,
      color: Colors.black87,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubMessage() {
    return Column(
      children: [
        MyText(
          'لطفاً قم بالحضور مبكراً قبل الوقت',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5.h),
        MyText(
          'المحدد للموعد',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHomeButton() {
    return Container(
      padding: EdgeInsets.all(30.w),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // تحديث بيانات السكرتير إذا كان مسجل دخول
            final session = Get.find<SessionController>();
            if (session.role.value == 'secretary') {
              try {
                final secretaryController =
                    Get.find<SecretaryAppointmentsController>();
                secretaryController.loadAppointments();
                print('✅ Secretary appointments refreshed after booking');
              } catch (e) {
                print('⚠️ Could not find SecretaryAppointmentsController: $e');
              }
            }

            // العودة للصفحة الرئيسية وحذف جميع الصفحات السابقة
            Get.until((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7FC8D6),
            padding: EdgeInsets.symmetric(vertical: 18.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
            ),
            elevation: 0,
          ),
          child: MyText(
            'الصفحة الرئيسية',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
