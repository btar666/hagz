import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../service_layer/services/upload_service.dart';
import '../service_layer/services/user_service.dart';
import '../service_layer/services/specialization_service.dart';
import '../model/specialization_model.dart';
import '../widget/loading_dialog.dart';
import '../widget/status_dialog.dart';
import '../utils/app_colors.dart';
import 'session_controller.dart';

class DoctorProfileManageController extends GetxController {
  // Personal info controllers
  final namePersonalCtrl = TextEditingController();
  final phonePersonalCtrl = TextEditingController();
  final cityPersonalCtrl = TextEditingController();
  final agePersonalCtrl = TextEditingController();
  final genderPersonalIndex = 0.obs;

  // Social media controllers
  final instagramCtrl = TextEditingController(text: 'http://ABCDEFG');
  final whatsappCtrl = TextEditingController(text: 'http://ABCDEFG');
  final facebookCtrl = TextEditingController();

  // Specialization state
  final specializations = <SpecializationModel>[].obs;
  final selectedSpecializationId = RxnString();
  final loadingSpecializations = false.obs;

  // Cities
  final List<String> allowedCities = const [
    'بغداد',
    'البصرة',
    'نينوى',
    'أربيل',
    'النجف',
    'كربلاء',
    'الأنبار',
    'ديالى',
    'صلاح الدين',
    'واسط',
    'ذي قار',
    'بابل',
    'كركوك',
    'السليمانية',
    'المثنى',
    'القادسية',
    'ميسان',
    'دهوك',
  ];
  final selectedCity = RxnString();

  // Services
  final _specializationService = SpecializationService();
  final _userService = UserService();
  final _uploadService = UploadService();

  // Flags
  final prefillCalled = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSpecializations();
    fetchLatestUserInfo();
  }

  @override
  void onClose() {
    namePersonalCtrl.dispose();
    phonePersonalCtrl.dispose();
    cityPersonalCtrl.dispose();
    agePersonalCtrl.dispose();
    instagramCtrl.dispose();
    whatsappCtrl.dispose();
    facebookCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchLatestUserInfo() async {
    try {
      print('📥 Fetching latest user info for profile page...');
      final res = await _userService.getUserInfo();
      print('📥 User info response: ${res['ok']}');
      if (res['ok'] == true) {
        print('✅ User info updated successfully - image should now be visible');
        // Session will be updated automatically by getUserInfo()
        await prefillPersonalInfo();
        loadExistingSocialMediaData();
      }
    } catch (e) {
      print('❌ Error fetching user info: $e');
    }
  }

  Future<void> prefillPersonalInfo() async {
    final session = Get.find<SessionController>();
    final user = session.currentUser.value;
    if (user != null) {
      if (namePersonalCtrl.text.isEmpty) namePersonalCtrl.text = user.name;
      if (phonePersonalCtrl.text.isEmpty) phonePersonalCtrl.text = user.phone;
      if (cityPersonalCtrl.text.isEmpty) {
        cityPersonalCtrl.text = user.city;
      }
      if (selectedCity.value == null && user.city.isNotEmpty) {
        selectedCity.value = user.city;
      }
      if (agePersonalCtrl.text.isEmpty) {
        agePersonalCtrl.text = (user.age > 0 ? user.age : 18).toString();
      }
      if (selectedSpecializationId.value == null &&
          user.specialization.isNotEmpty) {
        selectedSpecializationId.value = user.specialization;
      }
      final g = user.gender.trim();
      if (g == 'ذكر' || g.toLowerCase() == 'male') {
        genderPersonalIndex.value = 0;
      } else if (g == 'انثى' || g == 'أنثى' || g.toLowerCase() == 'female') {
        genderPersonalIndex.value = 1;
      }
    }
  }

  void loadExistingSocialMediaData() {
    final session = Get.find<SessionController>();
    final user = session.currentUser.value;
    if (user != null && user.socialMedia.isNotEmpty) {
      final social = user.socialMedia;
      instagramCtrl.text = social['instagram'] ?? 'http://ABCDEFG';
      whatsappCtrl.text = social['whatsapp'] ?? 'http://ABCDEFG';
      facebookCtrl.text = social['facebook'] ?? '';
    }
  }

  Future<void> prefillSocialFromApi(String userId) async {
    if (prefillCalled.value) return;
    prefillCalled.value = true;

    try {
      final res = await _userService.getUserById(userId);
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
        if (ig != null && ig.isNotEmpty) instagramCtrl.text = ig;
        if (wa != null && wa.isNotEmpty) whatsappCtrl.text = wa;
        if (fb != null && fb.isNotEmpty) facebookCtrl.text = fb;
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> fetchSpecializations() async {
    final session = Get.find<SessionController>();
    if (session.currentUser.value?.userType != 'Doctor') return;

    loadingSpecializations.value = true;
    try {
      final specs = await _specializationService.getSpecializationsList();
      specializations.value = specs;
    } catch (e) {
      print('❌ Error fetching specializations: $e');
    } finally {
      loadingSpecializations.value = false;
    }
  }

  Future<void> updatePersonalInfo() async {
    final session = Get.find<SessionController>();
    final user = session.currentUser.value;
    if (user == null) return;

    // Validation
    if (namePersonalCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال الاسم',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (phonePersonalCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رقم الهاتف',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedCity.value == null || selectedCity.value!.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى اختيار المحافظة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (agePersonalCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال العمر',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // For doctors, specialization is required
    if (user.userType == 'Doctor' &&
        (selectedSpecializationId.value == null ||
            selectedSpecializationId.value!.isEmpty)) {
      Get.snackbar(
        'خطأ',
        'يرجى اختيار التخصص',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await LoadingDialog.show(message: 'جاري حفظ التعديلات...');

    try {
      final gender = genderPersonalIndex.value == 0 ? 'ذكر' : 'انثى';
      final age = int.tryParse(agePersonalCtrl.text.trim()) ?? 18;

      final res = await _userService.updateUserInfo(
        name: namePersonalCtrl.text.trim(),
        phone: phonePersonalCtrl.text.trim(),
        city: selectedCity.value!,
        age: age,
        gender: gender,
        specializationId: selectedSpecializationId.value ?? '',
        address: '', // Keep existing address
      );

      LoadingDialog.hide();

      if (res['ok'] == true) {
        // Refresh user info
        await _userService.getUserInfo();

        await showStatusDialog(
          title: 'نجح الحفظ',
          message: 'تم حفظ التعديلات بنجاح',
          color: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      } else {
        final errorMsg =
            res['error']?.toString() ??
            res['data']?['message']?.toString() ??
            'حدث خطأ أثناء الحفظ';
        await showStatusDialog(
          title: 'خطأ',
          message: errorMsg,
          color: Colors.red,
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      LoadingDialog.hide();
      await showStatusDialog(
        title: 'خطأ',
        message: 'حدث خطأ غير متوقع: $e',
        color: Colors.red,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> updateSocialMedia() async {
    await LoadingDialog.show(message: 'جاري حفظ وسائل التواصل...');

    try {
      final session = Get.find<SessionController>();
      final userId = session.currentUser.value?.id;

      if (userId == null) {
        LoadingDialog.hide();
        return;
      }

      final res = await _userService.updateSocialMedia(
        instagram: instagramCtrl.text.trim(),
        whatsapp: whatsappCtrl.text.trim(),
        facebook: facebookCtrl.text.trim(),
      );

      LoadingDialog.hide();

      if (res['ok'] == true) {
        await showStatusDialog(
          title: 'نجح الحفظ',
          message: 'تم حفظ وسائل التواصل بنجاح',
          color: AppColors.primary,
          icon: Icons.check_circle_outline,
        );

        // Refresh user info
        await _userService.getUserInfo();
      } else {
        final errorMsg =
            res['error']?.toString() ??
            res['data']?['message']?.toString() ??
            'حدث خطأ أثناء الحفظ';
        await showStatusDialog(
          title: 'خطأ',
          message: errorMsg,
          color: Colors.red,
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      LoadingDialog.hide();
      await showStatusDialog(
        title: 'خطأ',
        message: 'حدث خطأ غير متوقع: $e',
        color: Colors.red,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> uploadProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) return;

      await LoadingDialog.show(message: 'جاري رفع الصورة...');

      final res = await _uploadService.uploadImage(File(picked.path));

      if (res['ok'] == true) {
        final url = (res['data']?['data']?['url']?.toString() ?? '');
        if (url.isNotEmpty) {
          // Update user profile with new image
          final session = Get.find<SessionController>();
          final user = session.currentUser.value;
          if (user != null) {
            final updateRes = await _userService.updateUserInfo(
              name: user.name,
              phone: user.phone,
              city: user.city,
              age: user.age,
              gender: user.gender,
              specializationId: user.specialization,
              image: url,
              address: user.address,
            );

            LoadingDialog.hide();

            if (updateRes['ok'] == true) {
              await showStatusDialog(
                title: 'نجح الرفع',
                message: 'تم تحديث صورة الملف الشخصي بنجاح',
                color: AppColors.primary,
                icon: Icons.check_circle_outline,
              );

              // Refresh user info
              await _userService.getUserInfo();
            }
          }
        }
      } else {
        LoadingDialog.hide();
        await showStatusDialog(
          title: 'خطأ',
          message: 'فشل رفع الصورة',
          color: Colors.red,
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      LoadingDialog.hide();
      await showStatusDialog(
        title: 'خطأ',
        message: 'حدث خطأ: $e',
        color: Colors.red,
        icon: Icons.error_outline,
      );
    }
  }
}
