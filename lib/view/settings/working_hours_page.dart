import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/working_hours_controller.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/loading_dialog.dart';
import '../../widget/status_dialog.dart';
import '../../widget/confirm_dialogs.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../widget/back_button_widget.dart';

class WorkingHoursPage extends StatelessWidget {
  WorkingHoursPage({super.key});

  final WorkingHoursController controller = Get.put(WorkingHoursController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  SizedBox(width: 48.w),
                  Expanded(
                    child: Center(
                      child: MyText(
                        'إدارة أوقات العمل',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const BackButtonWidget(),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Skeletonizer(
                      enabled: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInfoCard(),
                          SizedBox(height: 16.h),
                          ...List.generate(
                            4,
                            (i) => Container(
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
                                leading: CircleAvatar(
                                  radius: 20.r,
                                  backgroundColor: Colors.grey[200],
                                ),
                                title: MyText(
                                  ' ',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                                subtitle: MyText(
                                  ' ',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                                trailing: Switch(
                                  value: true,
                                  onChanged: (_) {},
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.delete_outline),
                                  label: MyText('حذف الكل', fontSize: 16.sp),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.save,
                                    color: Colors.white,
                                  ),
                                  label: MyText(
                                    'حفظ',
                                    fontSize: 16.sp,
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

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // معلومات توضيحية
                      _buildInfoCard(),
                      SizedBox(height: 16.h),

                      // قائمة الأيام
                      ...List.generate(7, (index) => _buildDayCard(index)),

                      SizedBox(height: 20.h),

                      // أزرار الحفظ والحذف
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _onDeleteAll,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFFF3B30),
                                ),
                                foregroundColor: const Color(0xFFFF3B30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                              ),
                              icon: const Icon(Icons.delete_outline),
                              label: MyText(
                                'حذف الكل',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFF3B30),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _onSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: MyText(
                                'حفظ',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
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
              'حدد أوقات عملك لكل يوم من أيام الأسبوع',
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

  Widget _buildDayCard(int dayIndex) {
    return Obx(() {
      final day = controller.workingHours[dayIndex];
      final isWorking = day['isWorking'] as bool;

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
        child: Theme(
          data: ThemeData(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            leading: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isWorking
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWorking ? Icons.check_circle : Icons.cancel,
                color: isWorking ? AppColors.primary : Colors.grey[400],
                size: 24.sp,
              ),
            ),
            title: MyText(
              day['dayName'],
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              textAlign: TextAlign.right,
            ),
            subtitle: MyText(
              isWorking ? '${day['startTime']} - ${day['endTime']}' : 'عطلة',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              textAlign: TextAlign.right,
            ),
            trailing: Switch(
              value: isWorking,
              onChanged: (value) {
                controller.toggleDayWorking(dayIndex);
              },
              activeColor: AppColors.primary,
            ),
            children: isWorking
                ? [
                    _buildTimeRow(
                      label: 'من',
                      value: day['startTime'],
                      onTap: () => _selectTime(
                        dayIndex,
                        day['startTime'],
                        isStart: true,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildTimeRow(
                      label: 'إلى',
                      value: day['endTime'],
                      onTap: () =>
                          _selectTime(dayIndex, day['endTime'], isStart: false),
                    ),
                    SizedBox(height: 12.h),
                    _buildSlotDurationRow(dayIndex, day['slotDuration']),
                  ]
                : [],
          ),
        ),
      );
    });
  }

  Widget _buildTimeRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: MyText(
            label,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            textAlign: TextAlign.right,
          ),
        ),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  MyText(
                    value,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotDurationRow(int dayIndex, int duration) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: MyText(
            'مدة الفترة',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            textAlign: TextAlign.right,
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (duration > 15) {
                      controller.updateSlotDuration(dayIndex, duration - 15);
                    }
                  },
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: 12.w),
                MyText(
                  '$duration دقيقة',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 12.w),
                IconButton(
                  onPressed: () {
                    if (duration < 120) {
                      controller.updateSlotDuration(dayIndex, duration + 15);
                    }
                  },
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(
    int dayIndex,
    String currentTime, {
    required bool isStart,
  }) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isStart) {
        controller.updateStartTime(dayIndex, formattedTime);
      } else {
        controller.updateEndTime(dayIndex, formattedTime);
      }
    }
  }

  Future<void> _onSave() async {
    await LoadingDialog.show(message: 'جاري الحفظ...');
    try {
      final res = await controller.saveWorkingHours();
      LoadingDialog.hide();
      if (res['ok'] == true) {
        await showStatusDialog(
          title: 'تم الحفظ',
          message: 'تم حفظ أوقات العمل بنجاح',
          color: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      } else {
        await showStatusDialog(
          title: 'فشل الحفظ',
          message:
              res['data']?['message']?.toString() ?? 'تعذر حفظ أوقات العمل',
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      LoadingDialog.hide();
      await showStatusDialog(
        title: 'خطأ',
        message: 'حدث خطأ أثناء حفظ أوقات العمل',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _onDeleteAll() async {
    await showActionConfirmDialog(
      title: 'حذف جميع أوقات العمل',
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
            text: 'سيتم حذف جميع أوقات العمل',
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
          final res = await controller.deleteAllWorkingHours();
          LoadingDialog.hide();
          if (res['ok'] == true) {
            await showStatusDialog(
              title: 'تم الحذف',
              message: 'تم حذف جميع أوقات العمل بنجاح',
              color: AppColors.primary,
              icon: Icons.check_circle_outline,
            );
          } else {
            await showStatusDialog(
              title: 'فشل الحذف',
              message:
                  res['data']?['message']?.toString() ?? 'تعذر حذف أوقات العمل',
              color: const Color(0xFFFF3B30),
              icon: Icons.error_outline,
            );
          }
        } catch (e) {
          LoadingDialog.hide();
          await showStatusDialog(
            title: 'خطأ',
            message: 'حدث خطأ أثناء حذف أوقات العمل',
            color: const Color(0xFFFF3B30),
            icon: Icons.error_outline,
          );
        }
      },
    );
  }
}
