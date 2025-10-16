import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/appointments_controller.dart';
import '../../widget/my_text.dart';
import 'appointment_confirmation_page.dart';

class AppointmentDateTimePage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String patientPhone;

  const AppointmentDateTimePage({
    Key? key,
    required this.doctorId,
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
  final AppointmentsController _appointmentsController = Get.put(
    AppointmentsController(),
  );

  DateTime selectedDate = DateTime.now();
  String? selectedTime;

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

  @override
  void initState() {
    super.initState();
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    await _appointmentsController.getAvailableSlots(
      doctorId: widget.doctorId,
      date: dateStr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    // حساب أيام الأسبوع الحالي
    final now = selectedDate;
    final weekStart = now.subtract(Duration(days: now.weekday % 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText(
              'اختر تاريخ الموعد',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              textAlign: TextAlign.right,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = selectedDate.subtract(
                        const Duration(days: 7),
                      );
                      selectedTime = null;
                    });
                    _loadAvailableSlots();
                  },
                  child: Icon(
                    Icons.chevron_right,
                    size: 24.r,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(width: 8.w),
                MyText(
                  '${selectedDate.year} , ${selectedDate.month}',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = selectedDate.add(const Duration(days: 7));
                      selectedTime = null;
                    });
                    _loadAvailableSlots();
                  },
                  child: Icon(
                    Icons.chevron_left,
                    size: 24.r,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
        // التقويم الأفقي
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE6F2F1), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = weekStart.add(Duration(days: index));
              final isSelected =
                  day.day == selectedDate.day &&
                  day.month == selectedDate.month &&
                  day.year == selectedDate.year;
              final isPast = day.isBefore(
                DateTime.now().subtract(const Duration(days: 1)),
              );

              return Expanded(
                child: GestureDetector(
                  onTap: isPast
                      ? null
                      : () {
                          setState(() {
                            selectedDate = day;
                            selectedTime = null;
                          });
                          _loadAvailableSlots();
                        },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF7FC8D6)
                          : isPast
                          ? Colors.grey[100]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                      border: isSelected
                          ? Border.all(color: const Color(0xFF7FC8D6), width: 2)
                          : null,
                    ),
                    child: Column(
                      children: [
                        MyText(
                          weekDays[day.weekday % 7],
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isPast
                              ? Colors.grey[400]
                              : Colors.black87,
                        ),
                        SizedBox(height: 6.h),
                        MyText(
                          '${day.day}',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : isPast
                              ? Colors.grey[400]
                              : Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Obx(() {
      final isLoading = _appointmentsController.isLoadingSlots.value;
      final slots = _appointmentsController.availableSlots;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MyText(
            'اختر وقت الموعد',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 20.h),
          isLoading
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: const CircularProgressIndicator(
                      color: Color(0xFF7FC8D6),
                    ),
                  ),
                )
              : slots.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48.r,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        MyText(
                          'لا توجد أوقات متاحة في هذا التاريخ',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // حساب عرض كل عنصر: (العرض الكلي - المسافات) / 3
                    final totalSpacing = 12.w * 2; // مسافتان بين 3 عناصر
                    final itemWidth = (constraints.maxWidth - totalSpacing) / 3;

                    return Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      alignment: WrapAlignment.end,
                      children: slots.map((slot) {
                        final isSelected = selectedTime == slot;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTime = slot;
                            });
                          },
                          child: Container(
                            width: itemWidth,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF7FC8D6)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF7FC8D6)
                                    : Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: MyText(
                                '$slot ص',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
        ],
      );
    });
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
              onPressed: selectedTime == null
                  ? null
                  : () {
                      final formattedDate = DateFormat(
                        'yyyy/MM/dd',
                      ).format(selectedDate);
                      Get.to(
                        () => AppointmentConfirmationPage(
                          doctorId: widget.doctorId,
                          doctorName: widget.doctorName,
                          doctorSpecialty: widget.doctorSpecialty,
                          patientName: widget.patientName,
                          patientAge: widget.patientAge,
                          patientGender: widget.patientGender,
                          patientPhone: widget.patientPhone,
                          appointmentDate: formattedDate,
                          appointmentTime: selectedTime!,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7FC8D6),
                disabledBackgroundColor: Colors.grey[300],
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
