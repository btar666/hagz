import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/back_button_widget.dart';
import '../../service_layer/services/visits_service.dart';
import '../../controller/delegate_doctors_visits_controller.dart';
import '../../controller/delegate_all_visits_controller.dart';
import 'repeat_visit_page.dart';
import 'edit_visit_page.dart';
import 'package:get/get.dart';

class VisitDetailsPage extends StatefulWidget {
  const VisitDetailsPage({super.key});

  @override
  State<VisitDetailsPage> createState() => _VisitDetailsPageState();
}

class _VisitDetailsPageState extends State<VisitDetailsPage> {
  late Map<String, dynamic> visitData;

  @override
  void initState() {
    super.initState();
    visitData = (Get.arguments ?? {}) as Map<String, dynamic>;
  }

  Future<void> _reloadVisitData() async {
    try {
      // تحديث البيانات من ال API
      final visitId = visitData['id'] as String?;
      if (visitId == null || visitId.isEmpty) return;

      final visitsService = VisitsService();
      final res = await visitsService.getVisits(limit: 100);

      if (res['ok'] == true) {
        final responseData = res['data'];
        List<dynamic> dataList = [];

        if (responseData != null) {
          if (responseData['data'] != null && responseData['data'] is List) {
            dataList = responseData['data'];
          } else if (responseData is List) {
            dataList = responseData;
          }
        }

        // ابحث عن الزيارة بالمعرف المطلوبة
        final updatedVisit = dataList.firstWhere(
          (item) => item['_id'].toString() == visitId,
          orElse: () => null,
        );

        if (updatedVisit != null) {
          setState(() {
            visitData = {
              'id': updatedVisit['_id']?.toString() ?? '',
              'title': updatedVisit['doctorName']?.toString() ?? '',
              'subtitle': updatedVisit['doctorSpecialization']?.toString() ?? '',
              'isSubscribed': updatedVisit['visitStatus']?.toString() == 'مشترك',
              'visits': updatedVisit['visitCount'] as int? ?? 0,
              'reason': updatedVisit['nonSubscriptionReason']?.toString(),
              'address': updatedVisit['doctorAddress']?.toString() ?? '',
              'phone': updatedVisit['doctorPhone']?.toString() ?? '',
              'governorate': updatedVisit['governorate']?.toString() ?? '',
              'district': updatedVisit['district']?.toString() ?? '',
              'notes': updatedVisit['notes']?.toString() ?? '',
              'coordinates': updatedVisit['coordinates'] as Map<String, dynamic>? ?? {},
            };
          });
        }
      }
    } catch (e) {
      print('❌ Error reloading visit data: $e');
    }
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 48.sp,
              ),
              SizedBox(height: 12.h),
              MyText(
                'تأكيد الحذف',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              MyText(
                'هل أنت متأكد من حذف هذه الزيارة؟ لا يمكن استرجاع ها.',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: MyText(
                        'إلغاء',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deleteVisit(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: MyText(
                        'حذف',
                        fontSize: 14.sp,
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
      ),
    );
  }

  Future<void> _deleteVisit() async {
    try {
      Get.back(); // إغلاق ديالوغ التأكيد

      final visitId = visitData['id'] as String?;
      if (visitId == null || visitId.isEmpty) {
        Get.snackbar('خطأ', 'لم يتم تحديث معرف الزيارة');
        return;
      }

      final visitsService = VisitsService();
      final res = await visitsService.deleteVisit(visitId);

      if (res['ok'] == true) {
        // تحديث القوائم
        try {
          final doctorsCtrl = Get.find<DelegateDoctorsVisitsController>();
          await doctorsCtrl.refresh();
        } catch (_) {}
        try {
          final allCtrl = Get.find<DelegateAllVisitsController>();
          await allCtrl.refresh();
        } catch (_) {}

        Get.back(); // الخروج من صفحة التفاصيل
      } else {
        Get.snackbar(
          'خطأ',
          res['message']?.toString() ?? 'فشل حذف الزيارة',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف الزيارة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = (visitData['title'] ?? '') as String;
    final String subtitle = (visitData['subtitle'] ?? '') as String;
    final bool isSubscribed = (visitData['isSubscribed'] ?? false) as bool;
    final int visits = (visitData['visits'] ?? 0) as int;
    final String? reason = visitData['reason'] as String?;
    final String address = (visitData['address'] ?? '') as String;
    final String phone = (visitData['phone'] ?? '') as String;
    final String governorate = (visitData['governorate'] ?? '') as String;
    final String district = (visitData['district'] ?? '') as String;
    final String notes = (visitData['notes'] ?? '') as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Expanded(
                    child: MyText(
                      'تفاصيل الزيارة',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const BackButtonWidget(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Content
                    // Header Card
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyText(
                            title,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          MyText(
                            subtitle,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Status Section
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
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
                          Center(
                            child: MyText(
                              'الحالة والعدد',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _detailRow(
                            'حالة الاشتراك',
                            isSubscribed ? 'مشترك' : 'غير مشترك',
                            isSubscribed ? const Color(0xFF2ECC71) : const Color(0xFFFF3B30),
                          ),
                          SizedBox(height: 12.h),
                          _detailRow('عدد الزيارات', visits.toString(), AppColors.primary),
                          if (!isSubscribed &&
                              (reason != null && reason.isNotEmpty)) ...[
                            SizedBox(height: 12.h),
                            _detailRow('سبب عدم الاشتراك', reason, const Color(0xFFFF3B30)),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Contact Section
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
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
                          Center(
                            child: MyText(
                              'بيانات الاتصال',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          if (phone.isNotEmpty)
                            _detailRowWithIcon('رقم الهاتف', phone, Icons.phone, AppColors.primary),
                          if (phone.isEmpty)
                            _detailRow('رقم الهاتف', 'غير متوفر', AppColors.textLight),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Address Section
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
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
                          Center(
                            child: MyText(
                              'العنوان',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          if (address.isNotEmpty)
                            _detailRowWithIcon('العنوان التفصيلي', address, Icons.location_on, AppColors.primary),
                          if (address.isEmpty)
                            _detailRow('العنوان التفصيلي', 'غير متوفر', AppColors.textLight),
                          if (governorate.isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            _detailRow('المحافظة', governorate, AppColors.textPrimary),
                          ],
                          if (district.isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            _detailRow('المنطقة', district, AppColors.textSecondary),
                          ],
                        ],
                      ),
                    ),

                    if (notes.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFFFFD54F),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MyText(
                              'الملاحظات',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFF57F17),
                              textAlign: TextAlign.right,
                            ),
                            SizedBox(height: 8.h),
                            MyText(
                              notes,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 24.h),

                    // Buttons
                    Column(
                      children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Get.to(() => const EditVisitPage(), arguments: {
                          ...visitData,
                          'coordinates': {
                            'latitude': visitData['coordinates']?['latitude'] ?? Get.arguments?['coordinates']?['latitude'] ?? 0.0,
                            'longitude': visitData['coordinates']?['longitude'] ?? Get.arguments?['coordinates']?['longitude'] ?? 0.0,
                          }
                        });
                        if (result == 'updated') {
                          // إعادة تحميل بيانات الزيارة
                          await _reloadVisitData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade500,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: MyText(
                        'تعديل الزيارة',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => const RepeatVisitPage(), arguments: visitData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: MyText(
                        'تكرار الزيارة',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showDeleteConfirmation(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: MyText(
                        'حذف الزيارة',
                        fontSize: 16.sp,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText(
          '$label :',
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          textAlign: TextAlign.left,
        ),
        MyText(
          value,
          fontSize: 16.sp,
          fontWeight: FontWeight.w900,
          color: valueColor,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _detailRowWithIcon(String label, String value, IconData icon, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: MyText(
            '$label :',
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: MyText(
                  value,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  // TODO: Add functionality for phone/location
                },
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
