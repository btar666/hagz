import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import 'appointment_confirmation_page.dart';

class AppointmentDateTimePage extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String patientName;
  final String patientAge;
  final String patientGender;
  final String patientPhone;

  const AppointmentDateTimePage({
    Key? key,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.patientPhone,
  }) : super(key: key);

  @override
  State<AppointmentDateTimePage> createState() =>
      _AppointmentDateTimePageState();
}

class CircularProgressPainter extends CustomPainter {
  final double progress; // 0..1
  final double strokeWidth;
  final Color backgroundColor;
  final Color? progressColor; // used when gradientColors is null
  final List<Color>? gradientColors; // optional gradient for the arc
  final List<double>? gradientStops; // optional stops for gradient
  final double startAngle; // in radians

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
      final backgroundPaint = Paint()
        ..color = backgroundColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, backgroundPaint);
    }

    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _AppointmentDateTimePageState extends State<AppointmentDateTimePage> {
  DateTime selectedDate = DateTime.now();
  String selectedTime = '6:00 ص';
  int selectedMonth = 8;
  int selectedYear = 2025;

  final List<String> weekDays = [
    'أحد',
    'اثنين',
    'ثلاثاء',
    'أربعاء',
    'خميس',
    'جمعة',
    'سبت',
  ];
  final List<String> months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  final List<Map<String, dynamic>> timeSlots = [
    {'time': '6:00 ص', 'available': true, 'selected': true},
    {'time': '7:00 ص', 'available': true, 'selected': false},
    {'time': '6:30 ص', 'available': true, 'selected': false},
    {'time': '8:00 ص', 'available': true, 'selected': false},
    {'time': '8:30 ص', 'available': true, 'selected': false},
    {'time': '7:30 ص', 'available': false, 'selected': false},
    {'time': '9:30 ص', 'available': true, 'selected': false},
    {'time': '9:00 ص', 'available': true, 'selected': false},
    {'time': '10:00 ص', 'available': false, 'selected': false},
  ];

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
                              _buildDateSelector(),
                              SizedBox(height: 30.h),
                              _buildTimeSelector(),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h),
                        _buildEarlyArrivalNote(),
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
    final double outerSize = 68.w; // same as page 1
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          Divider(color: Colors.grey[300], thickness: 1),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge at right
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
                        progress: 2 / 3,
                        strokeWidth: 4.0,
                        backgroundColor: Colors.transparent,
                        progressColor: const Color(0xFFFFB800),
                        startAngle: -math.pi / 2,
                      ),
                    ),
                  ),
                  MyText(
                    '2/3',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFB800),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      'اختيار تاريخ و وقت الموعد',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 6.h),
                    MyText(
                      'الخطوة التالية : تأكيد الموعد',
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

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText(
              'اختر تاريخ الموعد',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              textAlign: TextAlign.right,
            ),

            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedMonth < 12) {
                        selectedMonth++;
                      } else {
                        selectedMonth = 1;
                        selectedYear++;
                      }
                    });
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 16.r,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(width: 9.w),
                MyText(
                  '$selectedYear , ${months[selectedMonth - 1]}',
                  fontSize: 16.sp.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                SizedBox(width: 9.w),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedMonth > 1) {
                        selectedMonth--;
                      } else {
                        selectedMonth = 12;
                        selectedYear--;
                      }
                    });
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16.r,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8F7),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFFE6F2F1), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              bool isSelected = index == 4; // Thursday is selected
              return Flexible(
                child: Column(
                  children: [
                    MyText(
                      weekDays[index],
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF7FC8D6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF7FC8D6),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: MyText(
                          '25',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MyText(
          'اختر وقت الموعد',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8F7),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFFE6F2F1), width: 1),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 2.2,
            ),
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              final slot = timeSlots[index];
              return GestureDetector(
                onTap: () {
                  if (slot['available']) {
                    setState(() {
                      for (var s in timeSlots) {
                        s['selected'] = false;
                      }
                      slot['selected'] = true;
                      selectedTime = slot['time'];
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: slot['selected']
                        ? const Color(0xFF7FC8D6)
                        : slot['available']
                        ? Colors.grey[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                    border: slot['selected']
                        ? Border.all(color: const Color(0xFF7FC8D6), width: 2)
                        : Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Center(
                    child: MyText(
                      slot['time'],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: slot['selected']
                          ? Colors.white
                          : slot['available']
                          ? Colors.black87
                          : Colors.grey[400],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEarlyArrivalNote() {
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
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.lightbulb, color: Colors.white, size: 20.r),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: MyText(
              'لطفاً قم بالحضور مبكراً قبل الوقت المحدد للموعد',
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFB45309),
              textAlign: TextAlign.right,
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
                Get.to(
                  () => AppointmentConfirmationPage(
                    doctorName: widget.doctorName,
                    doctorSpecialty: widget.doctorSpecialty,
                    patientName: widget.patientName,
                    patientAge: widget.patientAge,
                    patientGender: widget.patientGender,
                    patientPhone: widget.patientPhone,
                    appointmentDate: '2 / 10 / 2025',
                    appointmentTime: selectedTime,
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
        ],
      ),
    );
  }
}
