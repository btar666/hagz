import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/doctor_profile_controller.dart';

class DoctorProfileManagePage extends StatelessWidget {
  DoctorProfileManagePage({super.key});

  final TextEditingController _instagramCtrl = TextEditingController(
    text: 'http://ABCDEFG',
  );
  final TextEditingController _whatsappCtrl = TextEditingController(
    text: 'http://ABCDEFG',
  );
  final TextEditingController _phoneCtrl = TextEditingController(
    text: '0770 000 0000',
  );
  final TextEditingController _facebookCtrl = TextEditingController();
  final TextEditingController _websiteCtrl = TextEditingController(
    text: 'http://ABCDEFG',
  );

  @override
  Widget build(BuildContext context) {
    final DoctorProfileController controller = Get.put(
      DoctorProfileController(),
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48.h,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: MyText(
                        'ادارة حسابك الشخصي',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 48.h),
                ],
              ),
              SizedBox(height: 16.h),

              _buildProfileCard(),

              SizedBox(height: 12.h),
              Obx(
                () => !controller.isEditingSocial.value
                    ? SizedBox(
                        width: double.infinity,
                        height: 64.h,
                        child: ElevatedButton(
                          onPressed: () => controller.toggleEditingSocial(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            elevation: 0,
                          ),
                          child: MyText(
                            'تعديل وسائل التواصل',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              Obx(
                () => controller.isEditingSocial.value
                    ? _buildSocialEditCard(controller)
                    : const SizedBox.shrink(),
              ),

              SizedBox(height: 16.h),

              _buildSectionsList(),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    // مطابق لتصميم صفحة بروفايل الطبيب الحالية
    return Column(
      children: [
        Padding(
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
                  Image.asset(
                    'assets/icons/home/doctor.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
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
        ),
        SizedBox(height: 20.h),
        MyText(
          'د. أيكورت',
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 8.h),
        MyText(
          'طب و جراحة العيون',
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _socialIconImage(
                'assets/icons/home/instgram.png',
                const Color(0xFFE4405F),
              ),
              _socialIconImage(
                'assets/icons/home/phone.png',
                const Color(0xFFFF3040),
              ),
              _socialIconImage(
                'assets/icons/home/watsapp.png',
                const Color(0xFF25D366),
              ),
              _socialIconImage(
                'assets/icons/home/facebook.png',
                const Color(0xFF1877F2),
              ),
              _socialIconImage('assets/icons/home/link.png', Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _socialIconImage(String imagePath, Color color) {
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
        ),
      ),
    );
  }

  Widget _buildSocialEditCard(DoctorProfileController controller) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _editableRow(
            _instagramCtrl,
            hint: 'http://ABCDEFG',
            trailingAsset: 'assets/icons/home/instgram.png',
          ),
          SizedBox(height: 12.h),
          _editableRow(
            _whatsappCtrl,
            hint: 'http://ABCDEFG',
            trailingAsset: 'assets/icons/home/watsapp.png',
          ),
          SizedBox(height: 12.h),
          _editableRow(
            _phoneCtrl,
            hint: '0770 000 0000',
            trailingAsset: 'assets/icons/home/phone.png',
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 12.h),
          _plainRow(
            _facebookCtrl,
            hint: 'ضع رابط حسابك على فيسبوك',
            trailingAsset: 'assets/icons/home/facebook.png',
          ),
          SizedBox(height: 12.h),
          _labeledRow(
            'افتراضي',
            _websiteCtrl,
            hint: 'http://ABCDEFG',
            trailingAsset: 'assets/icons/home/link.png',
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.toggleEditingSocial(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.secondary),
                    foregroundColor: AppColors.secondary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: MyText(
                    'إلغاء',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.toggleEditingSocial(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    elevation: 0,
                  ),
                  child: MyText(
                    'حفظ',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editableRow(
    TextEditingController controller, {
    required String hint,
    required String trailingAsset,
    TextInputType? keyboardType,
  }) {
    return Row(
      children: [
        _minusButton(() => controller.clear()),
        SizedBox(width: 8.w),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.textLight),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontFamily: 'Expo Arabic',
                        color: AppColors.textLight,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontFamily: 'Expo Arabic',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Image.asset(trailingAsset, width: 22.w, height: 22.w),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _plainRow(
    TextEditingController controller, {
    required String hint,
    required String trailingAsset,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.textLight),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Expo Arabic',
                  color: AppColors.textLight,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'Expo Arabic',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Image.asset(trailingAsset, width: 22.w, height: 22.w),
        ],
      ),
    );
  }

  Widget _labeledRow(
    String label,
    TextEditingController controller, {
    required String hint,
    required String trailingAsset,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.textLight),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Row(
        children: [
          MyText(
            label,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Expo Arabic',
                  color: AppColors.textLight,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'Expo Arabic',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Image.asset(trailingAsset, width: 22.w, height: 22.w),
        ],
      ),
    );
  }

  Widget _minusButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
        ),
        child: Icon(Icons.remove_circle, color: Colors.redAccent, size: 26.sp),
      ),
    );
  }

  Widget _buildSectionsList() {
    final List<String> sections = [
      'السيرة الذاتية و صور الشهادات',
      'العنوان',
      'الآراء',
      'المواعيد المتاحة',
      'تسلسل المواعيد',
      'صور لحالات تمت معالجتها',
      'الحوالات المالية',
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Column(
        children: [
          _bioManageTile(),
          for (final title in sections.skip(1)) _sectionTile(title),
        ],
      ),
    );
  }

  Widget _bioManageTile() {
    final DoctorProfileController controller = Get.find();
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: controller.toggleBioExpansion,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Row(
                children: [
                  const Icon(Icons.expand_more, color: AppColors.textSecondary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: MyText(
                      'السيرة الذاتية و صور الشهادات',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: controller.isBioExpanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: _bioEditContent(controller),
            ),
          ),
          Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }

  Widget _bioEditContent(DoctorProfileController controller) {
    final TextEditingController bioCtrl = TextEditingController(
      text: controller.doctorBio.value,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider),
          ),
          padding: EdgeInsets.all(12.w),
          child: TextField(
            controller: bioCtrl,
            maxLines: 6,
            textAlign: TextAlign.right,
            decoration: const InputDecoration.collapsed(
              hintText: 'اكتب سيرتك الذاتية هنا...',
            ),
            style: const TextStyle(fontFamily: 'Expo Arabic'),
            onChanged: controller.updateBio,
          ),
        ),
        SizedBox(height: 12.h),
        MyText(
          'صور الشهادات',
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              for (int i = 0; i < controller.certificateImages.length; i++)
                Stack(
                  children: [
                    Container(
                      width: 160.w,
                      height: 110.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.r),
                        image: DecorationImage(
                          image: AssetImage(controller.certificateImages[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: InkWell(
                        onTap: () => controller.removeCertificateAt(i),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              _addCertificateButton(controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addCertificateButton(DoctorProfileController controller) {
    return InkWell(
      onTap: () {
        controller.addCertificate('assets/images/sample_certificate.png');
      },
      child: Container(
        width: 160.w,
        height: 110.h,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.primary),
            SizedBox(height: 6.h),
            MyText(
              'إضافة صورة',
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTile(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          const Icon(Icons.expand_more, color: AppColors.textSecondary),
          SizedBox(width: 8.w),
          Expanded(
            child: MyText(
              title,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
