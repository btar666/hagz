import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../widget/my_text.dart';
import '../view/main_page.dart';
import '../controller/session_controller.dart';
import '../service_layer/services/auth_service.dart';
import '../service_layer/services/device_token_service.dart';
import '../widget/loading_dialog.dart';
import '../widget/status_dialog.dart';

class AuthController extends GetxController {
  final AuthService _auth = AuthService();
  final SessionController _session = Get.find<SessionController>();

  // Login
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final RxBool isLoading = false.obs;

  // Register (User role only for now)
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController regPhoneCtrl = TextEditingController();
  final TextEditingController regPasswordCtrl = TextEditingController();
  final RxString gender = ''.obs; // 'ذكر' | 'انثى'
  final RxInt age = 18.obs; // default

  Future<void> login() async {
    if (_session.role.value != 'user') {
      // keep existing flow for non-user roles
      Get.offAll(() => const MainPage());
      return;
    }
    if (phoneCtrl.text.trim().isEmpty || passwordCtrl.text.trim().isEmpty) {
      _showSnack('يرجى إدخال الهاتف وكلمة المرور');
      return;
    }
    isLoading.value = true;
    await LoadingDialog.show(message: 'جاري تسجيل الدخول...');
    try {
      final res = await _auth.login(
        phone: phoneCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );
      // Print full response for debugging
      // ignore: avoid_print
      print('LOGIN RESPONSE: ${res.toString()}');
      if (res['ok'] == true) {
        LoadingDialog.hide();
        final data = res['data'] as Map<String, dynamic>;
        final token = data['token'] ?? data['data']?['token'];
        _session.setToken(token?.toString());
        Get.offAll(() => const MainPage());
      } else {
        LoadingDialog.hide();
        await showStatusDialog(
          title: 'فشل تسجيل الدخول',
          message:
              res['error']?.toString() ?? 'تحقق من البيانات وحاول مرة أخرى',
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
          buttonText: 'حسناً',
        );
      }
    } catch (e) {
      LoadingDialog.hide();
      await showStatusDialog(
        title: 'خطأ غير متوقع',
        message: 'حدث خطأ، حاول لاحقاً',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
    } finally {
      LoadingDialog.hide();
      isLoading.value = false;
    }
  }

  Future<void> registerUser() async {
    if (_session.role.value != 'user') {
      _showSnack('التسجيل الحالي مخصص لحساب المستخدم فقط');
      return;
    }
    if (nameCtrl.text.trim().isEmpty ||
        regPhoneCtrl.text.trim().isEmpty ||
        regPasswordCtrl.text.trim().isEmpty ||
        gender.value.isEmpty ||
        cityCtrl.text.trim().isEmpty) {
      _showSnack('يرجى إكمال جميع الحقول');
      return;
    }
    isLoading.value = true;
    await LoadingDialog.show(message: 'جاري إنشاء الحساب...');
    try {
      final deviceToken = await DeviceTokenService.getOrCreateToken();
      final res = await _auth.registerUser(
        name: nameCtrl.text.trim(),
        phone: regPhoneCtrl.text.trim(),
        password: regPasswordCtrl.text.trim(),
        gender: gender.value,
        age: age.value,
        city: cityCtrl.text.trim(),
        userType: _session.apiUserType, // 'User'
        specialization: '',
        company: '',
        deviceToken: deviceToken,
      );
      // ignore: avoid_print
      print('REGISTER RESPONSE: ${res.toString()}');
      if (res['ok'] == true) {
        LoadingDialog.hide();
        // optional: auto login if token returned
        final data = res['data'] as Map<String, dynamic>;
        final token = data['token'] ?? data['data']?['token'];
        if (token != null) {
          _session.setToken(token.toString());
        }
        Get.offAll(() => const MainPage());
      } else {
        LoadingDialog.hide();
        await showStatusDialog(
          title: 'فشل إنشاء الحساب',
          message:
              res['error']?.toString() ?? 'تحقق من البيانات وحاول مرة أخرى',
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
          buttonText: 'حسناً',
        );
      }
    } catch (_) {
      LoadingDialog.hide();
      await showStatusDialog(
        title: 'خطأ غير متوقع',
        message: 'حدث خطأ أثناء إنشاء الحساب',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
    } finally {
      LoadingDialog.hide();
      isLoading.value = false;
    }
  }

  void _showSnack(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: MyText(
          message,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        snackStyle: SnackStyle.FLOATING,
        backgroundColor: AppColors.primary,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
