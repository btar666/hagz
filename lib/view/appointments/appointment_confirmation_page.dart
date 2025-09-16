import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import 'appointment_success_page.dart';

class CircularProgressPainter extends CustomPainter {
  final double progress; // 0..1
  final double strokeWidth;
  final Color backgroundColor;
  final Color? progressColor; // used when gradientColors is null
  final List<Color>? gradientColors;
  final List<double>? gradientStops;
  final double startAngle; // radians

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    this.backgroundColor = Colors.transparent,
    this.progressColor,
    this.gradientColors,
    this.gradientStops,
    this.startAngle = -math.pi / 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (backgroundColor.opacity > 0) {
      final bg = Paint()
        ..color = backgroundColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, bg);
    }

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (gradientColors != null && gradientColors!.isNotEmpty) {
      paint.shader = SweepGradient(
        colors: gradientColors!,
        stops: gradientStops,
        transform: GradientRotation(startAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      paint.color = progressColor ?? const Color(0xFFFFB800);
    }

    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class AppointmentConfirmationPage extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String patientName;
  final String patientAge;
  final String patientGender;
  final String patientPhone;
  final String appointmentDate;
  final String appointmentTime;

  const AppointmentConfirmationPage({
    Key? key,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.patientPhone,
    required this.appointmentDate,
    required this.appointmentTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FEFF),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),
                        _buildDoctorInfo(),
                        SizedBox(height: 30.h),
                        _buildQueueNumber(),
                        SizedBox(height: 20.h),
                        _buildWishMessage(),
                        SizedBox(height: 30.h),
                        _buildBaleyCab(),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
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
            onTap: () => Get.back(),
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

  Widget _buildProgressIndicator() {
    final double outerSize = 68.w;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          Divider(color: Colors.grey[300], thickness: 1),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: outerSize,
                    height: outerSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Color(0xFF5EA6FF),
                          Color(0xFF7E87FF),
                          Color(0xFF5EA6FF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x335EA6FF),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: outerSize - 6,
                    height: outerSize - 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE8F0FF),
                        width: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: outerSize - 14,
                    height: outerSize - 14,
                    child: CustomPaint(
                      painter: CircularProgressPainter(
                        progress: 3 / 3,
                        strokeWidth: 4.0,
                        backgroundColor: Colors.transparent,
                        progressColor: const Color(0xFF4CAF50),
                        startAngle: -math.pi / 2,
                      ),
                    ),
                  ),
                  MyText(
                    '3/3',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4CAF50),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      'الدفع و وصل الحجز',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 6.h),
                    MyText(
                      'يتم الدفع باستخدام الفيزا كارت',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x267FC8D6),
            blurRadius: 35,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          // Doctor avatar and name
          CircleAvatar(
            radius: 35.r,
            backgroundColor: const Color(0xFF7FC8D6),
            child: Icon(Icons.person, size: 40.r, color: Colors.white),
          ),
          SizedBox(height: 15.h),
          MyText(
            doctorName,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5.h),
          MyText(
            doctorSpecialty,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 25.h),
          Divider(color: Colors.grey[200], thickness: 1),
          SizedBox(height: 20.h),
          // Patient and appointment details
          _buildInfoRow('اسم المريض', patientName),
          SizedBox(height: 12.h),
          _buildInfoRow('تاريخ الحجز', appointmentDate),
          SizedBox(height: 12.h),
          _buildInfoRow('وقت الحجز', '$appointmentTime صباحاً'),
          SizedBox(height: 12.h),
          _buildInfoRow('سعر الحجز', '10,000 د.ع', isPrice: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Row(
      children: [
        MyText(
          '$label :',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
          textAlign: TextAlign.right,
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: MyText(
            value,
            fontSize: isPrice ? 18.sp : 16.sp,
            fontWeight: isPrice ? FontWeight.w700 : FontWeight.w600,
            color: isPrice ? const Color(0xFF7FC8D6) : Colors.black87,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueNumber() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x267FC8D6),
            blurRadius: 35,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          MyText(
            '22',
            fontSize: 47.sp,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          MyText(
            'تسلسل الموعد',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWishMessage() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: const Color(0xFFFFB800).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text('🧡', style: TextStyle(fontSize: 24.sp)),
          SizedBox(width: 10.w),
          Expanded(
            child: MyText(
              '" نتمناكم أيام كلها صحة و عافية "',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB45309),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaleyCab() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Center(
              child: MyText(
                'بلي',
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1976D2),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyText(
                  'اضغط هنا و اطلب سيارة أجرة لنقلك',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 5.h),
                MyText(
                  'من شركة بلي',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(30.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 18.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
                side: const BorderSide(color: Color(0xFF7FC8D6), width: 1.5),
              ),
              child: MyText(
                'عودة',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7FC8D6),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => const AppointmentSuccessPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7FC8D6),
                padding: EdgeInsets.symmetric(vertical: 18.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
                elevation: 0,
              ),
              child: MyText(
                'تأكيد و دفع كلفة الحجز',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
