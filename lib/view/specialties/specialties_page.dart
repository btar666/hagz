import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../home/doctors/doctor_profile_page.dart';

class SpecialtiesPage extends StatelessWidget {
  const SpecialtiesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FEFF),
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
                      // Specialties sidebar
                      _buildSpecialtiesSidebar(),

                      SizedBox(width: 15.w),

                      // Doctors list
                      Expanded(child: _buildDoctorsList()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 50.h, bottom: 30.h),
      child: Center(
        child: MyText(
          'الاختصاصات',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: const Color(0xFF7FC8D6).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن اختصاص...',
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              padding: EdgeInsets.all(12.r),
              child: Icon(
                Icons.search,
                color: const Color(0xFF7FC8D6),
                size: 26.r,
              ),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 25.w,
              vertical: 18.h,
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
    return GestureDetector(
      onTap: () {
        Get.to(
          () => DoctorProfilePage(
            doctorName: doctor.name,
            specialization: doctor.specialty,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Doctor image section
            Container(
              width: 99.w,
              height: 90.h,
              margin: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.asset(
                  doctor.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            size: 50.r,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 5.h),
                          MyText(
                            'صورة الطبيب',
                            fontSize: 10.sp,
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Doctor info section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(25.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(
                      doctor.name,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3748),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 8.h),
                    MyText(
                      doctor.specialty,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF718096),
                      textAlign: TextAlign.left,
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
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          children: [
            // Icon container
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: specialty.isSelected
                    ? const Color(0xFFFFB800)
                    : specialty.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15.r),
                border: specialty.isSelected
                    ? Border.all(color: const Color(0xFFFFB800), width: 2)
                    : null,
              ),
              child: Icon(
                specialty.icon,
                color: specialty.isSelected ? Colors.white : specialty.color,
                size: 20.r,
              ),
            ),

            SizedBox(height: 5.h),

            // Label text
            MyText(
              specialty.label,
              fontSize: 10.sp,
              color: specialty.isSelected
                  ? const Color(0xFFFFB800)
                  : Colors.grey[600],
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
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
      label: 'طب الأعصاب',
      name: 'طب الأعصاب',
    ),
    SidebarSpecialtyItem(
      icon: Icons.medical_services,
      color: const Color(0xFFFFB800),
      label: 'طب الأسنان',
      name: 'طب الأسنان',
    ),
    SidebarSpecialtyItem(
      icon: Icons.local_hospital,
      color: const Color(0xFFFFB800),
      label: 'الطب العام',
      name: 'الطب العام',
    ),
    SidebarSpecialtyItem(
      icon: Icons.remove_red_eye,
      color: const Color(0xFFFFB800),
      label: 'طب العيون',
      name: 'طب العيون',
      isSelected: true,
    ),
    SidebarSpecialtyItem(
      icon: Icons.child_care,
      color: const Color(0xFFFFB800),
      label: 'طب الأطفال',
      name: 'طب الأطفال',
    ),
    SidebarSpecialtyItem(
      icon: Icons.accessible,
      color: const Color(0xFFFFB800),
      label: 'المفاصل',
      name: 'المفاصل',
    ),
    SidebarSpecialtyItem(
      icon: Icons.healing,
      color: const Color(0xFFFFB800),
      label: 'العلاج الطبيعي',
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
