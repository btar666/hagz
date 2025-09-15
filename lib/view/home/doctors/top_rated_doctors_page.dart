import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../widget/my_text.dart';
import '../../../widget/specialty_text.dart';
import 'doctor_profile_page.dart';

class TopRatedDoctorsPage extends StatelessWidget {
  const TopRatedDoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> doctorNames = [
      'آرين',
      'مالوون',
      'نهاد',
      'أيكورت',
      'د. أحمد',
      'د. فاطمة',
      'د. خالد',
      'د. مريم',
      'د. محمد',
      'د. سارة',
    ];

    final List<String> specialties = [
      'جراحة الفم',
      'جراحة العيون',
      'جراحة الفم',
      'جراحة الفم',
      'طب الأسنان',
      'طب الأطفال',
      'جراحة العظام',
      'طب الجلدية',
      'طب القلب',
      'طب النساء',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8.w),
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: const Icon(Icons.tune, color: Colors.white, size: 20),
        ),
        title: MyText(
          'الأطباء الأعلى تقييماً',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: EdgeInsets.all(8.w),
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio:
                178 / 247, // نفس نسبة كاردات الأطباء في الصفحة الرئيسية
          ),
          itemCount: doctorNames.length,
          itemBuilder: (context, index) {
            return _buildDoctorCard(index, doctorNames, specialties);
          },
        ),
      ),
    );
  }

  Widget _buildDoctorCard(
    int index,
    List<String> doctorNames,
    List<String> specialties,
  ) {
    return GestureDetector(
      onTap: () {
        // الانتقال إلى صفحة تفاصيل الطبيب
        Get.to(
          () => DoctorProfilePage(
            doctorName: doctorNames[index],
            specialization: specialties[index],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
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
            // Doctor image with rounded rectangle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: AspectRatio(
                aspectRatio: 1.0, // Perfect square
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.asset(
                      'assets/icons/home/doctor.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Doctor name
            MyText(
              doctorNames[index],
              fontSize: 15.sp,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            // Specialty
            SpecialtyText(
              specialties[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
