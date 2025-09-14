import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';

class DoctorProfilePage extends StatelessWidget {
  final String doctorName;
  final String specialization;
  
  const DoctorProfilePage({
    super.key,
    required this.doctorName,
    required this.specialization,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with back button, title, and chat button
            _buildHeader(),
            
            // Doctor image section
            _buildDoctorImage(),
            
            SizedBox(height: 20.h),
            
            // Doctor name and specialty
            _buildDoctorInfo(),
            
            SizedBox(height: 20.h),
            
            // Social media icons
            _buildSocialMediaIcons(),
            
            SizedBox(height: 30.h),
            
            // Expandable sections
            _buildExpandableSections(),
            
            SizedBox(height: 30.h),
            
            // Book appointment button
            _buildBookButton(),
            
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
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
            
            // Title
            MyText(
              'بروفايل الطبيب',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            
            // Chat button
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorImage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        width: double.infinity,
        height: 400.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              // Doctor image
              Image.asset(
                'assets/icons/home/doctor.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryLight,
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
              
              // Rating badge
              Positioned(
                bottom: 16.h,
                left: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText(
                        '200 تقييم',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 4.w),
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 16,
                      ),
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

  Widget _buildDoctorInfo() {
    return Column(
      children: [
        MyText(
          doctorName,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        MyText(
          specialization,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSocialMediaIcons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 60.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSocialIcon(Icons.link, Colors.grey),
          _buildSocialIcon(Icons.facebook, const Color(0xFF1877F2)),
          _buildSocialIcon(Icons.phone, const Color(0xFF25D366)),
          _buildSocialIcon(Icons.phone, const Color(0xFFFF3040)),
          _buildSocialIcon(Icons.camera_alt, const Color(0xFFE4405F)),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildExpandableSections() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        children: [
          _buildExpandableSection('السيرة الذاتية و صور الشهادات', false, null),
          SizedBox(height: 20.h),
          _buildExpandableSection('العنوان', true, _buildAddressContent()),
          SizedBox(height: 20.h),
          _buildExpandableSection('الآراء', true, _buildReviewsContent()),
          SizedBox(height: 20.h),
          _buildExpandableSection('صور لحالات تمت معالجتها', true, _buildCaseImagesContent()),
          SizedBox(height: 20.h),
          _buildExpandableSection('طلب سيارة أجرة', false, null),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(String title, bool isExpanded, Widget? content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  title,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.right,
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
          if (isExpanded && content != null) ...[
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: content,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressContent() {
    return MyText(
      'مركز العيون التخصصي ، دهوك',
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      textAlign: TextAlign.right,
    );
  }

  Widget _buildReviewsContent() {
    return Column(
      children: [
        _buildReviewItem('غوثيا', 'منذ 10 دقائق', 'أنها طبيبة محترفة و تتمتع بخبرة واسعة في مجالها.'),
        SizedBox(height: 16.h),
        _buildReviewItem('ريتشارد', 'منذ 26 دقيقة', 'أنها طبيبة محترفة و تتمتع بخبرة واسعة في مجالها.'),
        SizedBox(height: 16.h),
        _buildReviewItem('سيروكو', 'منذ 10 ساعات', 'أنها طبيبة محترفة و تتمتع بخبرة واسعة في مجالها.'),
      ],
    );
  }

  Widget _buildReviewItem(String name, String time, String review) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: AppColors.primaryLight,
          child: MyText(
            name[0],
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MyText(
                    name,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  const Spacer(),
                  MyText(
                    time,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              MyText(
                review,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaseImagesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          'اسم الحالة: جفاف و حساسية',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.red,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              'assets/icons/home/case_image.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primaryLight,
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.fullscreen,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText(
              'حجز موعد',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
            SizedBox(width: 8.w),
            const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
