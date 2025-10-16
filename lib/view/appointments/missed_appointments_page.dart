import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/appointments_controller.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';

class MissedAppointmentsPage extends StatefulWidget {
  final String doctorId;

  const MissedAppointmentsPage({
    Key? key,
    required this.doctorId,
  }) : super(key: key);

  @override
  State<MissedAppointmentsPage> createState() => _MissedAppointmentsPageState();
}

class _MissedAppointmentsPageState extends State<MissedAppointmentsPage> {
  final AppointmentsController _controller = Get.put(AppointmentsController());
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMissedAppointments();
  }

  Future<void> _loadMissedAppointments() async {
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    
    await _controller.loadMissedAppointments(
      doctorId: widget.doctorId,
      startDate: startDateStr,
      endDate: endDateStr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: MyText(
          'المواعيد المفقودة',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.r,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _selectDateRange(),
            icon: Icon(
              Icons.date_range,
              color: AppColors.primary,
              size: 24.r,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateRangeCard(),
          Expanded(
            child: Obx(() {
              final appointments = _controller.missedAppointments;
              
              if (appointments.isEmpty) {
                return _buildEmptyState();
              }
              
              return RefreshIndicator(
                onRefresh: _loadMissedAppointments,
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(appointments[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: AppColors.primary,
            size: 20.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: MyText(
              'الفترة: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Obx(() {
            final count = _controller.missedAppointments.length;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: MyText(
                '$count موعد',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.error.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: MyText(
                  'لم يحضر',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              const Spacer(),
              MyText(
                appointment['patientName'] ?? 'غير محدد',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                textAlign: TextAlign.right,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.phone,
                color: AppColors.textSecondary,
                size: 16.r,
              ),
              SizedBox(width: 4.w),
              MyText(
                appointment['patientPhone'] ?? 'غير محدد',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              const Spacer(),
              Icon(
                Icons.access_time,
                color: AppColors.textSecondary,
                size: 16.r,
              ),
              SizedBox(width: 4.w),
              MyText(
                appointment['appointmentTime'] ?? '',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.calendar_today,
                color: AppColors.textSecondary,
                size: 16.r,
              ),
              SizedBox(width: 4.w),
              MyText(
                appointment['appointmentDate'] ?? '',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          if (appointment['patientNotes'] != null && 
              appointment['patientNotes'].toString().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: MyText(
                appointment['patientNotes'],
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                textAlign: TextAlign.right,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Row(
            children: [
              MyText(
                'الكلفة: ${appointment['amount']?.toString() ?? '0'} دينار',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64.r,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16.h),
          MyText(
            'لا توجد مواعيد مفقودة',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 8.h),
          MyText(
            'في الفترة المحددة',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _loadMissedAppointments();
    }
  }
}