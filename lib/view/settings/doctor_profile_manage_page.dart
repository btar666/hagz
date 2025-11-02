import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/specialization_text.dart';
import '../../controller/doctor_profile_controller.dart';
import '../../controller/session_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../service_layer/services/upload_service.dart';
import '../../widget/loading_dialog.dart';
import '../../widget/status_dialog.dart';
import '../../widget/confirm_dialogs.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widget/back_button_widget.dart';
import '../../controller/doctor_profile_manage_controller.dart';

class DoctorProfileManagePage extends StatelessWidget {
  const DoctorProfileManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final manageController = Get.find<DoctorProfileManageController>();
    final DoctorProfileController controller = Get.put(
      DoctorProfileController(),
    );

    // Prefill CV from server if exists
    controller.fetchMyCvIfAny();

    // تحميل سعر الحجز الحالي
    final session = Get.find<SessionController>();
    final String? userId = session.currentUser.value?.id;
    if (userId != null && userId.isNotEmpty) {
      controller.loadDoctorPricing(userId);
      controller.loadRatingsCount(userId);

      // Load calendar for current month
      controller.loadDoctorCalendar(doctorId: userId);

      // Prefill social media from API
      if (!manageController.prefillCalled.value) {
        manageController.prefillSocialFromApi(userId);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 48.h),
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
                  const BackButtonWidget(),
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

              SizedBox(height: 12.h),

              // Personal info edit button
              Obx(
                () => !controller.isEditingPersonal.value
                    ? SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: OutlinedButton(
                          onPressed: () => controller.toggleEditingPersonal(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: MyText(
                            'تعديل المعلومات الشخصية',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              Obx(
                () => controller.isEditingPersonal.value
                    ? _buildPersonalEditCard(controller)
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
    final session = Get.find<SessionController>();
    final DoctorProfileController controller =
        Get.find<DoctorProfileController>();
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
                  Obx(() {
                    final img = session.currentUser.value?.image ?? '';
                    final loading = controller.isLoadingSocial.value;

                    if (loading) {
                      return Skeletonizer(
                        enabled: true,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[300],
                        ),
                      );
                    }

                    if (img.isNotEmpty) {
                      return Image.network(
                        img,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Image.asset(
                          'assets/icons/home/doctor.png',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    return Image.asset(
                      'assets/icons/home/doctor.png',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    );
                  }),
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: InkWell(
                      onTap: () => Get.find<DoctorProfileManageController>()
                          .uploadProfileImage(),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
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
                          Obx(
                            () => MyText(
                              '${controller.ratingsCount.value} تقييم',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
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
        Obx(() {
          final session = Get.find<SessionController>();
          final name = session.currentUser.value?.name ?? '—';
          return MyText(
            name.isNotEmpty ? name : '—',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          );
        }),
        SizedBox(height: 8.h),
        Obx(() {
          final session = Get.find<SessionController>();
          final spec = session.currentUser.value?.specialization ?? '';
          return SpecializationText(
            specializationId: spec.isEmpty ? null : spec,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            defaultText: '—',
          );
        }),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Builder(
            builder: (context) {
              final manageController =
                  Get.find<DoctorProfileManageController>();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialIconImage(
                    'assets/icons/home/instgram.png',
                    const Color(0xFFE4405F),
                    onTap: () => _openUrlIfAny(
                      manageController.instagramCtrl.text,
                      fallbackHost: 'instagram.com',
                    ),
                  ),
                  _socialIconImage(
                    'assets/icons/home/watsapp.png',
                    const Color(0xFF25D366),
                    onTap: () =>
                        _openWhatsapp(manageController.whatsappCtrl.text),
                  ),
                  _socialIconImage(
                    'assets/icons/home/facebook.png',
                    const Color(0xFF1877F2),
                    onTap: () => _openUrlIfAny(
                      manageController.facebookCtrl.text,
                      fallbackHost: 'facebook.com',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _socialIconImage(
    String imagePath,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Future<void> _openWhatsapp(String input) async {
    final v = input.trim();
    if (v.isEmpty || v.startsWith('http://ABCDEFG')) {
      Get.snackbar(
        'لا يوجد رابط',
        'لم يتم ضبط رابط الواتساب',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }
    String url = v;
    if (!v.startsWith('http')) {
      // افترض أنه رقم هاتف؛ ازل الفراغات والرموز
      final digits = v.replaceAll(RegExp(r'[^0-9+]'), '');
      url = 'https://wa.me/$digits';
    }
    await _launchExternal(url);
  }

  Future<void> _openUrlIfAny(String input, {String? fallbackHost}) async {
    var v = input.trim();
    if (v.isEmpty || v.startsWith('http://ABCDEFG')) {
      Get.snackbar(
        'لا يوجد رابط',
        'لم يتم ضبط الرابط',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }
    if (!v.startsWith('http')) {
      // أضف https تلقائياً
      v = 'https://$v';
    }
    await _launchExternal(v);
  }

  Future<void> _launchExternal(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'تعذر الفتح',
          'لا يمكن فتح الرابط',
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } catch (_) {
      Get.snackbar(
        'تعذر الفتح',
        'الرابط غير صالح',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildSocialEditCard(DoctorProfileController controller) {
    final manageController = Get.find<DoctorProfileManageController>();
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
            manageController.instagramCtrl,
            hint: 'http://ABCDEFG',
            trailingAsset: 'assets/icons/home/instgram.png',
          ),
          SizedBox(height: 12.h),
          _editableRow(
            manageController.whatsappCtrl,
            hint: 'http://ABCDEFG',
            trailingAsset: 'assets/icons/home/watsapp.png',
          ),
          SizedBox(height: 12.h),
          _plainRow(
            manageController.facebookCtrl,
            hint: 'ضع رابط حسابك على فيسبوك',
            trailingAsset: 'assets/icons/home/facebook.png',
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
                  onPressed: () async {
                    await manageController.updateSocialMedia();
                    controller.toggleEditingSocial();
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
    String? trailingAsset,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 16.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.textLight, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.textLight, width: 1),
          ),
          suffixIcon: (trailingAsset != null && trailingAsset.isNotEmpty)
              ? Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Image.asset(
                    trailingAsset,
                    width: 22.w,
                    height: 22.w,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.cake_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : null,
        ),
        style: TextStyle(
          fontFamily: 'Expo Arabic',
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
        ),
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

  Widget _buildPersonalEditCard(DoctorProfileController controller) {
    final manageController = Get.find<DoctorProfileManageController>();
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
          _plainRow(manageController.namePersonalCtrl, hint: 'الاسم الكامل'),
          SizedBox(height: 12.h),
          _plainRow(
            manageController.phonePersonalCtrl,
            hint: 'رقم الهاتف',
            trailingAsset: 'assets/icons/home/phone.png',
          ),
          SizedBox(height: 12.h),
          // Gender selector
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final sel = manageController.genderPersonalIndex.value == 0;
                  return OutlinedButton(
                    onPressed: () =>
                        manageController.genderPersonalIndex.value = 0,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: sel ? AppColors.primary : AppColors.divider,
                      ),
                      foregroundColor: sel
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: MyText(
                      'ذكر',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: sel ? AppColors.primary : AppColors.textSecondary,
                    ),
                  );
                }),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Obx(() {
                  final sel = manageController.genderPersonalIndex.value == 1;
                  return OutlinedButton(
                    onPressed: () =>
                        manageController.genderPersonalIndex.value = 1,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: sel ? AppColors.primary : AppColors.divider,
                      ),
                      foregroundColor: sel
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: MyText(
                      'أنثى',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: sel ? AppColors.primary : AppColors.textSecondary,
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _plainRow(manageController.agePersonalCtrl, hint: 'العمر'),
          SizedBox(height: 12.h),
          _cityDropdown(),
          SizedBox(height: 12.h),
          _specializationDropdown(),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.toggleEditingPersonal(),
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
                  onPressed: () async {
                    await manageController.updatePersonalInfo();
                    controller.toggleEditingPersonal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
          _pricingManageTile(),
          _availabilityManageTile(),
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
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.textSecondary,
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
    // إنشاء controller مرة واحدة فقط
    final TextEditingController bioCtrl = TextEditingController();

    // تعيين النص الأولي فقط إذا كانت هناك سيرة ذاتية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String text = controller.cvDescription.value;
      if (bioCtrl.text != text) {
        bioCtrl.text = text;
      }
    });

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
          child: TextFormField(
            controller: bioCtrl,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            minLines: 5,
            maxLines: 8,
            style: const TextStyle(
              fontFamily: 'Expo Arabic',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب سيرتك الذاتية هنا...',
              hintStyle: TextStyle(
                fontFamily: 'Expo Arabic',
                color: AppColors.textLight,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (v) {
              controller.updateBio(v);
              controller.cvDescription.value = v;
            },
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
        Obx(() {
          // استخدام قائمة موحدة للعرض
          final List<String> displayImages =
              controller.cvCertificates.isNotEmpty
              ? controller.cvCertificates.toList()
              : controller.certificateImages.toList();

          return Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              for (int i = 0; i < displayImages.length; i++)
                Stack(
                  children: [
                    Container(
                      width: 160.w,
                      height: 110.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.r),
                        image: DecorationImage(
                          image: _imageProvider(displayImages[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: InkWell(
                        onTap: () {
                          // حذف من القائمة المناسبة
                          if (controller.cvCertificates.isNotEmpty) {
                            controller.cvCertificates.removeAt(i);
                          } else {
                            controller.removeCertificateAt(i);
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.delete_forever,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              _addCertificateButton(controller),
            ],
          );
        }),
        SizedBox(height: 16.h),
        Obx(() {
          // يظهر زر الإضافة فقط إذا لم يكن هناك cvId (لم يتم الحفظ في API)
          final bool isSavedInApi = controller.cvId.value.isNotEmpty;

          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.toggleBioExpansion(),
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
              SizedBox(width: 12.w),
              // زر الإضافة: يظهر فقط إذا لم تكن السيرة محفوظة في API
              if (!isSavedInApi)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // استخدام القائمة الصحيحة
                      final certs = controller.cvCertificates.isNotEmpty
                          ? controller.cvCertificates.toList()
                          : controller.certificateImages.toList();
                      final res = await controller.saveMyCv(
                        description: controller.cvDescription.value,
                        certificates: certs,
                      );
                      if (res['ok'] == true) {
                        controller.updateBio(controller.cvDescription.value);
                        Get.snackbar(
                          'تمت الإضافة',
                          'تم إضافة السيرة الذاتية بنجاح',
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      } else {
                        Get.snackbar(
                          'فشل الإضافة',
                          (res['data']?['message']?.toString() ??
                              'تعذر إضافة السيرة'),
                          backgroundColor: const Color(0xFFFF3B30),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      elevation: 0,
                    ),
                    child: MyText(
                      'إضافة',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              // أزرار التعديل والحذف: تظهر فقط إذا كانت السيرة محفوظة في API
              if (isSavedInApi) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // استخدام القائمة الصحيحة (cvCertificates عند التعديل)
                      final certs = controller.cvCertificates.isNotEmpty
                          ? controller.cvCertificates.toList()
                          : controller.certificateImages.toList();
                      final res = await controller.saveMyCv(
                        description: controller.cvDescription.value,
                        certificates: certs,
                      );
                      if (res['ok'] == true) {
                        controller.updateBio(controller.cvDescription.value);
                        Get.snackbar(
                          'تم الحفظ',
                          'تم تعديل السيرة الذاتية',
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      } else {
                        Get.snackbar(
                          'فشل التعديل',
                          (res['data']?['message']?.toString() ??
                              'تعذر حفظ السيرة'),
                          backgroundColor: const Color(0xFFFF3B30),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      }
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
                      'تعديل',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final res = await controller.deleteMyCv();
                      if (res['ok'] == true) {
                        controller.updateBio('');
                        controller.certificateImages.clear();
                        Get.snackbar(
                          'تم الحذف',
                          'تم حذف السيرة الذاتية',
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      } else {
                        Get.snackbar(
                          'فشل الحذف',
                          (res['data']?['message']?.toString() ??
                              'تعذر حذف السيرة'),
                          backgroundColor: const Color(0xFFFF3B30),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF3B30)),
                      foregroundColor: const Color(0xFFFF3B30),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    child: MyText(
                      'حذف',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF3B30),
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
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
        if (picked == null) return;
        await LoadingDialog.show(message: 'جاري رفع الصورة...');
        try {
          final upload = UploadService();
          final res = await upload.uploadImage(File(picked.path));
          LoadingDialog.hide();
          if (res['ok'] == true) {
            final url = (res['data']?['data']?['url']?.toString() ?? '');
            if (url.isNotEmpty) {
              controller.addCertificate(url);
              await showStatusDialog(
                title: 'تم الرفع',
                message: res['message']?.toString().isNotEmpty == true
                    ? res['message'] as String
                    : 'تم رفع الصورة بنجاح',
                color: AppColors.primary,
                icon: Icons.check_circle_outline,
              );
            } else {
              await showStatusDialog(
                title: 'فشل الرفع',
                message: 'تعذر الحصول على الرابط من الخادم',
                color: const Color(0xFFFF3B30),
                icon: Icons.error_outline,
              );
            }
          } else {
            await showStatusDialog(
              title: 'فشل الرفع',
              message: (res['message']?.toString().isNotEmpty == true)
                  ? res['message'] as String
                  : 'يرجى المحاولة لاحقاً',
              color: const Color(0xFFFF3B30),
              icon: Icons.error_outline,
            );
          }
        } catch (_) {
          LoadingDialog.hide();
          await showStatusDialog(
            title: 'خطأ',
            message: 'حدث خطأ أثناء رفع الصورة',
            color: const Color(0xFFFF3B30),
            icon: Icons.error_outline,
          );
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
    final TextEditingController addressCtrl = TextEditingController();

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
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
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
              child: _addressEditContent(controller, addressCtrl),
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
            onTap: () async {
              controller.toggleOpinionsExpansion();
              if (controller.isOpinionsExpanded.value) {
                await controller.loadMyOpinions();
              }
            },
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
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
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

  // Pricing manage tile
  Widget _pricingManageTile() {
    final controller = Get.find<DoctorProfileController>();
    final TextEditingController priceCtrl = TextEditingController();

    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: () {
              controller.toggleInsuranceExpansion();
              // تحميل السعر إلى الحقل عند الفتح
              if (controller.defaultPrice.value > 0) {
                priceCtrl.text = controller.defaultPrice.value.toStringAsFixed(
                  0,
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Row(
                children: [
                  Expanded(
                    child: MyText(
                      'سعر الحجز',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: controller.isInsuranceExpanded.value ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: controller.isInsuranceExpanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: _pricingEditContent(controller, priceCtrl),
            ),
          ),
          Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }

  Widget _pricingEditContent(
    DoctorProfileController controller,
    TextEditingController priceCtrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MyText(
          'حدد سعر الحجز للمرضى',
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              Obx(
                () => MyText(
                  controller.currency.value,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Expo Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 18.sp,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'أدخل السعر',
                    hintStyle: TextStyle(
                      fontFamily: 'Expo Arabic',
                      color: AppColors.textLight,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Icon(Icons.attach_money, color: AppColors.primary, size: 24.r),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 56.h,
          child: ElevatedButton(
            onPressed: () async {
              final text = priceCtrl.text.trim();
              if (text.isEmpty) {
                Get.snackbar(
                  'خطأ',
                  'يرجى إدخال السعر',
                  backgroundColor: const Color(0xFFFF3B30),
                  colorText: Colors.white,
                );
                return;
              }
              final double? price = double.tryParse(text);
              if (price == null || price <= 0) {
                Get.snackbar(
                  'خطأ',
                  'يرجى إدخال سعر صحيح',
                  backgroundColor: const Color(0xFFFF3B30),
                  colorText: Colors.white,
                );
                return;
              }
              final session = Get.find<SessionController>();
              final String? userId = session.currentUser.value?.id;
              if (userId == null || userId.isEmpty) {
                Get.snackbar(
                  'خطأ',
                  'يرجى تسجيل الدخول',
                  backgroundColor: const Color(0xFFFF3B30),
                  colorText: Colors.white,
                );
                return;
              }
              await LoadingDialog.show(message: 'جاري الحفظ...');
              try {
                final res = await controller.saveOrUpdatePricing(
                  doctorId: userId,
                  price: price,
                  curr: controller.currency.value,
                );
                LoadingDialog.hide();
                if (res['ok'] == true) {
                  await showStatusDialog(
                    title: 'تم الحفظ',
                    message: 'تم حفظ سعر الحجز بنجاح',
                    color: AppColors.primary,
                    icon: Icons.check_circle_outline,
                  );
                } else {
                  await showStatusDialog(
                    title: 'فشل الحفظ',
                    message:
                        res['data']?['message']?.toString() ?? 'تعذر حفظ السعر',
                    color: const Color(0xFFFF3B30),
                    icon: Icons.error_outline,
                  );
                }
              } catch (e) {
                LoadingDialog.hide();
                await showStatusDialog(
                  title: 'خطأ',
                  message: 'حدث خطأ غير متوقع',
                  color: const Color(0xFFFF3B30),
                  icon: Icons.error_outline,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
            child: MyText(
              'حفظ السعر',
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _addressEditContent(
    DoctorProfileController controller,
    TextEditingController addressCtrl,
  ) {
    // تحميل العنوان الحالي عند فتح القسم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Get.find<SessionController>().currentUser.value;
      if (user != null && user.address.isNotEmpty) {
        addressCtrl.text = user.address;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MyText(
          'أدخل عنوانك',
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: TextField(
            controller: addressCtrl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'أدخل عنوانك هنا...',
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 50.h,
          child: ElevatedButton(
            onPressed: () async {
              if (addressCtrl.text.trim().isEmpty) {
                Get.snackbar('خطأ', 'يرجى إدخال العنوان');
                return;
              }

              LoadingDialog.show(message: 'جاري تحديث العنوان...');

              final result = await controller.updateDoctorAddress(
                addressCtrl.text.trim(),
              );

              LoadingDialog.hide();

              if (result['ok'] == true) {
                Get.snackbar('نجح', 'تم تحديث العنوان بنجاح');
                controller.toggleAddressExpansion();
              } else {
                Get.snackbar(
                  'خطأ',
                  result['message'] ?? 'فشل في تحديث العنوان',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
            child: MyText(
              'حفظ العنوان',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
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
                          '( ${_formatRelative(dateStr)} )',
                          fontSize: 14.sp,
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

  ImageProvider _imageProvider(String path) {
    final p = path.trim();
    // Network URL
    if (p.startsWith('http://') || p.startsWith('https://')) {
      final host = Uri.tryParse(p)?.host.toLowerCase() ?? '';
      // Avoid providers that often block hotlinking (403), show local placeholder instead
      if (host.contains('scontent') ||
          host.contains('fbcdn') ||
          host.contains('facebook.com')) {
        return const AssetImage('assets/icons/home/doctor.png');
      }
      // Handle URLs with special characters by encoding them properly
      try {
        final uri = Uri.parse(p);
        final encodedUrl = uri.toString();
        return NetworkImage(encodedUrl);
      } catch (_) {
        // If URL parsing fails, try manual encoding of the path part
        try {
          final parts = p.split('/');
          if (parts.length > 3) {
            final baseParts = parts.take(parts.length - 1).join('/');
            final fileName = Uri.encodeComponent(parts.last);
            final encodedUrl = '$baseParts/$fileName';
            return NetworkImage(encodedUrl);
          }
        } catch (_) {}
        return const AssetImage('assets/icons/home/doctor.png');
      }
    }
    // Local file (Unix or Windows)
    final isWindowsDrive = RegExp(r'^[A-Za-z]:\\').hasMatch(p);
    if (p.startsWith('/') || p.contains('\\') || isWindowsDrive) {
      return FileImage(File(p));
    }
    // Asset path
    return AssetImage(p);
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
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
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
        case 'full':
          return const Color(0xFFE3F5ED); // light green - الحجز ممتلأ
        case 'available':
          return const Color(0xFFEFF3F8); // light gray - الحجز متاح
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
            // Use Obx for each day to track individual status changes
            return Obx(() {
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
            });
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
                legendDot(const Color(0xFFEFF3F8)), // رمادي - available
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
                legendDot(const Color(0xFFE3F5ED)), // أخضر - full
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

  // Cases manage tile (treated cases)
  Widget _casesManageTile() {
    final controller = Get.find<DoctorProfileController>();
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: () async {
              controller.toggleCasesExpansion();
              // جلب الحالات عند فتح القسم
              if (controller.isCasesExpanded.value) {
                final session = Get.find<SessionController>();
                final userId = session.currentUser.value?.id;
                if (userId != null && userId.isNotEmpty) {
                  await controller.loadDoctorCases(userId);
                }
              }
            },
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
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
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
    // Controllers للنموذج
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final RxString visibility = 'public'.obs;
    final RxList<String> caseImages = <String>[].obs;

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form: Add new case
          MyText(
            'إضافة حالة جديدة',
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8.h),
          // Title
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.divider),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: TextField(
              controller: titleCtrl,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'عنوان الحالة',
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'Expo Arabic',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Description
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.divider),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: TextField(
              controller: descCtrl,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'وصف الحالة',
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'Expo Arabic',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Visibility toggle
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => visibility.value = 'public',
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: visibility.value == 'public'
                            ? AppColors.primary
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: visibility.value == 'public'
                              ? AppColors.primary
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.public,
                            color: visibility.value == 'public'
                                ? Colors.white
                                : Colors.grey[600],
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          MyText(
                            'عام',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: visibility.value == 'public'
                                ? Colors.white
                                : Colors.grey[600]!,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => visibility.value = 'private',
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: visibility.value == 'private'
                            ? AppColors.primary
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: visibility.value == 'private'
                              ? AppColors.primary
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            color: visibility.value == 'private'
                                ? Colors.white
                                : Colors.grey[600],
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          MyText(
                            'خاص',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: visibility.value == 'private'
                                ? Colors.white
                                : Colors.grey[600]!,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Images section
          Obx(
            () => Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                for (int i = 0; i < caseImages.length; i++)
                  Stack(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: Colors.grey[200],
                          image: DecorationImage(
                            image: _imageProvider(caseImages[i]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => caseImages.removeAt(i),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                // Add image button
                InkWell(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (picked == null) return;
                    await LoadingDialog.show(message: 'جاري رفع الصورة...');
                    try {
                      final upload = UploadService();
                      final res = await upload.uploadImage(File(picked.path));
                      LoadingDialog.hide();
                      if (res['ok'] == true) {
                        final url =
                            (res['data']?['data']?['url']?.toString() ?? '');
                        if (url.isNotEmpty) {
                          caseImages.add(url);
                        }
                      }
                    } catch (_) {
                      LoadingDialog.hide();
                    }
                  },
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: AppColors.primary),
                        MyText(
                          'إضافة صورة',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty ||
                    descCtrl.text.trim().isEmpty) {
                  await showStatusDialog(
                    title: 'خطأ',
                    message: 'يرجى ملء جميع الحقول',
                    color: const Color(0xFFFF3B30),
                    icon: Icons.error_outline,
                  );
                  return;
                }
                await LoadingDialog.show(message: 'جاري إضافة الحالة...');
                try {
                  final res = await controller.createNewCase(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    visibility: visibility.value,
                    images: caseImages.toList(),
                  );
                  LoadingDialog.hide();
                  if (res['ok'] == true) {
                    titleCtrl.clear();
                    descCtrl.clear();
                    caseImages.clear();
                    visibility.value = 'public';
                    await showStatusDialog(
                      title: 'تمت الإضافة',
                      message: 'تم إضافة الحالة بنجاح',
                      color: AppColors.primary,
                      icon: Icons.check_circle_outline,
                    );
                  } else {
                    await showStatusDialog(
                      title: 'فشل الإضافة',
                      message:
                          (res['data']?['message']?.toString() ??
                          'تعذر إضافة الحالة'),
                      color: const Color(0xFFFF3B30),
                      icon: Icons.error_outline,
                    );
                  }
                } catch (_) {
                  LoadingDialog.hide();
                  await showStatusDialog(
                    title: 'خطأ',
                    message: 'حدث خطأ أثناء إضافة الحالة',
                    color: const Color(0xFFFF3B30),
                    icon: Icons.error_outline,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
          if (controller.isLoadingCases.value)
            Skeletonizer(
              enabled: true,
              child: Column(
                children: List.generate(
                  3,
                  (_) => Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      leading: Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      title: MyText(
                        ' ',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      subtitle: MyText(
                        ' ',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else if (controller.apiCases.isEmpty)
            MyText(
              'لا توجد حالات بعد',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              textAlign: TextAlign.right,
            )
          else
            ...controller.apiCases.map((caseData) {
              final images = (caseData['images'] as List<dynamic>?) ?? [];
              final firstImage = images.isNotEmpty
                  ? images.first.toString()
                  : '';

              return Card(
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  leading: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.r),
                      image: firstImage.isNotEmpty
                          ? DecorationImage(
                              image: _imageProvider(firstImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: firstImage.isEmpty
                        ? const Icon(
                            Icons.image,
                            color: AppColors.textSecondary,
                            size: 20,
                          )
                        : null,
                  ),
                  title: MyText(
                    caseData['title']?.toString() ?? '',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.right,
                  ),
                  subtitle: MyText(
                    caseData['description']?.toString() ?? '',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                  ),
                  trailing: IconButton(
                    tooltip: 'حذف',
                    icon: const Icon(Icons.delete, color: Color(0xFFFF3B30)),
                    onPressed: () async {
                      final caseId = caseData['_id']?.toString() ?? '';
                      if (caseId.isEmpty) return;

                      final confirmed = await showDeleteCaseConfirmDialog(
                        Get.context!,
                      );
                      if (!confirmed) return;

                      await LoadingDialog.show(message: 'جاري الحذف...');
                      try {
                        final res = await controller.deleteCase(caseId);
                        LoadingDialog.hide();
                        if (res['ok'] == true) {
                          await showStatusDialog(
                            title: 'تم الحذف',
                            message: 'تم حذف الحالة بنجاح',
                            color: AppColors.primary,
                            icon: Icons.check_circle_outline,
                          );
                        } else {
                          // التعامل مع رسائل الخطأ المختلفة
                          String errorMessage =
                              res['data']?['message']?.toString() ??
                              'تعذر حذف الحالة';

                          // تحديد العنوان بناءً على نوع الخطأ
                          String errorTitle = 'فشل الحذف';
                          if (errorMessage.contains('غير مصرح') ||
                              errorMessage.contains('not authorized') ||
                              errorMessage.contains('Unauthorized')) {
                            errorTitle = 'غير مصرح لك';
                            errorMessage = 'ليس لديك صلاحية حذف هذه الحالة';
                          }

                          await showStatusDialog(
                            title: errorTitle,
                            message: errorMessage,
                            color: const Color(0xFFFF3B30),
                            icon: Icons.error_outline,
                          );
                        }
                      } catch (_) {
                        LoadingDialog.hide();
                        await showStatusDialog(
                          title: 'خطأ',
                          message: 'حدث خطأ أثناء حذف الحالة',
                          color: const Color(0xFFFF3B30),
                          icon: Icons.error_outline,
                        );
                      }
                    },
                  ),
                ),
              );
            }),
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

  Widget _cityDropdown() {
    final manageController = Get.find<DoctorProfileManageController>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(
        () => DropdownButtonFormField<String>(
          value: manageController.selectedCity.value,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'اختر المحافظة',
            hintStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16.sp,
              fontFamily: 'Expo Arabic',
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.textLight, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.primary, width: 1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.textLight, width: 1),
            ),
          ),
          items: manageController.allowedCities.map((city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(
                city,
                style: TextStyle(fontSize: 16.sp, fontFamily: 'Expo Arabic'),
                textAlign: TextAlign.right,
              ),
            );
          }).toList(),
          onChanged: (value) {
            manageController.selectedCity.value = value;
            manageController.cityPersonalCtrl.text = value ?? '';
          },
        ),
      ),
    );
  }

  Widget _specializationDropdown() {
    final manageController = Get.find<DoctorProfileManageController>();
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Obx(
            () => DropdownButtonFormField<String>(
              value: manageController.selectedSpecializationId.value,
              decoration: InputDecoration(
                hintText: manageController.loadingSpecializations.value
                    ? 'جاري التحميل...'
                    : manageController.specializations.isEmpty
                    ? 'لا توجد اختصاصات'
                    : 'اختر الاختصاص',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                  fontFamily: 'Expo Arabic',
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: AppColors.textLight, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: AppColors.textLight, width: 1),
                ),
              ),
              isExpanded: true,
              items: manageController.specializations.map((spec) {
                return DropdownMenuItem<String>(
                  value: spec.id,
                  child: Text(
                    spec.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'Expo Arabic',
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              }).toList(),
              onChanged:
                  manageController.loadingSpecializations.value ||
                      manageController.specializations.isEmpty
                  ? null
                  : (value) {
                      manageController.selectedSpecializationId.value = value;
                    },
            ),
          ),
        ),
        Obx(() {
          if (manageController.specializations.isEmpty &&
              !manageController.loadingSpecializations.value) {
            return Column(
              children: [
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () => manageController.fetchSpecializations(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.primary, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          color: AppColors.primary,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        MyText(
                          'إعادة المحاولة',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
