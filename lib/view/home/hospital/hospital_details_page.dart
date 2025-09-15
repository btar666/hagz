import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hagz/utils/app_colors.dart';
import 'package:hagz/widget/my_text.dart';
import '../../../controller/hospital_details_controller.dart';

class HospitalDetailsPage extends StatelessWidget {
  final String hospitalName;
  final String hospitalLocation;

  const HospitalDetailsPage({
    super.key,
    required this.hospitalName,
    required this.hospitalLocation,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HospitalDetailsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            SizedBox(height: 20.h),

            // Main content section
            _buildMainContent(),

            SizedBox(height: 20.h),

            // Ride request section
            _buildRideRequestSection(controller),

            SizedBox(height: 30.h),

            // Doctors grid section
            _buildDoctorsSection(),

            SizedBox(height: 30.h),
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
                'تفاصيل المستشفى',
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

  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hospital info section
          Expanded(child: _buildHospitalInfoCard()),

          SizedBox(width: 20.w),
          // Social media icons column
          _buildSocialMediaColumn(),
        ],
      ),
    );
  }

  Widget _buildSocialMediaColumn() {
    return Container(
      width: 70.w,
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
        padding: EdgeInsets.symmetric(vertical: 15.h),
        child: Column(
          children: [
            _buildSocialIconItem(
              'assets/icons/home/instgram.png',
              const Color(0xFFE4405F),
            ),
            SizedBox(height: 12.h),
            _buildSocialIconItem(
              'assets/icons/home/phone.png',
              const Color(0xFFFF3040),
            ),
            SizedBox(height: 12.h),
            _buildSocialIconItem(
              'assets/icons/home/watsapp.png',
              const Color(0xFF25D366),
            ),
            SizedBox(height: 12.h),
            _buildSocialIconItem(
              'assets/icons/home/facebook.png',
              const Color(0xFF1877F2),
            ),
            SizedBox(height: 12.h),
            _buildSocialIconItem('assets/icons/home/link.png', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIconItem(String imagePath, Color color) {
    return Container(
      width: 45.w,
      height: 45.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Image.asset(
          imagePath,
          width: 25,
          height: 25,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icons
            IconData fallbackIcon = Icons.link;
            if (imagePath.contains('instgram')) {
              fallbackIcon = Icons.camera_alt;
            } else if (imagePath.contains('watsapp')) {
              fallbackIcon = Icons.phone;
            } else if (imagePath.contains('facebook')) {
              fallbackIcon = Icons.facebook;
            } else if (imagePath.contains('phone')) {
              fallbackIcon = Icons.phone;
            }
            return Icon(fallbackIcon, color: color, size: 25);
          },
        ),
      ),
    );
  }

  Widget _buildHospitalInfoCard() {
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
        child: Column(
          children: [
            // Hospital logo
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(15.w),
                child: Image.asset(
                  'assets/icons/home/hospital.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_hospital,
                          size: 40.r,
                          color: const Color(0xFF7FC8D6),
                        ),
                        SizedBox(height: 5.h),
                        MyText(
                          'MEDICAL CARE',
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7FC8D6),
                          textAlign: TextAlign.center,
                        ),
                        MyText(
                          'Medical Center',
                          fontSize: 6.sp,
                          color: const Color(0xFF7FC8D6),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Hospital name
            MyText(
              hospitalName,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 15.h),

            // Contact section
            MyText(
              'للتواصل :',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // Address
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: const Color(0xFF7FC8D6),
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: MyText(
                    hospitalLocation,
                    fontSize: 12.sp,
                    color: const Color(0xFF7FC8D6),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Phone numbers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.black54, size: 18.r),
                    SizedBox(width: 5.w),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: const Color(0xFF7FC8D6),
                      size: 18.r,
                    ),
                    SizedBox(width: 5.w),
                    MyText(
                      '0770 000 0000',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF7FC8D6),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideRequestSection(HospitalDetailsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
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
              Expanded(
                child: MyText(
                  'طلب سيارة أجرة',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  textAlign: TextAlign.right,
                ),
              ),
              Obx(
                () => AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: controller.isRideExpanded.value ? 0.5 : 0,
                  child: GestureDetector(
                    onTap: controller.toggleRideExpansion,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black54,
                      size: 24.r,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Section header
          Row(
            children: [
              Icon(
                Icons.medical_services,
                color: const Color(0xFF7FC8D6),
                size: 24.r,
              ),
              SizedBox(width: 10.w),
              MyText(
                'الكُل',
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Doctors grid
          Row(
            children: [
              Expanded(
                child: _buildDoctorCard(
                  'آرين',
                  'جراحة الفم',
                  'assets/images/doctor1.jpg',
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: _buildDoctorCard(
                  'مالهوزن',
                  'جراحة العيون',
                  'assets/images/doctor2.jpg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(String name, String specialty, String imagePath) {
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
      child: Column(
        children: [
          // Doctor image
          Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      size: 80.r,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          ),

          // Doctor info
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              children: [
                MyText(
                  name,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5.h),
                MyText(
                  specialty,
                  fontSize: 12.sp,
                  color: Colors.black54,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
