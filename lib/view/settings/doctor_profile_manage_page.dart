import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/specialization_text.dart';
import '../../controller/doctor_profile_controller.dart';
import '../../controller/session_controller.dart';
import '../appointments/appointment_details_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../service_layer/services/upload_service.dart';
import '../../service_layer/services/user_service.dart';
import '../../service_layer/services/specialization_service.dart';
import '../../model/specialization_model.dart';
import '../../widget/loading_dialog.dart';
import '../../widget/status_dialog.dart';
import '../../widget/confirm_dialogs.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorProfileManagePage extends StatefulWidget {
  const DoctorProfileManagePage({super.key});

  @override
  State<DoctorProfileManagePage> createState() =>
      _DoctorProfileManagePageState();
}

class _DoctorProfileManagePageState extends State<DoctorProfileManagePage> {
  static bool _prefillCalled = false;

  // Personal info controllers
  final TextEditingController _namePersonalCtrl = TextEditingController();
  final TextEditingController _phonePersonalCtrl = TextEditingController();
  final TextEditingController _cityPersonalCtrl = TextEditingController();
  final TextEditingController _agePersonalCtrl = TextEditingController();
  final RxInt _genderPersonalIndex = 0.obs;

  // Specialization state
  List<SpecializationModel> _specializations = [];
  String? _selectedSpecializationId;
  bool _loadingSpecializations = false;
  final SpecializationService _specializationService = SpecializationService();

  // Social controllers
  final TextEditingController _instagramCtrl = TextEditingController(
    text: 'http://ABCDEFG',
  );
  final TextEditingController _whatsappCtrl = TextEditingController(
    text: 'http://ABCDEFG',
  );
  final TextEditingController _facebookCtrl = TextEditingController();

  void _loadExistingSocialMediaData(SessionController session) {
    final user = session.currentUser.value;
    if (user != null && user.socialMedia.isNotEmpty) {
      final social = user.socialMedia;
      _instagramCtrl.text = social['instagram'] ?? 'http://ABCDEFG';
      _whatsappCtrl.text = social['whatsapp'] ?? 'http://ABCDEFG';
      _facebookCtrl.text = social['facebook'] ?? '';
    }
  }

  Future<void> _prefillSocialFromApi(String userId) async {
    try {
      final userService = Get.put(UserService());
      final res = await userService.getUserById(userId);
      if (res['ok'] == true) {
        final dynamic wrap = res['data'];
        Map<String, dynamic>? obj;
        if (wrap is Map<String, dynamic>) {
          obj = (wrap['data'] is Map<String, dynamic>)
              ? (wrap['data'] as Map<String, dynamic>)
              : wrap;
        }
        final Map<String, dynamic> social =
            (obj?['socialMedia'] as Map<String, dynamic>?) ?? {};
        final String? ig = social['instagram']?.toString();
        final String? wa = social['whatsapp']?.toString();
        final String? fb = social['facebook']?.toString();
        if (ig != null && ig.isNotEmpty) _instagramCtrl.text = ig;
        if (wa != null && wa.isNotEmpty) _whatsappCtrl.text = wa;
        if (fb != null && fb.isNotEmpty) _facebookCtrl.text = fb;
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSpecializations();
    _fetchLatestUserInfo();
  }

  Future<void> _fetchLatestUserInfo() async {
    try {
      final userService = Get.put(UserService());
      print('📥 Fetching latest user info for profile page...');
      final res = await userService.getUserInfo();
      print('📥 User info response: ${res['ok']}');
      if (res['ok'] == true) {
        print('✅ User info updated successfully - image should now be visible');
        // Session will be updated automatically by getUserInfo()
      }
    } catch (e) {
      print('❌ Error fetching user info: $e');
    }
  }

  @override
  void dispose() {
    _namePersonalCtrl.dispose();
    _phonePersonalCtrl.dispose();
    _cityPersonalCtrl.dispose();
    _agePersonalCtrl.dispose();
    _instagramCtrl.dispose();
    _whatsappCtrl.dispose();
    _facebookCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchSpecializations() async {
    final session = Get.find<SessionController>();
    if (session.currentUser.value?.userType != 'Doctor') return;

    setState(() => _loadingSpecializations = true);
    try {
      final specializations = await _specializationService
          .getSpecializationsList();
      if (mounted) {
        setState(() {
          _specializations = specializations;
          _loadingSpecializations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSpecializations = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
    }

    // Load existing social media data from user profile
    _loadExistingSocialMediaData(session);

    // Prefill personal info from session
    final user = session.currentUser.value;
    if (user != null) {
      if (_namePersonalCtrl.text.isEmpty) _namePersonalCtrl.text = user.name;
      if (_phonePersonalCtrl.text.isEmpty) _phonePersonalCtrl.text = user.phone;
      if (_cityPersonalCtrl.text.isEmpty) _cityPersonalCtrl.text = user.city;
      if (_agePersonalCtrl.text.isEmpty)
        _agePersonalCtrl.text = (user.age > 0 ? user.age : 18).toString();
      if (_selectedSpecializationId == null && user.specialization.isNotEmpty) {
        _selectedSpecializationId = user.specialization;
      }
      final g = user.gender.trim();
      if (g == 'ذكر' || g.toLowerCase() == 'male') {
        _genderPersonalIndex.value = 0;
      } else if (g == 'انثى' || g == 'أنثى' || g.toLowerCase() == 'female') {
        _genderPersonalIndex.value = 1;
      }
    }

    if (!_prefillCalled && userId != null && userId.isNotEmpty) {
      _prefillCalled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefillSocialFromApi(userId);
      });
    }

    return Scaffold(
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
                      onTap: _changeProfileImage,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _socialIconImage(
                'assets/icons/home/instgram.png',
                const Color(0xFFE4405F),
                onTap: () => _openUrlIfAny(
                  _instagramCtrl.text,
                  fallbackHost: 'instagram.com',
                ),
              ),
              _socialIconImage(
                'assets/icons/home/watsapp.png',
                const Color(0xFF25D366),
                onTap: () => _openWhatsapp(_whatsappCtrl.text),
              ),
              _socialIconImage(
                'assets/icons/home/facebook.png',
                const Color(0xFF1877F2),
                onTap: () => _openUrlIfAny(
                  _facebookCtrl.text,
                  fallbackHost: 'facebook.com',
                ),
              ),
            ],
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
          _plainRow(
            _facebookCtrl,
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
                    final session = Get.find<SessionController>();
                    final String? token = session.token.value;
                    if (token == null || token.isEmpty) {
                      Get.snackbar(
                        'غير مسجل',
                        'يرجى تسجيل الدخول أولاً',
                        backgroundColor: const Color(0xFFFF3B30),
                        colorText: Colors.white,
                      );
                      return;
                    }

                    await LoadingDialog.show(message: 'جاري الحفظ...');
                    try {
                      final userService = Get.put(UserService());
                      final res = await userService.updateSocialMedia(
                        instagram: _instagramCtrl.text.trim(),
                        whatsapp: _whatsappCtrl.text.trim(),
                        facebook: _facebookCtrl.text.trim(),
                      );
                      LoadingDialog.hide();
                      if (res['ok'] == true) {
                        controller.toggleEditingSocial();
                        await showStatusDialog(
                          title: 'تم الحفظ',
                          message: 'تم تحديث وسائل التواصل بنجاح',
                          color: AppColors.primary,
                          icon: Icons.check_circle_outline,
                        );
                      } else {
                        await showStatusDialog(
                          title: 'فشل الحفظ',
                          message:
                              res['data']?['message']?.toString() ??
                              'تعذر تحديث البيانات',
                          color: const Color(0xFFFF3B30),
                          icon: Icons.error_outline,
                        );
                      }
                    } catch (e) {
                      LoadingDialog.hide();
                      await showStatusDialog(
                        title: 'خطأ',
                        message: 'حدث خطأ غير متوقع: $e',
                        color: const Color(0xFFFF3B30),
                        icon: Icons.error_outline,
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
        border: Border.all(color: AppColors.textLight),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
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
          _plainRow(_namePersonalCtrl, hint: 'الاسم الكامل'),
          SizedBox(height: 12.h),
          _plainRow(
            _phonePersonalCtrl,
            hint: 'رقم الهاتف',
            trailingAsset: 'assets/icons/home/phone.png',
          ),
          SizedBox(height: 12.h),
          // Gender selector
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final sel = _genderPersonalIndex.value == 0;
                  return OutlinedButton(
                    onPressed: () => _genderPersonalIndex.value = 0,
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
                  final sel = _genderPersonalIndex.value == 1;
                  return OutlinedButton(
                    onPressed: () => _genderPersonalIndex.value = 1,
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
                      'انثى',
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
          _plainRow(
            _agePersonalCtrl,
            hint: 'العمر',
            trailingAsset: 'assets/icons/home/link.png',
          ),
          SizedBox(height: 12.h),
          _plainRow(
            _cityPersonalCtrl,
            hint: 'المدينة',
            trailingAsset: 'assets/icons/home/link.png',
          ),
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
                    final name = _namePersonalCtrl.text.trim();
                    final phone = _phonePersonalCtrl.text.trim();
                    final city = _cityPersonalCtrl.text.trim();
                    final ageText = _agePersonalCtrl.text.trim();
                    if (name.isEmpty ||
                        phone.isEmpty ||
                        city.isEmpty ||
                        ageText.isEmpty) {
                      Get.snackbar(
                        'خطأ',
                        'يرجى تعبئة الحقول المطلوبة',
                        backgroundColor: const Color(0xFFFF3B30),
                        colorText: Colors.white,
                      );
                      return;
                    }
                    final age = int.tryParse(ageText) ?? 0;
                    final gender = _genderPersonalIndex.value == 0
                        ? 'ذكر'
                        : 'انثى';
                    await LoadingDialog.show(message: 'جاري الحفظ...');
                    try {
                      print('🔄 Updating user info...');
                      print('📝 Name: $name');
                      print('📞 Phone: $phone');
                      print('🏙️ City: $city');
                      print('👤 Gender: $gender');
                      print('🎂 Age: $age');
                      print('🏥 Specialization ID: $_selectedSpecializationId');

                      final userService = Get.put(UserService());
                      final res = await userService.updateUserInfo(
                        name: name,
                        city: city,
                        phone: phone,
                        gender: gender,
                        age: age,
                        specializationId: _selectedSpecializationId,
                      );

                      print('📥 UPDATE USER INFO RESPONSE:');
                      print('Response: $res');
                      print('res[ok]: ${res['ok']}');
                      print('res[data]: ${res['data']}');

                      LoadingDialog.hide();
                      if (res['ok'] == true) {
                        print('✅ Update successful!');
                        controller.toggleEditingPersonal();

                        // Update session model with data from server
                        final session = Get.find<SessionController>();
                        final current = session.currentUser.value;
                        print(
                          '👤 Current user before update: ${current?.toJson()}',
                        );

                        // Extract user data from server response
                        final responseData = res['data'];
                        final userData =
                            (responseData is Map &&
                                responseData['data'] != null)
                            ? responseData['data'] as Map<String, dynamic>
                            : null;

                        print('📦 Server returned user data: $userData');

                        if (current != null && userData != null) {
                          final serverSpecialization =
                              userData['specialization']?.toString();

                          // Check if server accepted the specialization update
                          if (_selectedSpecializationId != null &&
                              serverSpecialization != null &&
                              _selectedSpecializationId !=
                                  serverSpecialization) {
                            print(
                              '⚠️ WARNING: Specialization NOT updated by server!',
                            );
                            print('   Sent: $_selectedSpecializationId');
                            print('   Received: $serverSpecialization');
                          }

                          // Update with data from server response
                          final updatedUser = current.copyWith(
                            name: userData['name']?.toString() ?? name,
                            phone:
                                phone, // Phone not in response, use our value
                            gender: userData['gender']?.toString() ?? gender,
                            age: userData['age'] as int? ?? age,
                            city: userData['city']?.toString() ?? city,
                            specialization:
                                serverSpecialization ?? current.specialization,
                            image:
                                userData['image']?.toString() ?? current.image,
                          );
                          print(
                            '👤 Updated user from server: ${updatedUser.toJson()}',
                          );
                          session.setCurrentUser(updatedUser);

                          // Update the selected specialization to match server
                          setState(() {
                            _selectedSpecializationId = serverSpecialization;
                          });
                        } else if (current != null) {
                          // Fallback: use our sent data
                          final updatedUser = current.copyWith(
                            name: name,
                            phone: phone,
                            gender: gender,
                            age: age,
                            city: city,
                            specialization:
                                _selectedSpecializationId ??
                                current.specialization,
                          );
                          print(
                            '👤 Updated user (fallback): ${updatedUser.toJson()}',
                          );
                          session.setCurrentUser(updatedUser);
                        }
                        await showStatusDialog(
                          title: 'تم الحفظ',
                          message: 'تم تحديث المعلومات الشخصية بنجاح',
                          color: AppColors.primary,
                          icon: Icons.check_circle_outline,
                        );
                      } else {
                        print('❌ Update failed!');
                        print('Error message: ${res['data']?['message']}');
                        await showStatusDialog(
                          title: 'فشل الحفظ',
                          message:
                              res['data']?['message']?.toString() ??
                              'تعذر تحديث البيانات',
                          color: const Color(0xFFFF3B30),
                          icon: Icons.error_outline,
                        );
                      }
                    } catch (e) {
                      LoadingDialog.hide();
                      await showStatusDialog(
                        title: 'خطأ',
                        message: 'حدث خطأ غير متوقع: $e',
                        color: const Color(0xFFFF3B30),
                        icon: Icons.error_outline,
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

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

  Future<void> _changeProfileImage() async {
    await LoadingDialog.show(message: 'جاري رفع الصورة...');
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (x == null) {
        LoadingDialog.hide();
        return;
      }
      final upload = UploadService();
      final res = await upload.uploadImage(File(x.path));
      if (res['ok'] == true) {
        final url = (res['data']?['data']?['url']?.toString() ?? '');
        if (url.isNotEmpty) {
          final service = Get.put(UserService());
          final update = await service.updateProfileImage(url);
          LoadingDialog.hide();
          if (update['ok'] == true) {
            final session = Get.find<SessionController>();
            final current = session.currentUser.value;
            if (current != null) {
              session.setCurrentUser(current.copyWith(image: url));
            }
            await showStatusDialog(
              title: 'تم التحديث',
              message: 'تم تحديث صورتك الشخصية',
              color: AppColors.primary,
              icon: Icons.check_circle_outline,
            );
          } else {
            await showStatusDialog(
              title: 'فشل التحديث',
              message:
                  update['data']?['message']?.toString() ?? 'تعذر تحديث الصورة',
              color: const Color(0xFFFF3B30),
              icon: Icons.error_outline,
            );
          }
        } else {
          LoadingDialog.hide();
          await showStatusDialog(
            title: 'فشل الرفع',
            message: 'تعذر الحصول على الرابط من الخادم',
            color: const Color(0xFFFF3B30),
            icon: Icons.error_outline,
          );
        }
      } else {
        LoadingDialog.hide();
        await showStatusDialog(
          title: 'فشل الرفع',
          message: res['message']?.toString().isNotEmpty == true
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
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            MyText(
                              time,
                              fontSize: 18.sp,
                              color: AppColors.textSecondary,
                            ),
                            dot(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.6,
                              ),
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

  Widget _specializationDropdown() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedSpecializationId,
            decoration: InputDecoration(
              hintText: _loadingSpecializations
                  ? 'جاري التحميل...'
                  : _specializations.isEmpty
                  ? 'لا توجد اختصاصات'
                  : 'اختر الاختصاص',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16.sp,
                fontFamily: 'Expo Arabic',
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            isExpanded: true,
            items: _specializations.map((spec) {
              return DropdownMenuItem<String>(
                value: spec.id,
                child: Text(
                  spec.name,
                  style: TextStyle(fontSize: 16.sp, fontFamily: 'Expo Arabic'),
                  textAlign: TextAlign.right,
                ),
              );
            }).toList(),
            onChanged: _loadingSpecializations || _specializations.isEmpty
                ? null
                : (value) {
                    setState(() {
                      _selectedSpecializationId = value;
                    });
                  },
          ),
        ),
        if (_specializations.isEmpty && !_loadingSpecializations) ...[
          SizedBox(height: 8.h),
          InkWell(
            onTap: _fetchSpecializations,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: AppColors.primary, size: 16.sp),
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
      ],
    );
  }
}
