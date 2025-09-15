import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hagz/utils/app_colors.dart';
import 'package:hagz/widget/my_text.dart';
import '../../../controller/doctor_profile_controller.dart';

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
    final controller = Get.put(DoctorProfileController());

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
            _buildExpandableSections(controller),

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

            // Title
            MyText(
              'بروفايل الطبيب',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),

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
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
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
                      const Icon(Icons.favorite, color: Colors.red, size: 16),
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
          _buildSocialIconImage('assets/icons/home/instgram.png', const Color(0xFFE4405F)),
          _buildSocialIconImage('assets/icons/home/phone.png', const Color(0xFFFF3040)),
          _buildSocialIconImage('assets/icons/home/watsapp.png', const Color(0xFF25D366)),
          _buildSocialIconImage('assets/icons/home/facebook.png', const Color(0xFF1877F2)),
          _buildSocialIconImage('assets/icons/home/link.png', Colors.grey),
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
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildSocialIconImage(String imagePath, Color color) {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Image.asset(
          imagePath,
          width: 34,
          height: 34,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to icons if image fails to load
            if (imagePath.contains('instgram')) {
              return Icon(Icons.camera_alt, color: color, size: 28);
            } else if (imagePath.contains('watsapp')) {
              return Icon(Icons.phone, color: color, size: 28);
            } else if (imagePath.contains('facebook')) {
              return Icon(Icons.facebook, color: color, size: 28);
            } else if (imagePath.contains('phone')) {
              return Icon(Icons.phone, color: color, size: 28);
            } else if (imagePath.contains('link')) {
              return Icon(Icons.link, color: color, size: 28);
            }
            return Icon(Icons.link, color: color, size: 28);
          },
        ),
      ),
    );
  }

  Widget _buildExpandableSections(DoctorProfileController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
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
            _buildExpandableSection(
              title: 'السيرة الذاتية و صور الشهادات',
              isExpanded: controller.isBioExpanded,
              onToggle: controller.toggleBioExpansion,
              content: _buildBioContent(controller),
              isFirst: true,
              isLast: false,
            ),
            const Divider(height: 1, thickness: 1),
            _buildExpandableSection(
              title: 'العنوان',
              isExpanded: controller.isAddressExpanded,
              onToggle: controller.toggleAddressExpansion,
              content: _buildAddressContent(controller),
              isFirst: false,
              isLast: false,
            ),
            const Divider(height: 1, thickness: 1),
            _buildExpandableSection(
              title: 'الآراء',
              isExpanded: controller.isOpinionsExpanded,
              onToggle: controller.toggleOpinionsExpansion,
              content: _buildReviewsContent(controller),
              isFirst: false,
              isLast: false,
            ),
            const Divider(height: 1, thickness: 1),
            _buildExpandableSection(
              title: 'صور لحالات تمت معالجتها',
              isExpanded: controller.isCasesExpanded,
              onToggle: controller.toggleCasesExpansion,
              content: _buildCaseImagesContent(controller),
              isFirst: false,
              isLast: false,
            ),
            const Divider(height: 1, thickness: 1),
            _buildExpandableSection(
              title: 'طلب سيارة أجرة',
              isExpanded: controller.isInsuranceExpanded,
              onToggle: controller.toggleInsuranceExpansion,
              content: _buildInsuranceContent(controller),
              isFirst: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required RxBool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        // Header with tap functionality
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MyText(
                    title,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.right,
                  ),
                ),
                Obx(
                  () => AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded.value ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content with animation
        Obx(
          () => AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(),
            secondChild: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: content,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBioContent(DoctorProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => MyText(
            controller.doctorBio.value,
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(height: 16.h),
        MyText(
          'الشهادات:',
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 8.h),
        Container(
          height: 150.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: const Center(
            child: Icon(Icons.image, size: 40, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressContent(DoctorProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 20.r),
            SizedBox(width: 8.w),
            Expanded(
              child: Obx(
                () => MyText(
                  controller.doctorAddress.value,
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Icon(Icons.phone, color: AppColors.primary, size: 20.r),
            SizedBox(width: 8.w),
            Obx(
              () => MyText(
                controller.doctorPhone.value,
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewsContent(DoctorProfileController controller) {
    return Obx(
      () => Column(
        children: controller.opinions
            .map(
              (opinion) => Container(
                margin: EdgeInsets.only(bottom: 16.h),
                child: _buildReviewItem(
                  opinion['patientName'],
                  opinion['date'],
                  opinion['comment'],
                  opinion['rating'].toDouble(),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildReviewItem(
    String name,
    String time,
    String review,
    double rating,
  ) {
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14.r),
                      SizedBox(width: 4.w),
                      MyText(
                        rating.toString(),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              MyText(
                time,
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 8.h),
              MyText(
                review,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaseImagesContent(DoctorProfileController controller) {
    return Obx(
      () => Column(
        children: controller.treatedCases
            .map(
              (case_) => Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12.r),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.medical_services,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            case_['title']!,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 8.h),
                          MyText(
                            case_['description']!,
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInsuranceContent(DoctorProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          'خدمات النقل المتاحة:',
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 16.h),

        // Ride service button
        InkWell(
          onTap: () {
            // Handle taxi booking
            Get.snackbar(
              'طلب سيارة أجرة',
              'سيتم توجيهك لتطبيق بلي',
              backgroundColor: AppColors.primary,
              colorText: Colors.white,
            );
          },
          borderRadius: BorderRadius.circular(25.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F2FF), // Very light blue background
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Row(
              children: [
                // Company logo - Baly style
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          'بلي',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0066FF), // Bright blue
                        ),
                        MyText(
                          'BALY',
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0066FF),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),

                // Service name
                Expanded(
                  child: MyText(
                    'شركة بلي',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 16.w),

                // Forward arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[700],
                  size: 20.r,
                ),
              ],
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
            const Icon(Icons.calendar_today, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
