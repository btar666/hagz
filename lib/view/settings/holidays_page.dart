import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/holidays_controller.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/loading_dialog.dart';
import '../../widget/status_dialog.dart';
import '../../widget/confirm_dialogs.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HolidaysPage extends StatelessWidget {
  HolidaysPage({super.key});

  final HolidaysController controller = Get.put(HolidaysController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: MyText(
          'إدارة العطل',
          fontSize: 20.sp,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          // Skeleton while loading holidays
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Skeletonizer(
              enabled: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: MyText('إضافة عطلة جديدة', fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  SizedBox(height: 20.h),
                  MyText('جميع العطل', fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary, textAlign: TextAlign.right),
                  SizedBox(height: 12.h),
                  ...List.generate(3, (_) => _buildHolidayCard({
                        'date': '',
                        'reason': '',
                        'isRecurring': false,
                        'isFullDay': true,
                        '_id': '',
                      })),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // معلومات توضيحية
              _buildInfoCard(),
              SizedBox(height: 16.h),

              // زر إضافة عطلة
              ElevatedButton.icon(
                onPressed: () => _showAddHolidayDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: MyText(
                  'إضافة عطلة جديدة',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),

              // العطل القادمة
              if (controller.upcomingHolidays.isNotEmpty) ...[
                MyText(
                  'العطل القادمة',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 12.h),
                ...controller.upcomingHolidays.map(
                  (holiday) => _buildHolidayCard(holiday),
                ),
                SizedBox(height: 20.h),
              ],

              // جميع العطل
              MyText(
                'جميع العطل',
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 12.h),

              if (controller.holidays.isEmpty)
                _buildEmptyState()
              else
                ...controller.holidays.map(
                  (holiday) => _buildHolidayCard(holiday),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: MyText(
              'أضف العطل الرسمية والعطل الشخصية الخاصة بك',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(Icons.beach_access, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          MyText(
            'لا توجد عطل مضافة بعد',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayCard(Map<String, dynamic> holiday) {
    final date = holiday['date']?.toString() ?? '';
    final reason = holiday['reason']?.toString() ?? '';
    final isRecurring = holiday['isRecurring'] as bool? ?? false;
    final isFullDay = holiday['isFullDay'] as bool? ?? true;
    final holidayId = holiday['_id']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                _getDay(date),
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
              MyText(
                _getMonth(date),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        title: MyText(
          reason,
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          textAlign: TextAlign.right,
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isRecurring)
              Container(
                margin: EdgeInsets.only(left: 4.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: MyText(
                  'متكرر',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF34C759),
                ),
              ),
            if (!isFullDay) ...[
              Icon(
                Icons.access_time,
                size: 14.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4.w),
              MyText(
                '${holiday['startTime']} - ${holiday['endTime']}',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ] else
              MyText(
                'طوال اليوم',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 8,
          offset: Offset(0, 10.h),
          color: Colors.white,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyText(
                      'تعديل',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyText(
                      'حذف',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF3B30),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.delete,
                        size: 18.sp,
                        color: const Color(0xFFFF3B30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditHolidayDialog(Get.context!, holiday);
            } else if (value == 'delete') {
              _deleteHoliday(holidayId);
            }
          },
        ),
      ),
    );
  }

  String _getDay(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return dateTime.day.toString();
    } catch (e) {
      return '';
    }
  }

  String _getMonth(String date) {
    try {
      final dateTime = DateTime.parse(date);
      final months = [
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
      return months[dateTime.month - 1];
    } catch (e) {
      return '';
    }
  }

  Future<void> _showAddHolidayDialog(BuildContext context) async {
    final dateCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final RxBool isRecurring = false.obs;
    final RxBool isFullDay = true.obs;
    final startTimeCtrl = TextEditingController(text: '09:00');
    final endTimeCtrl = TextEditingController(text: '17:00');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFFF4FEFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              MyText(
                'إضافة عطلة جديدة',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // التاريخ
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: dateCtrl,
                    decoration: InputDecoration(
                      labelText: 'التاريخ',
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // السبب
              TextFormField(
                controller: reasonCtrl,
                decoration: InputDecoration(
                  labelText: 'السبب',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 16.h),

              // عطلة متكررة
              Obx(
                () => SwitchListTile(
                  title: MyText(
                    'عطلة متكررة سنوياً',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  value: isRecurring.value,
                  onChanged: (val) => isRecurring.value = val,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              // طوال اليوم
              Obx(
                () => SwitchListTile(
                  title: MyText(
                    'طوال اليوم',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  value: isFullDay.value,
                  onChanged: (val) => isFullDay.value = val,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              // أوقات العطلة (إذا لم تكن طوال اليوم)
              Obx(() {
                if (isFullDay.value) return const SizedBox.shrink();
                return Column(
                  children: [
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: startTimeCtrl,
                            decoration: InputDecoration(
                              labelText: 'من',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            textAlign: TextAlign.center,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (picked != null) {
                                startTimeCtrl.text =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextFormField(
                            controller: endTimeCtrl,
                            decoration: InputDecoration(
                              labelText: 'إلى',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            textAlign: TextAlign.center,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (picked != null) {
                                endTimeCtrl.text =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),

              SizedBox(height: 24.h),

              // زر الحفظ
              ElevatedButton(
                onPressed: () async {
                  if (dateCtrl.text.isEmpty || reasonCtrl.text.isEmpty) {
                    Get.snackbar('خطأ', 'يرجى ملء جميع الحقول المطلوبة');
                    return;
                  }

                  Get.back();
                  await LoadingDialog.show(message: 'جاري الحفظ...');
                  try {
                    final res = await controller.addHoliday(
                      date: dateCtrl.text,
                      reason: reasonCtrl.text,
                      isRecurring: isRecurring.value,
                      isFullDay: isFullDay.value,
                      startTime: isFullDay.value ? null : startTimeCtrl.text,
                      endTime: isFullDay.value ? null : endTimeCtrl.text,
                    );
                    LoadingDialog.hide();
                    if (res['ok'] == true) {
                      await showStatusDialog(
                        title: 'تمت الإضافة',
                        message: 'تم إضافة العطلة بنجاح',
                        color: AppColors.primary,
                        icon: Icons.check_circle_outline,
                      );
                    } else {
                      await showStatusDialog(
                        title: 'فشل الإضافة',
                        message:
                            res['data']?['message']?.toString() ??
                            'تعذر إضافة العطلة',
                        color: const Color(0xFFFF3B30),
                        icon: Icons.error_outline,
                      );
                    }
                  } catch (e) {
                    LoadingDialog.hide();
                    await showStatusDialog(
                      title: 'خطأ',
                      message: 'حدث خطأ أثناء إضافة العطلة',
                      color: const Color(0xFFFF3B30),
                      icon: Icons.error_outline,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                ),
                child: MyText(
                  'حفظ',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditHolidayDialog(
    BuildContext context,
    Map<String, dynamic> holiday,
  ) async {
    final holidayId = holiday['_id']?.toString() ?? '';
    final dateCtrl = TextEditingController(
      text: holiday['date']?.toString() ?? '',
    );
    final reasonCtrl = TextEditingController(
      text: holiday['reason']?.toString() ?? '',
    );
    final RxBool isRecurring = (holiday['isRecurring'] as bool? ?? false).obs;
    final RxBool isFullDay = (holiday['isFullDay'] as bool? ?? true).obs;
    final startTimeCtrl = TextEditingController(
      text: holiday['startTime']?.toString() ?? '09:00',
    );
    final endTimeCtrl = TextEditingController(
      text: holiday['endTime']?.toString() ?? '17:00',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFFF4FEFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              MyText(
                'تعديل العطلة',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // التاريخ
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.tryParse(holiday['date']?.toString() ?? '') ??
                        DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: dateCtrl,
                    decoration: InputDecoration(
                      labelText: 'التاريخ',
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // السبب
              TextFormField(
                controller: reasonCtrl,
                decoration: InputDecoration(
                  labelText: 'السبب',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 16.h),

              // عطلة متكررة
              Obx(
                () => SwitchListTile(
                  title: MyText(
                    'عطلة متكررة سنوياً',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  value: isRecurring.value,
                  onChanged: (val) => isRecurring.value = val,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              // طوال اليوم
              Obx(
                () => SwitchListTile(
                  title: MyText(
                    'طوال اليوم',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  value: isFullDay.value,
                  onChanged: (val) => isFullDay.value = val,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              // أوقات العطلة (إذا لم تكن طوال اليوم)
              Obx(() {
                if (isFullDay.value) return const SizedBox.shrink();
                return Column(
                  children: [
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: startTimeCtrl,
                            decoration: InputDecoration(
                              labelText: 'من',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            textAlign: TextAlign.center,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (picked != null) {
                                startTimeCtrl.text =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextFormField(
                            controller: endTimeCtrl,
                            decoration: InputDecoration(
                              labelText: 'إلى',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            textAlign: TextAlign.center,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (picked != null) {
                                endTimeCtrl.text =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),

              SizedBox(height: 24.h),

              // زر الحفظ
              ElevatedButton(
                onPressed: () async {
                  if (dateCtrl.text.isEmpty || reasonCtrl.text.isEmpty) {
                    Get.snackbar('خطأ', 'يرجى ملء جميع الحقول المطلوبة');
                    return;
                  }

                  Get.back();
                  await LoadingDialog.show(message: 'جاري التحديث...');
                  try {
                    final res = await controller.updateHoliday(
                      holidayId: holidayId,
                      date: dateCtrl.text,
                      reason: reasonCtrl.text,
                      isRecurring: isRecurring.value,
                      isFullDay: isFullDay.value,
                      startTime: isFullDay.value ? null : startTimeCtrl.text,
                      endTime: isFullDay.value ? null : endTimeCtrl.text,
                    );
                    LoadingDialog.hide();
                    if (res['ok'] == true) {
                      await showStatusDialog(
                        title: 'تم التحديث',
                        message: 'تم تحديث العطلة بنجاح',
                        color: AppColors.primary,
                        icon: Icons.check_circle_outline,
                      );
                    } else {
                      await showStatusDialog(
                        title: 'فشل التحديث',
                        message:
                            res['data']?['message']?.toString() ??
                            'تعذر تحديث العطلة',
                        color: const Color(0xFFFF3B30),
                        icon: Icons.error_outline,
                      );
                    }
                  } catch (e) {
                    LoadingDialog.hide();
                    await showStatusDialog(
                      title: 'خطأ',
                      message: 'حدث خطأ أثناء تحديث العطلة',
                      color: const Color(0xFFFF3B30),
                      icon: Icons.error_outline,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                ),
                child: MyText(
                  'تحديث',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteHoliday(String holidayId) async {
    await showActionConfirmDialog(
      title: 'حذف العطلة',
      message: TextSpan(
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Expo Arabic',
        ),
        children: const [
          TextSpan(text: 'هل أنت متأكد ؟ '),
          TextSpan(
            text: 'سيتم حذف العطلة نهائياً',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ],
      ),
      primaryColor: const Color(0xFFFF3B30),
      icon: Icons.warning_amber_rounded,
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      onConfirm: () async {
        await LoadingDialog.show(message: 'جاري الحذف...');
        try {
          final res = await controller.deleteHoliday(holidayId);
          LoadingDialog.hide();
          if (res['ok'] == true) {
            await showStatusDialog(
              title: 'تم الحذف',
              message: 'تم حذف العطلة بنجاح',
              color: AppColors.primary,
              icon: Icons.check_circle_outline,
            );
          } else {
            await showStatusDialog(
              title: 'فشل الحذف',
              message: res['data']?['message']?.toString() ?? 'تعذر حذف العطلة',
              color: const Color(0xFFFF3B30),
              icon: Icons.error_outline,
            );
          }
        } catch (e) {
          LoadingDialog.hide();
          await showStatusDialog(
            title: 'خطأ',
            message: 'حدث خطأ أثناء حذف العطلة',
            color: const Color(0xFFFF3B30),
            icon: Icons.error_outline,
          );
        }
      },
    );
  }
}
