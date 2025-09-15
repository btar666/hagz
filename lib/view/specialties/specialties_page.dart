import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';

class SpecialtiesPage extends StatelessWidget {
  const SpecialtiesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search bar
            _buildSearchBar(),

            SizedBox(height: 20.h),

            // Main content with doctors list and specialties sidebar
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    // Doctors list
                    Expanded(child: _buildDoctorsList()),

                    SizedBox(width: 15.w),

                    // Specialties sidebar
                    _buildSpecialtiesSidebar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              // Empty space to balance the back button
              SizedBox(width: 50.w),
              const Spacer(),

              // Title
              MyText(
                'الاختصاصات',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                textAlign: TextAlign.center,
              ),

              const Spacer(),
              // Back button
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7FC8D6),
                    borderRadius: BorderRadius.circular(15.r),
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
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Container(
        height: 55.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن اختصاص...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            prefixIcon: Icon(
              Icons.search,
              color: const Color(0xFF7FC8D6),
              size: 24.r,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 15.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsList() {
    return ListView.separated(
      itemCount: _doctors.length,
      separatorBuilder: (context, index) => SizedBox(height: 15.h),
      itemBuilder: (context, index) {
        return _buildDoctorCard(_doctors[index]);
      },
    );
  }

  Widget _buildDoctorCard(DoctorItem doctor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            // Doctor info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MyText(
                    doctor.name,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 5.h),
                  MyText(
                    doctor.specialty,
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),

            SizedBox(width: 15.w),

            // Doctor image
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  doctor.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        size: 40.r,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtiesSidebar() {
    return Container(
      width: 80.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _sidebarSpecialties.length,
                separatorBuilder: (context, index) => SizedBox(height: 20.h),
                itemBuilder: (context, index) {
                  return _buildSidebarSpecialtyItem(_sidebarSpecialties[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarSpecialtyItem(SidebarSpecialtyItem specialty) {
    return GestureDetector(
      onTap: () {
        // Handle specialty selection
      },
      child: Container(
        width: 50.w,
        height: 50.w,
        margin: EdgeInsets.symmetric(horizontal: 15.w),
        decoration: BoxDecoration(
          color: specialty.isSelected
              ? const Color(0xFFFFB800)
              : specialty.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15.r),
          border: specialty.isSelected
              ? Border.all(color: const Color(0xFFFFB800), width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              specialty.icon,
              color: specialty.isSelected ? Colors.white : specialty.color,
              size: 20.r,
            ),
            if (specialty.label.isNotEmpty) ...[
              SizedBox(height: 2.h),
              MyText(
                specialty.label,
                fontSize: 8.sp,
                color: specialty.isSelected ? Colors.white : specialty.color,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Static data
  static final List<DoctorItem> _doctors = [
    DoctorItem(
      name: 'د. آرين',
      specialty: 'طب الشبكية',
      imagePath: 'assets/images/doctor1.jpg',
    ),
    DoctorItem(
      name: 'د. آرين',
      specialty: 'طب الشبكية',
      imagePath: 'assets/images/doctor2.jpg',
    ),
    DoctorItem(
      name: 'د. آرين',
      specialty: 'طب الشبكية',
      imagePath: 'assets/images/doctor3.jpg',
    ),
    DoctorItem(
      name: 'د. آرين',
      specialty: 'طب الشبكية',
      imagePath: 'assets/images/doctor4.jpg',
    ),
    DoctorItem(
      name: 'د. آرين',
      specialty: 'طب الشبكية',
      imagePath: 'assets/images/doctor5.jpg',
    ),
    DoctorItem(
      name: 'د. آرين',
      specialty: 'طب الشبكية',
      imagePath: 'assets/images/doctor6.jpg',
    ),
    DoctorItem(
      name: 'د. آرين',
      specialty: 'طب الشبكية',
      imagePath: 'assets/images/doctor7.jpg',
    ),
  ];

  static final List<SidebarSpecialtyItem> _sidebarSpecialties = [
    SidebarSpecialtyItem(
      icon: Icons.psychology,
      color: const Color(0xFFFFB800),
      label: '',
      name: 'طب الأعصاب',
    ),
    SidebarSpecialtyItem(
      icon: Icons.medical_services,
      color: const Color(0xFFFFB800),
      label: '',
      name: 'طب الأسنان',
    ),
    SidebarSpecialtyItem(
      icon: Icons.local_hospital,
      color: const Color(0xFFFFB800),
      label: '',
      name: 'الطب العام',
    ),
    SidebarSpecialtyItem(
      icon: Icons.remove_red_eye,
      color: const Color(0xFFFFB800),
      label: '',
      name: 'طب العيون',
      isSelected: true,
    ),
    SidebarSpecialtyItem(
      icon: Icons.child_care,
      color: const Color(0xFFFFB800),
      label: '',
      name: 'طب الأطفال',
    ),
    SidebarSpecialtyItem(
      icon: Icons.accessible,
      color: const Color(0xFFFFB800),
      label: '',
      name: 'المفاصل',
    ),
    SidebarSpecialtyItem(
      icon: Icons.healing,
      color: const Color(0xFFFFB800),
      label: '',
      name: 'العلاج الطبيعي',
    ),
  ];

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
              child: Icon(specialty.icon, color: specialty.color, size: 30.sp),
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
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
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

class DoctorItem {
  final String name;
  final String specialty;
  final String imagePath;

  DoctorItem({
    required this.name,
    required this.specialty,
    required this.imagePath,
  });
}

class SidebarSpecialtyItem {
  final IconData icon;
  final Color color;
  final String label;
  final String name;
  final bool isSelected;

  SidebarSpecialtyItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.name,
    this.isSelected = false,
  });
}
