import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/specialization_text.dart';
import '../../controller/search_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'hospital/hospital_details_page.dart';
import '../../bindings/hospital_details_binding.dart';
import 'doctors/doctor_profile_page.dart';
import '../../bindings/doctor_profile_binding.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchController c = Get.find<SearchController>();
    final args = Get.arguments as Map?;
    final String mode = (args != null
        ? (args['mode']?.toString() ?? 'all')
        : 'all');
    // تهيئة وضع البحث وفق المصدر: أطباء/مستشفيات/مجمعات
    c.initMode(mode);

    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FEFF),
        elevation: 0,
        title: MyText(
          'نتائج البحث',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: MyText(
            'الغاء',
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                onChanged: c.onQueryChanged,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن طبيب...',
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textLight,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerRight,
              child: MyText(
                'نتائج البحث',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                final items = c.results;

                // حالة التحميل الأولي - عرض Skeletonizer فقط
                if (c.isLoading.value && items.isEmpty) {
                  return Skeletonizer(
                    enabled: true,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 178 / 247,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return Container(
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
                              SizedBox(height: 8.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              MyText(
                                'جاري التحميل...',
                                fontSize: 15.sp,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                              SizedBox(height: 6.h),
                              MyText(
                                'جاري التحميل...',
                                fontSize: 12.45.sp,
                                color: AppColors.textSecondary,
                                textAlign: TextAlign.center,
                              ),
                              const Spacer(),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }

                // إذا لا توجد نتائج بعد البحث، أعرض رسالة واضحة
                if (!c.isLoading.value &&
                    items.isEmpty &&
                    c.query.value.isNotEmpty) {
                  return Center(
                    child: MyText(
                      'لا توجد نتائج مطابقة لبحثك',
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // عرض البيانات الحقيقية فقط
                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 100 &&
                        !c.isLoading.value) {
                      c.loadMore();
                    }
                    return false;
                  },
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 178 / 247,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final name = (item['name'] ?? '').toString();
                      final type = (item['type'] ?? '').toString();
                      final image = (item['image'] ?? '').toString();
                      final id = (item['_id'] ?? item['id'] ?? '').toString();
                      final isHospital = type == 'مستشفى' || type == 'مجمع طبي';

                      // Extract specialization ID
                      String specializationId = '';
                      final specData = item['specialization'];
                      if (specData != null) {
                        if (specData is String) {
                          specializationId = specData;
                        } else if (specData is Map) {
                          specializationId =
                              (specData['_id'] ?? specData['id'] ?? '')
                                  .toString();
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          if (isHospital) {
                            Get.to(
                              () => const HospitalDetailsPage(),
                              arguments: {'id': id},
                              binding: HospitalDetailsBinding(),
                            );
                          } else {
                            // Navigate to doctor profile page
                            Get.to(
                              () => DoctorProfilePage(
                                doctorId: id,
                                doctorName: name,
                                specializationId: specializationId.isEmpty
                                    ? '—'
                                    : specializationId,
                              ),
                              binding: DoctorProfileBinding(),
                            );
                          }
                        },
                        child: Container(
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
                              SizedBox(height: 8.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: image.isNotEmpty
                                          ? Image.network(
                                              image,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    // لا تستخدم صورة doctor.png أبداً
                                                    if (isHospital) {
                                                      return Image.asset(
                                                        'assets/icons/home/hospital.png',
                                                        fit: BoxFit.cover,
                                                      );
                                                    }
                                                    return Container(
                                                      color: Colors.white,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.person,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            )
                                          : (isHospital
                                                ? Image.asset(
                                                    'assets/icons/home/hospital.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    color: Colors.white,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  )),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              MyText(
                                name,
                                fontSize: 15.sp,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6.h),
                              isHospital
                                  ? MyText(
                                      type == 'مجمع طبي'
                                          ? 'مجمع طبي'
                                          : 'مستشفى',
                                      fontSize: 12.45.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                      textAlign: TextAlign.center,
                                    )
                                  : SpecializationText(
                                      specializationId: specializationId.isEmpty
                                          ? null
                                          : specializationId,
                                      fontSize: 12.45.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                      textAlign: TextAlign.center,
                                      defaultText: '—',
                                    ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
