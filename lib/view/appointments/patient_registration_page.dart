import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widget/my_text.dart';
import 'appointment_datetime_page.dart';

class PatientRegistrationPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;

  const PatientRegistrationPage({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
  }) : super(key: key);

  @override
  State<PatientRegistrationPage> createState() =>
      _PatientRegistrationPageState();
}

class CircularProgressPainter extends CustomPainter {
  final double progress; // 0..1
  final double strokeWidth;
  final Color backgroundColor;
  final Color? progressColor; // used when gradientColors is null
  final List<Color>? gradientColors; // optional gradient for the arc
  final List<double>? gradientStops; // optional stops for gradient
  final double startAngle; // in radians, default -90deg (top)

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

    // Background ring (optional)
    if (backgroundColor.opacity > 0) {
      final backgroundPaint = Paint()
        ..color = backgroundColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, backgroundPaint);
    }

    // Progress arc
    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // If gradient provided, use it
    if (gradientColors != null && gradientColors!.isNotEmpty) {
      progressPaint.shader = SweepGradient(
        colors: gradientColors!,
        stops: gradientStops,
        transform: GradientRotation(startAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      progressPaint.color = progressColor ?? const Color(0xFFFFB800);
    }

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedGender = 'أنثى';
  int? _selectedAge;

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
                        Container(
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
                              _buildPatientNameField(),
                              SizedBox(height: 30.h),
                              _buildAgeField(),
                              SizedBox(height: 30.h),
                              _buildGenderSelection(),
                              SizedBox(height: 30.h),
                              _buildPhoneField(),
                            ],
                          ),
                        ),
                        SizedBox(height: 60.h),
                      ],
                    ),
                  ),
                ),
              ),
              _buildNextButton(),
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
    final double outerSize = 68.w; // badge size close to mockup
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          Divider(color: Colors.grey[300], thickness: 1),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Progress badge at the right (RTL)
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer gradient ring with subtle glow
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
                  // Inner white circle + faint inner border
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
                  // Thin progress arc
                  SizedBox(
                    width: outerSize - 14,
                    height: outerSize - 14,
                    child: CustomPaint(
                      painter: CircularProgressPainter(
                        progress: 1 / 3,
                        strokeWidth: 4.0,
                        backgroundColor: Colors.transparent,
                        progressColor: const Color(0xFFFFB800),
                        startAngle: -math.pi / 2,
                      ),
                    ),
                  ),
                  // Center fraction text
                  MyText(
                    '1/3',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFB800),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      'تسجيل معلومات المريض',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 6.h),
                    MyText(
                      'الخطوة التالية : اختيار تاريخ و وقت الموعد',
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

  Widget _buildPatientNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: MyText(
            'اسم المريض الثلاثي',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            textAlign: TextAlign.right,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8F7),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFFE6F2F1), width: 1),
          ),
          child: TextField(
            controller: _nameController,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 16.sp, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'اكتب اسم المريض',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
              hintTextDirection: TextDirection.rtl,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 18.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: MyText(
            'عمر المريض',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            textAlign: TextAlign.right,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8F7),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFFE6F2F1), width: 1),
          ),
          child: DropdownButtonFormField<int>(
            value: _selectedAge,
            decoration: InputDecoration(
              hintText: 'اختر عمر المريض',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 18.h,
              ),
            ),
            icon: Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[500],
                size: 22.r,
              ),
            ),
            style: TextStyle(fontSize: 16.sp, color: Colors.black87),
            isExpanded: true,
            alignment: Alignment.centerRight,
            items: List.generate(
              100,
              (index) => DropdownMenuItem<int>(
                value: index + 1,
                alignment: Alignment.centerRight,
                child: MyText(
                  '${index + 1} سنة',
                  fontSize: 16.sp,
                  color: Colors.black87,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _selectedAge = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          'الجنس ( اضغط للاختيار )',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 18.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedGender = 'ذكر');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: _selectedGender == 'ذكر'
                          ? const Color(0xFF7FC8D6)
                          : const Color(0xFFE6F2F1),
                      width: _selectedGender == 'ذكر' ? 2 : 1,
                    ),
                    boxShadow: _selectedGender == 'ذكر'
                        ? [
                            BoxShadow(
                              color: const Color(0x1A7FC8D6),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: MyText(
                      'ذكر',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: _selectedGender == 'ذكر'
                          ? const Color(0xFF2CB8C6)
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedGender = 'أنثى');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: _selectedGender == 'أنثى'
                          ? const Color(0xFF7FC8D6)
                          : const Color(0xFFE6F2F1),
                      width: _selectedGender == 'أنثى' ? 2 : 1,
                    ),
                    boxShadow: _selectedGender == 'أنثى'
                        ? [
                            BoxShadow(
                              color: const Color(0x1A7FC8D6),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: MyText(
                      'أنثى',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: _selectedGender == 'أنثى'
                          ? const Color(0xFF2CB8C6)
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: MyText(
            'رقم الهاتف',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            textAlign: TextAlign.right,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8F7),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFFE6F2F1), width: 1),
          ),
          child: TextField(
            controller: _phoneController,
            textAlign: TextAlign.right,
            textDirection: TextDirection.ltr, // أرقام الهاتف تبقى LTR
            keyboardType: TextInputType.phone,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black87,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '0000 000 0000',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 18.sp,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
              hintTextDirection: TextDirection.ltr,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 18.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Container(
      padding: EdgeInsets.all(30.w),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // فحص صحة البيانات
            if (_nameController.text.trim().isEmpty) {
              Get.snackbar('خطأ', 'يرجى إدخال اسم المريض');
              return;
            }
            if (_selectedAge == null) {
              Get.snackbar('خطأ', 'يرجى إختيار العمر');
              return;
            }
            if (_phoneController.text.trim().isEmpty) {
              Get.snackbar('خطأ', 'يرجى إدخال رقم الهاتف');
              return;
            }

            Get.to(
              () => AppointmentDateTimePage(
                doctorId: widget.doctorId,
                doctorName: widget.doctorName,
                doctorSpecialty: widget.doctorSpecialty,
                patientName: _nameController.text.trim(),
                patientAge: _selectedAge!,
                patientGender: _selectedGender,
                patientPhone: _phoneController.text.trim(),
              ),
            );
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
            'الخطوة التالية',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
