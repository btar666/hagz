import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../widget/my_text.dart';
import '../../../widget/specialty_text.dart';
import '../../../widget/doctors_filter_dialog.dart';
import 'doctor_profile_page.dart';
import '../../../bindings/doctor_profile_binding.dart';

import '../../../service_layer/services/ratings_service.dart';

class TopRatedDoctorsPage extends StatefulWidget {
  const TopRatedDoctorsPage({super.key});

  @override
  State<TopRatedDoctorsPage> createState() => _TopRatedDoctorsPageState();
}

class _TopRatedDoctorsPageState extends State<TopRatedDoctorsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadTopDoctors();
  }

  Future<void> _loadTopDoctors() async {
    setState(() => _isLoading = true);
    try {
      final service = RatingsService();
      final res = await service.getTopDoctors(page: 1, limit: 20);
      if (res['ok'] == true) {
        final data = res['data'];
        final list = (data is Map && data['data'] is List) ? data['data'] as List : (data as List? ?? []);
        _items = list.map<Map<String, dynamic>>((e) {
          final m = e as Map<String, dynamic>;
          return {
            'doctorId': m['_id']?.toString() ?? '',
            'name': m['name']?.toString() ?? '',
            'specialty': m['specialization']?.toString() ?? '',
            'avg': (m['averageRating'] is num) ? (m['averageRating'] as num).toDouble() : 0.0,
            'count': (m['totalRatings'] is num) ? (m['totalRatings'] as num).toInt() : 0,
          };
        }).toList();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FEFF),
        elevation: 0,
        leading: GestureDetector(
          onTap: () async {
            await Get.dialog(const DoctorsFilterDialog());
          },
          child: Container(
            margin: EdgeInsets.all(8.w),
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 178 / 247,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildDoctorCard(_items[index]);
                },
              ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => DoctorProfilePage(
            doctorId: item['doctorId'] ?? '',
            doctorName: item['name'] ?? 'طبيب',
            specialization: item['specialty'] ?? '',
          ),
          binding: DoctorProfileBinding(),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: AppColors.primary, size: 40),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            MyText(
              item['name'] ?? 'طبيب',
              fontSize: 15.sp,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            SpecialtyText(
              (item['specialty'] ?? '').toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
