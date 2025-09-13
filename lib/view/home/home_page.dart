import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/main_controller.dart';
import '../../utils/app_colors.dart';
import '../../widget/search_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Header with profile and chat
              _buildHeader(),
              SizedBox(height: 20.h),
              
              // Search bar
              const SearchWidget(hint: 'ابحث عن طبيب أو مستشفى...'),
              SizedBox(height: 20.h),
              
              // Banner/Image section
              _buildBanner(),
              SizedBox(height: 20.h),
              
              // Tab buttons (أطباء الأعلى تقييماً, الكل)
              _buildTabHeader(),
              SizedBox(height: 20.h),
              
              // Content tabs
              Expanded(
                child: Obx(() => IndexedStack(
                  index: controller.homeTabIndex.value,
                  children: [
                    _buildDoctorsTab(),
                    _buildHospitalsTab(),
                    _buildMedicalCentersTab(),
                  ],
                )),
              ),
              
              // Bottom tab selector
              _buildBottomTabs(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Profile avatar
        Container(
          width: 50.w,
          height: 50.w,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 30,
          ),
        ),
        const Spacer(),
        // Chat icon
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primary.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'الأطباء الأعلى تقييماً',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            // Dots indicator
            Row(
              children: List.generate(
                4,
                (index) => Container(
                  margin: EdgeInsets.only(right: 8.w),
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == 3 ? AppColors.textPrimary : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabHeader() {
    return Row(
      children: [
        Icon(
          Icons.tune,
          color: AppColors.textSecondary,
          size: 24.sp,
        ),
        const Spacer(),
        Text(
          'الكل',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorsTab() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.8,
      ),
      itemCount: 6, // Sample count
      itemBuilder: (context, index) {
        return _buildDoctorCard(index);
      },
    );
  }

  Widget _buildHospitalsTab() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.9,
      ),
      itemCount: 4, // Sample count
      itemBuilder: (context, index) {
        return _buildHospitalCard();
      },
    );
  }

  Widget _buildMedicalCentersTab() {
    return const Center(
      child: Text(
        'لا توجد مجمعات',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDoctorCard(int index) {
    final List<String> doctorNames = [
      'د. آرين',
      'د. صوفيا',
      'د. سونجوز',
      'د. آرين',
      'د. مالوون',
      'د. آرين',
    ];

    final List<String> specialties = [
      'جراحة القلب',
      'جراحة القلب',
      'جراحة القلب',
      'جراحة القلب',
      'جراحة العيون',
      'جراحة القلب',
    ];

    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'تفاصيل الطبيب',
          'سيتم فتح صفحة تفاصيل ${doctorNames[index % doctorNames.length]}',
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
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
          SizedBox(height: 16.h),
          // Doctor image
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          SizedBox(height: 12.h),
          // Doctor name
          Text(
            doctorNames[index % doctorNames.length],
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          // Specialty
          Text(
            specialties[index % specialties.length],
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          const Spacer(),
        ],
      ),
    ),
    );
  }

  Widget _buildHospitalCard() {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'تفاصيل المستشفى',
          'سيتم فتح صفحة تفاصيل مستشفى روما',
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hospital logo
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(
              Icons.local_hospital,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          SizedBox(height: 12.h),
          // Hospital name
          Text(
            'مستشفى روما',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildBottomTabs(MainController controller) {
    final List<String> tabLabels = ['أطباء', 'مستشفيات', 'مجمعات'];
    
    return Obx(() => Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = controller.homeTabIndex.value == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeHomeTab(index),
              child: Container(
                height: 50.h,
                decoration: isSelected
                    ? BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(25.r),
                      )
                    : null,
                child: Center(
                  child: Text(
                    tabLabels[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontSize: 16.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ));
  }
}
