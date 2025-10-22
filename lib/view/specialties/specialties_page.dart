import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/specialization_text.dart';
import '../home/doctors/doctor_profile_page.dart';
import '../../bindings/doctor_profile_binding.dart';
import '../../service_layer/services/specialization_service.dart';
import '../../model/specialization_model.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SpecialtiesPage extends StatefulWidget {
  const SpecialtiesPage({Key? key}) : super(key: key);

  @override
  State<SpecialtiesPage> createState() => _SpecialtiesPageState();
}

class _SpecialtiesPageState extends State<SpecialtiesPage> {
  final SpecializationService _specializationService = SpecializationService();
  List<SpecializationModel> _specializations = [];
  List<Map<String, dynamic>> _doctors = [];
  String? _selectedSpecializationId;
  bool _isLoadingSpecializations = false;
  bool _isLoadingDoctors = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSpecializations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSpecializations() async {
    setState(() => _isLoadingSpecializations = true);
    try {
      final specializations = await _specializationService
          .getSpecializationsList();
      setState(() {
        _specializations = specializations;
        _isLoadingSpecializations = false;
        // اختر أول اختصاص تلقائياً
        if (specializations.isNotEmpty) {
          _selectedSpecializationId = specializations.first.id;
          _fetchDoctorsBySpecialization(_selectedSpecializationId!);
        }
      });
    } catch (_) {
      setState(() => _isLoadingSpecializations = false);
    }
  }

  Future<void> _fetchDoctorsBySpecialization(String specializationId) async {
    setState(() => _isLoadingDoctors = true);
    try {
      final response = await _specializationService.getDoctorsBySpecialization(
        specializationId: specializationId,
        search: _searchController.text.trim(),
      );
      if (response['ok'] == true || response['status'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final List<dynamic> doctors = (data['doctors'] as List<dynamic>?) ?? [];
        setState(() {
          _doctors = doctors.map((doc) => doc as Map<String, dynamic>).toList();
          _isLoadingDoctors = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingDoctors = false);
    }
  }

  void _onSpecializationSelected(String specializationId) {
    if (_selectedSpecializationId != specializationId) {
      setState(() => _selectedSpecializationId = specializationId);
      _fetchDoctorsBySpecialization(specializationId);
    }
  }

  void _onSearchChanged(String value) {
    if (_selectedSpecializationId != null) {
      _fetchDoctorsBySpecialization(_selectedSpecializationId!);
    }
  }

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
          controller: _searchController,
          onChanged: _onSearchChanged,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن طبيب...',
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
    if (_isLoadingDoctors) {
      return Skeletonizer(
        enabled: true,
        child: ListView.separated(
          itemCount: 3,
          separatorBuilder: (context, index) => SizedBox(height: 15.h),
          itemBuilder: (context, index) {
            return Container(
              height: 110.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(25.r),
              ),
            );
          },
        ),
      );
    }

    if (_doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64.r,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            MyText(
              'لا توجد أطباء في هذا الاختصاص',
              fontSize: 16.sp,
              color: Colors.grey[600],
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _doctors.length,
      separatorBuilder: (context, index) => SizedBox(height: 15.h),
      itemBuilder: (context, index) {
        return _buildDoctorCard(_doctors[index]);
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final String doctorId = doctor['_id']?.toString() ?? '';
    final String name = doctor['name']?.toString() ?? 'طبيب';
    final String specialization = doctor['specialization']?.toString() ?? '';
    final String image = doctor['image']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        Get.to(
          () => DoctorProfilePage(
            doctorId: doctorId,
            doctorName: name,
            specializationId: specialization,
          ),
          binding: DoctorProfileBinding(),
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
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDoctorPlaceholder();
                        },
                      )
                    : _buildDoctorPlaceholder(),
              ),
            ),

            // Doctor info section
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(
                      name,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5.h),
                    SpecializationText(
                      specializationId: specialization.isEmpty
                          ? null
                          : specialization,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7FC8D6),
                      textAlign: TextAlign.start,
                      defaultText: '—',
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

  Widget _buildDoctorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.person, size: 50.r, color: Colors.grey[400])],
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
            if (_isLoadingSpecializations)
              Expanded(
                child: Skeletonizer(
                  enabled: true,
                  child: ListView.separated(
                    itemCount: 5,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 20.h),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Column(
                          children: [
                            Container(
                              width: 50.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Container(
                              height: 12.h,
                              width: 40.w,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _specializations.length,
                  separatorBuilder: (context, index) => SizedBox(height: 20.h),
                  itemBuilder: (context, index) {
                    return _buildSidebarSpecialtyItem(_specializations[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarSpecialtyItem(SpecializationModel specialty) {
    final bool isSelected = _selectedSpecializationId == specialty.id;
    return GestureDetector(
      onTap: () => _onSpecializationSelected(specialty.id),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          children: [
            // Icon container
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFB800)
                    : const Color(0xFF7FC8D6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15.r),
                border: isSelected
                    ? Border.all(color: const Color(0xFFFFB800), width: 2)
                    : null,
              ),
              child: Icon(
                Icons.medical_services,
                color: isSelected ? Colors.white : const Color(0xFF7FC8D6),
                size: 20.r,
              ),
            ),

            SizedBox(height: 5.h),

            // Label text
            MyText(
              specialty.name,
              fontSize: 10.sp,
              color: isSelected ? const Color(0xFFFFB800) : Colors.grey[600],
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
