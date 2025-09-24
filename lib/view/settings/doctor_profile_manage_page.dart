import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/doctor_profile_controller.dart';
import '../appointments/appointment_details_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontFamily: 'Expo Arabic',
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
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
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'Expo Arabic',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
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
    final List<String> remaining = ['الحوالات المالية'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Column(
        children: [
          _bioManageTile(),
          _addressManageTile(),
          _opinionsManageTile(),
          _availabilityManageTile(),
          _sequenceManageTile(),
          _casesManageTile(),
          for (final title in remaining) _sectionTile(title),
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
                  Expanded(
                    child: MyText(
                      'السيرة الذاتية و صور الشهادات',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: controller.isBioExpanded.value ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: AppColors.textSecondary),
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
                          image: _imageProvider(
                            controller.certificateImages[i],
                          ),
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
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  controller.toggleBioExpansion();
                },
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
                onPressed: () {
                  controller.updateBio(bioCtrl.text);
                  controller.toggleBioExpansion();
                  Get.snackbar(
                    'تم الحفظ',
                    'تم تحديث السيرة الذاتية',
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
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
    );
  }

  Widget _addCertificateButton(DoctorProfileController controller) {
    return InkWell(
      onTap: () async {
        final ImagePicker picker = ImagePicker();
        final XFile? picked = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (picked != null) {
          controller.addCertificate(picked.path);
        }
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

  // Address manage tile
  Widget _addressManageTile() {
    final controller = Get.find<DoctorProfileController>();
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: controller.toggleAddressExpansion,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Row(
                children: [
                  Expanded(
                    child: MyText(
                      'العنوان',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: controller.isAddressExpanded.value ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: controller.isAddressExpanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: _addressEditContent(controller),
            ),
          ),
          Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }

  // Opinions manage tile
  Widget _opinionsManageTile() {
    final controller = Get.find<DoctorProfileController>();
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: controller.toggleOpinionsExpansion,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Row(
                children: [
                  Expanded(
                    child: MyText(
                      'الآراء',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  // new opinions badge
                  Builder(
                    builder: (_) {
                      final int newCount = controller.opinions
                          .where((e) => !(e['published'] as bool? ?? false))
                          .length;
                      return newCount > 0
                          ? MyText(
                              '$newCount آراء جديدة',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF3040),
                              textAlign: TextAlign.left,
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: controller.isOpinionsExpanded.value ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: controller.isOpinionsExpanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: _opinionsContent(controller),
            ),
          ),
          Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }

  Widget _addressEditContent(DoctorProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MyText(
          'اكتب عناوينك كتابة أو قم بوضع رابطه',
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Obx(
          () => Column(
            children: [
              for (int i = 0; i < controller.addresses.length; i++)
                _addressRow(controller, i),
              SizedBox(height: 16.h),
              _addAddressButton(controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addressRow(DoctorProfileController controller, int index) {
    final item = controller.addresses[index];
    final TextEditingController fieldCtrl = TextEditingController(
      text: (item['value'] ?? '') as String,
    );
    final bool isLink = (item['isLink'] ?? false) as bool;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        height: 78.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(color: const Color(0xFF616E7C), width: 1.6),
        ),
        child: Stack(
          children: [
            // text field aligned to start (يمين) مع هامش للأيقونات اليسار
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: TextField(
                  controller: fieldCtrl,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: isLink
                        ? 'الصق الرابط هنا ..'
                        : 'اكتب العنوان هنا',
                    hintStyle: TextStyle(
                      color: AppColors.textLight,
                      fontFamily: 'Expo Arabic',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    contentPadding: EdgeInsets.only(right: 16.w, left: 96.w),
                  ),
                  style: TextStyle(
                    fontFamily: 'Expo Arabic',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  onChanged: (v) => controller.updateAddressValue(index, v),
                ),
              ),
            ),
            // left side action buttons (inside the field)
            Positioned(
              left: 16.w,
              top: 0,
              bottom: 0,
              child: Row(
                children: [
                  _minusRedCircle(() => controller.removeAddressAt(index)),
                  SizedBox(width: 12.w),
                  _editYellowIcon(() => controller.toggleAddressType(index)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addAddressButton(DoctorProfileController controller) {
    return InkWell(
      onTap: () => controller.addAddress(isLink: false),
      borderRadius: BorderRadius.circular(28.r),
      child: Container(
        height: 64.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F5),
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Center(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: AppColors.textSecondary),
                SizedBox(width: 8.w),
                MyText(
                  'أضف عنوان جديد',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // عناصر التحكم الخاصة بالقسم (تصميم جديد)
  Widget _minusRedCircle(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: const BoxDecoration(
          color: Color(0xFFFF5252),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.remove, color: Colors.white, size: 22.sp),
      ),
    );
  }

  Widget _editYellowIcon(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(Icons.edit, color: Color(0xFFFFC107), size: 28.sp),
    );
  }

  // Opinions content
  Widget _opinionsContent(DoctorProfileController controller) {
    return Obx(
      () => Column(
        children: [
          for (int i = 0; i < controller.opinions.length; i++) ...[
            _opinionItem(controller, i),
            if (i != controller.opinions.length - 1)
              Divider(color: AppColors.divider, height: 1),
          ],
        ],
      ),
    );
  }

  Widget _opinionItem(DoctorProfileController controller, int index) {
    final item = controller.opinions[index];
    final String name = (item['patientName'] ?? '') as String;
    final String comment = (item['comment'] ?? '') as String;
    final String? dateStr = item['date'] as String?;
    final bool published = (item['published'] as bool? ?? false);
    final String timeAgo = _formatRelative(dateStr);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Spacer left to align with RTL; avatar on right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      spacing: 6.w,
                      children: [
                        MyText(
                          name,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                        MyText(
                          '( $timeAgo )',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    MyText(
                      comment,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              _circleAvatar(item['avatar'] as String?),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _pillButton(
                  label: 'حذف',
                  bg: const Color(0xFFFFEEEE),
                  fg: const Color(0xFFFF3040),
                  onTap: () => controller.removeOpinionAt(index),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _pillButton(
                  label: published ? 'الغاء النشر' : 'نشر',
                  bg: published
                      ? const Color(0xFFE8F7FA)
                      : const Color(0xFFFFF4DB),
                  fg: published
                      ? const Color(0xFF18A2AE)
                      : const Color(0xFFFFA000),
                  onTap: () => controller.toggleOpinionPublished(index),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleAvatar(String? assetPath) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: assetPath != null
          ? Image.asset(assetPath, fit: BoxFit.cover)
          : const Icon(Icons.person, size: 28, color: AppColors.textSecondary),
    );
  }

  Widget _pillButton({
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Center(
          child: MyText(
            label,
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: fg,
          ),
        ),
      ),
    );
  }

  String _formatRelative(String? isoString) {
    if (isoString == null) return 'منذ لحظات';
    DateTime? date;
    try {
      date = DateTime.parse(isoString);
    } catch (_) {
      return 'منذ لحظات';
    }
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعات';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return 'منذ ${diff.inDays ~/ 7} أسابيع';
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

  ImageProvider _imageProvider(String path) {
    // If path points to a file on device, use FileImage; otherwise assume asset
    if (path.startsWith('/') || path.contains('\\') || path.contains(':\\')) {
      return FileImage(File(path));
    }
    return AssetImage(path);
  }

  // Availability manage tile
  Widget _availabilityManageTile() {
    final controller = Get.find<DoctorProfileController>();
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: controller.toggleAvailabilityExpansion,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Row(
                children: [
                  Expanded(
                    child: MyText(
                      'المواعيد المتاحة',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: controller.isAvailabilityExpanded.value ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: controller.isAvailabilityExpanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: _availabilityContent(controller),
            ),
          ),
          Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }

  Widget _availabilityContent(DoctorProfileController controller) {
    final DateTime month = controller.selectedMonth.value;
    final int year = month.year;
    final int m = month.month;
    final DateTime firstDay = DateTime(year, m, 1);
    final int startIndex = firstDay.weekday % 7; // 0 => Sunday
    final int daysInMonth = DateTime(year, m + 1, 0).day;
    final int total = ((startIndex + daysInMonth + 6) ~/ 7) * 7;

    final weekNames = [
      'أحد',
      'اثنين',
      'ثلاثاء',
      'أربعاء',
      'خميس',
      'جمعة',
      'سبت',
    ];

    Color bgForStatus(String status) {
      switch (status) {
        case 'available':
          return const Color(0xFFE3F5ED); // light green
        case 'holiday':
          return const Color(0xFFFFF0D5); // light yellow
        case 'closed':
          return const Color(0xFFFFE4E4); // light red
        case 'open':
        default:
          return const Color(0xFFEFF3F8); // light gray
      }
    }

    Widget legendDot(Color color) => Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Month header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: controller.prevMonth,
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      MyText(
                        '$year, $m',
                        fontSize: 16.sp,
                        color: AppColors.textPrimary,
                      ),
                      const Icon(
                        Icons.expand_more,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                InkWell(
                  onTap: controller.nextMonth,
                  child: const Icon(
                    Icons.chevron_left,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            MyText(
              'هذا الشهر',
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ],
        ),
        SizedBox(height: 10.h),
        // Weekdays header
        Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final name in weekNames)
                MyText(
                  name,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.0,
          ),
          itemCount: total,
          itemBuilder: (_, i) {
            if (i < startIndex || i >= startIndex + daysInMonth) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              );
            }
            final day = i - startIndex + 1;
            final status = controller.dayStatuses[day] ?? 'open';
            return Container(
              decoration: BoxDecoration(
                color: bgForStatus(status),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: MyText(
                  '$day',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 16.h),
        // Legend
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyText(
                  'الحجز متاح',
                  fontSize: 18.sp,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 10.w),
                legendDot(const Color(0xFFEFF3F8)),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyText(
                  'الحجوزات ممتلئة',
                  fontSize: 18.sp,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 10.w),
                legendDot(const Color(0xFF2ECC71)),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyText(
                  'عطلة العيادة',
                  fontSize: 18.sp,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 10.w),
                legendDot(const Color(0xFFFFC107)),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyText(
                  'العيادة مغلقة',
                  fontSize: 18.sp,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 10.w),
                legendDot(const Color(0xFFFF3B30)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Sequence manage tile
  Widget _sequenceManageTile() {
    final controller = Get.find<DoctorProfileController>();
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: controller.toggleSequenceExpansion,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Row(
                children: [
                  Expanded(
                    child: MyText(
                      'تسلسل المواعيد',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: controller.isSequenceExpanded.value ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: controller.isSequenceExpanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: _sequenceContent(controller),
            ),
          ),
          Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }

  Widget _sequenceContent(DoctorProfileController controller) {
    Color statusColor(String status) {
      switch (status) {
        case 'completed':
          return const Color(0xFF2ECC71);
        case 'pending':
          return const Color(0xFFFFA000);
        case 'cancelled':
          return const Color(0xFFFF3B30);
        default:
          return AppColors.textSecondary;
      }
    }

    String statusLabel(String s) {
      switch (s) {
        case 'completed':
          return 'مكتمل';
        case 'pending':
          return 'قيد الانتظار';
        case 'cancelled':
          return 'ملغي';
        default:
          return s;
      }
    }

    Widget dot({Color color = AppColors.textSecondary}) => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    return Obx(
      () => Column(
        children: [
          for (int i = 0; i < controller.sequenceAppointments.length; i++) ...[
            _sequenceItem(
              patient: controller.sequenceAppointments[i]['patient'] as String,
              order: controller.sequenceAppointments[i]['order'] as int,
              time: controller.sequenceAppointments[i]['time'] as String,
              status: controller.sequenceAppointments[i]['status'] as String,
              statusColor: statusColor,
              statusLabel: statusLabel,
              dot: dot,
              onTap: () {
                final s =
                    controller.sequenceAppointments[i]['status'] as String;
                Color sColor = statusColor(s);
                String sText = statusLabel(s);
                Get.to(
                  () => AppointmentDetailsPage(
                    details: {
                      'patient': controller.sequenceAppointments[i]['patient'],
                      'order': controller.sequenceAppointments[i]['order'],
                      'time': controller.sequenceAppointments[i]['time'],
                      'statusText': sText,
                      'statusColor': sColor,
                      'age': 22,
                      'gender': 'أنثى',
                      'phone': '0770 000 0000',
                      'date': _formatDate(DateTime.now()),
                      'price': '10,000 د.ع',
                    },
                  ),
                );
              },
            ),
            if (i != controller.sequenceAppointments.length - 1)
              Divider(color: AppColors.divider, height: 1),
          ],
        ],
      ),
    );
  }

  Widget _sequenceItem({
    required String patient,
    required int order,
    required String time,
    required String status,
    required Color Function(String) statusColor,
    required String Function(String) statusLabel,
    required Widget Function({Color color}) dot,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row flipped: content on اليسار (Left), arrow on اليمين (Right), بدون صورة
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content (left)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        patient,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 8.h),
                      // order • time • status
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: [
                            MyText(
                              'التسلسل : $order',
                              fontSize: 18.sp,
                              color: AppColors.textSecondary,
                            ),
                            dot(
                              color: AppColors.textSecondary.withOpacity(0.6),
                            ),
                            MyText(
                              time,
                              fontSize: 18.sp,
                              color: AppColors.textSecondary,
                            ),
                            dot(
                              color: AppColors.textSecondary.withOpacity(0.6),
                            ),
                            MyText(
                              statusLabel(status),
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: statusColor(status),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Right arrow
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Cases manage tile (treated cases)
  Widget _casesManageTile() {
    final controller = Get.find<DoctorProfileController>();
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: controller.toggleCasesExpansion,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Row(
                children: [
                  Expanded(
                    child: MyText(
                      'صور لحالات تمت معالجتها',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: controller.isCasesExpanded.value ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: controller.isCasesExpanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: _casesEditContent(controller),
            ),
          ),
          Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }

  Widget _casesEditContent(DoctorProfileController controller) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form: Add new case (single image from gallery)
          MyText(
            'إضافة حالة جديدة',
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.divider),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: TextField(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'اكتب اسم الحالة',
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'Expo Arabic',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
              onChanged: controller.updateNewCaseName,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: const Color(0xFFF2F4F5),
                  image: controller.newCaseImage.value.isNotEmpty
                      ? DecorationImage(
                          image: _imageProvider(controller.newCaseImage.value),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: controller.newCaseImage.value.isEmpty
                    ? const Icon(Icons.image, color: AppColors.textSecondary)
                    : null,
              ),
              SizedBox(width: 10.w),
              OutlinedButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 90,
                  );
                  if (picked != null) {
                    controller.updateNewCaseImage(picked.path);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('اختيار صورة من المعرض'),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed:
                  controller.canAddCase ? controller.addManagedCase : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.divider,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: MyText(
                'إضافة الحالة',
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Divider(color: AppColors.divider, height: 1),
          SizedBox(height: 12.h),
          MyText(
            'الحالات المضافة',
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8.h),
          if (controller.managedCases.isEmpty)
            MyText(
              'لا توجد حالات بعد',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              textAlign: TextAlign.right,
            )
          else ...controller.managedCases.asMap().entries.map(
                (e) => Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    leading: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.r),
                        image: (e.value['image'] ?? '').isNotEmpty
                            ? DecorationImage(
                                image: _imageProvider(e.value['image']!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (e.value['image'] ?? '').isEmpty
                          ? const Icon(Icons.image,
                              color: AppColors.textSecondary, size: 20)
                          : null,
                    ),
                    title: MyText(
                      e.value['name'] ?? '',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'تعديل',
                          icon: const Icon(Icons.edit, color: AppColors.primary),
                          onPressed: () async {
                            final ctx = Get.context;
                            if (ctx == null) return;
                            final nameController = TextEditingController(
                              text: e.value['name'] ?? '',
                            );
                            String imagePath = e.value['image'] ?? '';
                            await showModalBottomSheet(
                              context: ctx,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  topRight: Radius.circular(20.r),
                                ),
                              ),
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setModalState) {
                                    return SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          16.w,
                                          16.h,
                                          16.w,
                                          16.h +
                                              MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            MyText(
                                              'تعديل الحالة',
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                              textAlign: TextAlign.right,
                                            ),
                                            SizedBox(height: 12.h),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                                border: Border.all(
                                                    color: AppColors.divider),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w),
                                              child: TextField(
                                                controller: nameController,
                                                textAlign: TextAlign.right,
                                                textDirection: TextDirection.rtl,
                                                decoration: const InputDecoration(
                                                  hintText: 'اسم الحالة',
                                                  border: InputBorder.none,
                                                ),
                                                style: TextStyle(
                                                  fontFamily: 'Expo Arabic',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 64.w,
                                                  height: 64.w,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.r),
                                                    color:
                                                        const Color(0xFFF2F4F5),
                                                    image: imagePath.isNotEmpty
                                                        ? DecorationImage(
                                                            image: _imageProvider(
                                                                imagePath),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                                  ),
                                                  child: imagePath.isEmpty
                                                      ? const Icon(Icons.image,
                                                          color: AppColors
                                                              .textSecondary)
                                                      : null,
                                                ),
                                                SizedBox(width: 10.w),
                                                OutlinedButton(
                                                  onPressed: () async {
                                                    final ImagePicker picker =
                                                        ImagePicker();
                                                    final XFile? picked =
                                                        await picker.pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                      imageQuality: 90,
                                                    );
                                                    if (picked != null) {
                                                      setModalState(() {
                                                        imagePath = picked.path;
                                                      });
                                                    }
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    side: BorderSide(
                                                        color: AppColors
                                                            .primary),
                                                    foregroundColor:
                                                        AppColors.primary,
                                                  ),
                                                  child: const Text(
                                                      'اختيار صورة من المعرض'),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 16.h),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      side: BorderSide(
                                                          color: AppColors
                                                              .secondary),
                                                      foregroundColor:
                                                          AppColors.secondary,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 14.h),
                                                    ),
                                                    child: MyText(
                                                      'إلغاء',
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          AppColors.secondary,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      controller
                                                          .updateManagedCaseNameAt(
                                                        e.key,
                                                        nameController.text,
                                                      );
                                                      controller
                                                          .updateManagedCaseImageAt(
                                                        e.key,
                                                        imagePath,
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          AppColors.secondary,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 14.h),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    18.r),
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                    child: MyText(
                                                      'حفظ',
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'حذف',
                          icon: const Icon(Icons.delete, color: Color(0xFFFF3B30)),
                          onPressed: () => controller.removeManagedCaseAt(e.key),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
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
          Expanded(
            child: MyText(
              title,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 8.w),
          const Icon(Icons.expand_more, color: AppColors.textSecondary),
        ],
      ),
    );
  }

}
