import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../service_layer/services/upload_service.dart';
import '../service_layer/services/auth_service.dart';
import '../widget/loading_dialog.dart';
import '../widget/status_dialog.dart';
import '../utils/app_colors.dart';
import 'session_controller.dart';
import '../view/main_page.dart';

class DelegateRegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final regionCtrl = TextEditingController(); // المنطقة
  final companyCtrl = TextEditingController();
  final certificateCtrl = TextEditingController();

  var selectedCity = Rxn<String>();
  var selectedAge = Rxn<String>();
  var genderIndex = Rxn<int>(); // 0 = ذكر, 1 = انثى

  var profileImageUrl = Rxn<String>();
  var idFrontImageUrl = Rxn<String>();
  var idBackImageUrl = Rxn<String>();
  var uploadingImage = false.obs;

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

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    cityCtrl.dispose();
    addressCtrl.dispose();
    regionCtrl.dispose();
    companyCtrl.dispose();
    certificateCtrl.dispose();
    super.onClose();
  }

  Future<void> pickAndUploadImage(String type) async {
    try {
      uploadingImage.value = true;
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) {
        uploadingImage.value = false;
        return;
      }

      final upload = UploadService();
      final res = await upload.uploadImage(File(picked.path));

      if (res['ok'] == true) {
        final url = (res['data']?['data']?['url']?.toString() ?? '');
        if (url.isNotEmpty) {
          if (type == 'profile') {
            profileImageUrl.value = url;
          } else if (type == 'idFront') {
            idFrontImageUrl.value = url;
          } else if (type == 'idBack') {
            idBackImageUrl.value = url;
          }
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      uploadingImage.value = false;
    }
  }

  Future<void> registerDelegate() async {
    if (!formKey.currentState!.validate()) return;

    if (genderIndex.value == null) {
      Get.snackbar(
        'خطأ',
        'يرجى اختيار الجنس',
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

    if (selectedAge.value == null || selectedAge.value!.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى اختيار العمر',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await LoadingDialog.show(message: 'جاري التسجيل...');

    try {
      final authService = AuthService();
      final session = Get.find<SessionController>();

      // Prepare registration data
      final registrationData = {
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'gender': genderIndex.value == 0 ? 'ذكر' : 'أنثى',
        'age': int.parse(selectedAge.value!),
        'city': selectedCity.value!,
        'region': regionCtrl.text.trim(), // المنطقة
        'userType': 'Representative',
        'company': companyCtrl.text.trim(),
        'deviceToken': '',
        'image': profileImageUrl.value ?? '',
        'address': addressCtrl.text.trim(),
        'certificate': certificateCtrl.text.trim(),
        'idFrontImage': idFrontImageUrl.value ?? '',
        'idBackImage': idBackImageUrl.value ?? '',
      };

      // Print registration data (without password for security)
      print('📋 ========== DELEGATE REGISTRATION REQUEST ==========');
      print('📋 Name: ${registrationData['name']}');
      print('📋 Phone: ${registrationData['phone']}');
      print('📋 Password: [HIDDEN]');
      print('📋 Gender: ${registrationData['gender']}');
      print('📋 Age: ${registrationData['age']}');
      print('📋 City: ${registrationData['city']}');
      print('📋 Region: ${registrationData['region']}');
      print('📋 UserType: ${registrationData['userType']}');
      print('📋 Company: ${registrationData['company']}');
      print('📋 Address: ${registrationData['address']}');
      print('📋 Certificate: ${registrationData['certificate']}');
      print('📋 Profile Image: ${registrationData['image']}');
      print('📋 ID Front Image: ${registrationData['idFrontImage']}');
      print('📋 ID Back Image: ${registrationData['idBackImage']}');
      print('📋 ===================================================');

      final res = await authService.registerUser(
        name: registrationData['name'] as String,
        phone: registrationData['phone'] as String,
        password: registrationData['password'] as String,
        gender: registrationData['gender'] as String,
        age: registrationData['age'] as int,
        city: registrationData['city'] as String,
        region: registrationData['region'] as String,
        userType: registrationData['userType'] as String,
        company: registrationData['company'] as String,
        deviceToken: registrationData['deviceToken'] as String,
        image: registrationData['image'] as String,
        address: registrationData['address'] as String,
        certificate: registrationData['certificate'] as String,
        idFrontImage: registrationData['idFrontImage'] as String,
        idBackImage: registrationData['idBackImage'] as String,
      );

      // Print API response
      print('📥 ========== DELEGATE REGISTRATION RESPONSE ==========');
      print('📥 Status Code: ${res['statusCode'] ?? 'N/A'}');
      print('📥 OK: ${res['ok']}');
      print('📥 Full Response: ${res.toString()}');
      if (res['data'] != null) {
        print('📥 Response Data: ${res['data']}');
        if (res['data'] is Map) {
          final data = res['data'] as Map;
          print('📥 Status: ${data['status']}');
          print('📥 Code: ${data['code']}');
          print('📥 Message: ${data['message']}');
          if (data['data'] != null) {
            print('📥 Response Data.data: ${data['data']}');
          }
        }
      }
      if (res['error'] != null) {
        print('📥 Error: ${res['error']}');
      }
      print('📥 ===================================================');

      LoadingDialog.hide();

      if (res['ok'] == true) {
        await showStatusDialog(
          title: 'نجح التسجيل',
          message: 'تم تسجيل حسابك بنجاح',
          color: AppColors.primary,
          icon: Icons.check_circle_outline,
        );

        // Update session role to delegate
        session.role.value = 'delegate';

        // Go to main page
        Get.offAll(() => const MainPage());
      } else {
        final errorMsg =
            res['error']?.toString() ??
            res['data']?['message']?.toString() ??
            'حدث خطأ أثناء التسجيل';
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
}
