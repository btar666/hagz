import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../widget/search_widget.dart';

class SpecialtiesPage extends StatelessWidget {
  const SpecialtiesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الاختصاصات',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Search bar
            const SearchWidget(hint: 'ابحث عن اختصاص...'),
            SizedBox(height: 20.h),
            
            // Specialties grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.1,
                ),
                itemCount: _specialties.length,
                itemBuilder: (context, index) {
                  return _buildSpecialtyCard(_specialties[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard(SpecialtyItem specialty) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'اختيار الاختصاص',
          'سيتم عرض أطباء ${specialty.name}',
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
          // Specialty icon
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: specialty.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              specialty.icon,
              color: specialty.color,
              size: 30.sp,
            ),
          ),
          SizedBox(height: 12.h),
          // Specialty name
          Text(
            specialty.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          // Specialty type
          Text(
            specialty.type,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    ),
    );
  }

  static final List<SpecialtyItem> _specialties = [
    SpecialtyItem(
      name: 'طب الأعصاب',
      type: 'طب الشبكية',
      icon: Icons.psychology,
      color: AppColors.neurology,
    ),
    SpecialtyItem(
      name: 'طب الأسنان',
      type: 'طب الشبكية',
      icon: Icons.medical_services,
      color: AppColors.secondary,
    ),
    SpecialtyItem(
      name: 'الطب العام',
      type: 'طب الشبكية',
      icon: Icons.local_hospital,
      color: AppColors.generalMedicine,
    ),
    SpecialtyItem(
      name: 'طب العيون',
      type: 'طب الشبكية',
      icon: Icons.remove_red_eye,
      color: AppColors.ophthalmology,
    ),
    SpecialtyItem(
      name: 'طب الأطفال',
      type: 'طب الشبكية',
      icon: Icons.child_care,
      color: AppColors.pediatrics,
    ),
    SpecialtyItem(
      name: 'المفاصل',
      type: 'طب الشبكية',
      icon: Icons.accessible,
      color: AppColors.orthopedics,
    ),
    SpecialtyItem(
      name: 'العلاج الطبيعي',
      type: 'العلاج الطبيعي',
      icon: Icons.healing,
      color: AppColors.dermatology,
    ),
  ];
}

class SpecialtyItem {
  final String name;
  final String type;
  final IconData icon;
  final Color color;

  SpecialtyItem({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });
}
