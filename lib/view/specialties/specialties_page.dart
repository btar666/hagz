import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widget/my_text.dart';
import '../../widget/specialization_text.dart';
import '../home/doctors/doctor_profile_page.dart';
import '../../bindings/doctor_profile_binding.dart';
import '../../service_layer/services/specialization_service.dart';
import '../../model/specialization_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../controller/locale_controller.dart';
import '../../utils/app_colors.dart';

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
  String? _selectedSpecializationName;
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
      print('🔍 Fetching doctors for specialization: $specializationId');
      final response = await _specializationService.getDoctorsBySpecialization(
        specializationId: specializationId,
        search: _searchController.text.trim(),
      );

      print('📥 Response received: $response');

      if (response['ok'] == true) {
        final responseData = response['data'];
        print('📦 Response data: $responseData');

        if (responseData is Map<String, dynamic>) {
          // Check if data has nested structure with 'data' key
          final dataMap = responseData['data'] is Map<String, dynamic>
              ? responseData['data'] as Map<String, dynamic>
              : responseData;

          // Extract specialization info
          final specializationInfo =
              dataMap['specialization'] as Map<String, dynamic>?;
          String? specId;
          if (specializationInfo != null) {
            _selectedSpecializationName = specializationInfo['name']
                ?.toString();
            specId = specializationInfo['id']?.toString();
            print(
              '🏥 Specialization: $_selectedSpecializationName (ID: $specId)',
            );
          }

          final List<dynamic> doctors =
              (dataMap['doctors'] as List<dynamic>?) ?? [];
          print('👨‍⚕️ Found ${doctors.length} doctors');

          // Add specialization ID to each doctor
          final doctorsWithSpecialization = doctors.map((doc) {
            final doctorMap = Map<String, dynamic>.from(
              doc as Map<String, dynamic>,
            );
            // Add specialization ID if not present
            if (!doctorMap.containsKey('specialization') && specId != null) {
              doctorMap['specialization'] = specId;
              print(
                '➕ Added specialization $specId to doctor ${doctorMap['name']}',
              );
            }
            return doctorMap;
          }).toList();

          setState(() {
            _doctors = doctorsWithSpecialization;
            _isLoadingDoctors = false;
          });
        } else {
          print('⚠️ Unexpected data format');
          setState(() {
            _doctors = [];
            _isLoadingDoctors = false;
          });
        }
      } else {
        print('❌ Request failed: ${response['message']}');
        setState(() {
          _doctors = [];
          _isLoadingDoctors = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching doctors: $e');
      setState(() {
        _doctors = [];
        _isLoadingDoctors = false;
      });
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Specialties sidebar
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: _buildSpecialtiesSidebar(),
                      ),

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
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.h),
          child: Center(
            child: MyText(
              'specialties'.tr,
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
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
              key: ValueKey(
                'search_${localeController.selectedLanguage.value}',
              ),
              controller: _searchController,
              onChanged: _onSearchChanged,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'search_doctor'.tr,
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
      },
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
            GetBuilder<LocaleController>(
              builder: (localeController) {
                return MyText(
                  'no_doctors_in_specialty'.tr,
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  textAlign: TextAlign.center,
                );
              },
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
    final String name = doctor['name']?.toString() ?? 'doctor_default'.tr;
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
        padding: EdgeInsets.only(top: 20.h, bottom: 30.h),
        child: Column(
          children: [
            if (_isLoadingSpecializations)
              Expanded(
                child: Skeletonizer(
                  enabled: true,
                  child: ListView.separated(
                    padding: EdgeInsets.only(bottom: 30.h),
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
                  padding: EdgeInsets.only(bottom: 30.h),
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

  IconData _getSpecializationIcon(String specializationName) {
    final name = specializationName.toLowerCase();
    if (name.contains('عيون') || name.contains('eye')) {
      return Icons.remove_red_eye;
    } else if (name.contains('قلب') ||
        name.contains('cardio') ||
        name.contains('heart')) {
      return Icons.favorite;
    } else if (name.contains('أسنان') ||
        name.contains('dental') ||
        name.contains('tooth')) {
      return Icons.local_hospital;
    } else if (name.contains('أطفال') ||
        name.contains('pediatric') ||
        name.contains('child')) {
      return Icons.child_care;
    } else if (name.contains('نساء') ||
        name.contains('ولادة') ||
        name.contains('gynec') ||
        name.contains('obstet')) {
      return Icons.pregnant_woman;
    } else if (name.contains('جلد') ||
        name.contains('dermat') ||
        name.contains('skin')) {
      return Icons.face;
    } else if (name.contains('عظام') ||
        name.contains('ortho') ||
        name.contains('bone')) {
      return Icons.healing;
    } else if (name.contains('أذن') ||
        name.contains('أنف') ||
        name.contains('حنجرة') ||
        name.contains('ent') ||
        name.contains('ear') ||
        name.contains('nose')) {
      return Icons.hearing;
    } else if (name.contains('جراحة') ||
        name.contains('surgery') ||
        name.contains('surgical')) {
      return Icons.medical_services;
    } else if (name.contains('باطنية') ||
        name.contains('باطنة') ||
        name.contains('internal') ||
        name.contains('digestive')) {
      return Icons.medical_information;
    } else if (name.contains('أعصاب') ||
        name.contains('neuro') ||
        name.contains('nerve')) {
      return Icons.psychology;
    } else if (name.contains('نفسي') ||
        name.contains('psych') ||
        name.contains('mental')) {
      return Icons.psychology;
    } else if (name.contains('أورام') ||
        name.contains('oncology') ||
        name.contains('cancer')) {
      return Icons.coronavirus;
    } else if (name.contains('مسالك') ||
        name.contains('urology') ||
        name.contains('urinary')) {
      return Icons.water_drop;
    } else if (name.contains('أشعة') ||
        name.contains('radiology') ||
        name.contains('radiology') ||
        name.contains('x-ray') ||
        name.contains('imaging')) {
      return Icons.scanner;
    } else if (name.contains('تخدير') ||
        name.contains('anesthesia') ||
        name.contains('anesthesiology')) {
      return Icons.medication;
    } else if (name.contains('طوارئ') ||
        name.contains('emergency') ||
        name.contains('er')) {
      return Icons.local_hospital;
    } else if (name.contains('أنف') || name.contains('nose')) {
      return Icons.air;
    } else {
      return Icons.medical_services;
    }
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
                _getSpecializationIcon(specialty.name),
                color: isSelected ? Colors.white : const Color(0xFF7FC8D6),
                size: 28.r,
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
