import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../widget/my_text.dart';
import '../view/main_page.dart';
import '../controller/session_controller.dart';
import '../service_layer/services/auth_service.dart';
import '../service_layer/services/user_service.dart';
import '../model/user_model.dart';
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
  final RxBool obscurePassword = true.obs;

  // Register (User role only for now)
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController regPhoneCtrl = TextEditingController();
  final TextEditingController regPasswordCtrl = TextEditingController();
  final TextEditingController specializationCtrl = TextEditingController();
  final RxString specializationId = ''.obs; // ID الاختصاص بدلاً من النص
  final RxString gender = ''.obs; // 'ذكر' | 'انثى'
  final RxInt age = 18.obs; // default
  final RxString imageUrl = ''.obs;

  String _mapApiUserTypeToInternal(String? apiUserType) {
    switch (apiUserType) {
      case 'User':
        return 'user';
      case 'Doctor':
        return 'doctor';
      case 'Secretary':
        return 'secretary';
      case 'Representative':
      case 'Delegate':
        return 'delegate';
      default:
        return '';
    }
  }

  Future<void> login() async {
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
        final serverUserType = data['data']?['userType']?.toString();
        final internalType = _mapApiUserTypeToInternal(serverUserType);

        if (internalType.isNotEmpty && internalType != _session.role.value) {
          await showStatusDialog(
            title: 'لا يوجد حساب بهذه المعلومات',
            message:
                'نوع المستخدم المختار لا يطابق نوع الحساب. الرجاء اختيار النوع الصحيح أو استخدام بيانات الحساب المطابقة.',
            color: const Color(0xFFFF3B30),
            icon: Icons.error_outline,
            buttonText: 'حسناً',
          );
          return;
        }
        // Persist token and user model if available
        _session.setToken(token?.toString());
        try {
          // Many APIs return the user data either at root or in data.data.user
          final Map<String, dynamic> userJson =
              (data['user'] as Map<String, dynamic>?) ??
              (data['data']?['user'] as Map<String, dynamic>?) ??
              (data['data'] as Map<String, dynamic>?) ??
              data;
          final user = UserModel.fromJson(userJson);
          _session.setCurrentUser(user);

          // Fetch complete user info to get associatedDoctor for secretaries
          print('🔄 Fetching complete user info after login...');
          final userService = Get.put(UserService());
          await userService.getUserInfo();
        } catch (_) {
          // ignore parse errors silently
        }
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
    if (_session.role.value == 'doctor' && specializationId.value.isEmpty) {
      _showSnack('يرجى اختيار الاختصاص للطبيب');
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
        userType: _session.apiUserType, // 'User' | 'Doctor'
        specializationId: _session.role.value == 'doctor'
            ? specializationId.value
            : '',
        company: '',
        deviceToken: deviceToken,
        image: imageUrl.value,
      );
      // ignore: avoid_print
      print('REGISTER RESPONSE: ${res.toString()}');
      if (res['ok'] == true) {
        LoadingDialog.hide();
        // optional: auto login if token returned
        final data = res['data'] as Map<String, dynamic>;
        // ignore: avoid_print
        print('REGISTER DATA: $data');
        final token = data['token'] ?? data['data']?['token'];
        final serverUserType = data['data']?['userType']?.toString();
        final internalType = _mapApiUserTypeToInternal(serverUserType);

        if (internalType.isNotEmpty && internalType != _session.role.value) {
          await showStatusDialog(
            title: 'لا يوجد حساب بهذه المعلومات',
            message:
                'نوع المستخدم المختار لا يطابق نوع الحساب. الرجاء اختيار النوع الصحيح أو استخدام بيانات الحساب المطابقة.',
            color: const Color(0xFFFF3B30),
            icon: Icons.error_outline,
            buttonText: 'حسناً',
          );
          return;
        }

        if (token != null) {
          _session.setToken(token.toString());
        }
        try {
          final Map<String, dynamic> userJson =
              (data['user'] as Map<String, dynamic>?) ??
              (data['data']?['user'] as Map<String, dynamic>?) ??
              (data['data'] as Map<String, dynamic>?) ??
              data;
          final user = UserModel.fromJson(userJson);
          _session.setCurrentUser(user);
          // ignore: avoid_print
          print(
            'REGISTER USER => id=${user.id}, name=${user.name}, image=${user.image}',
          );
          if (token != null) {
            // ignore: avoid_print
            print('REGISTER TOKEN: $token');
          }
        } catch (e) {
          // ignore: avoid_print
          print('REGISTER USER PARSE ERROR: $e');
        }
        Get.offAll(() => const MainPage());
      } else {
        LoadingDialog.hide();
        // ignore: avoid_print
        print('REGISTER FAILED -> error=${res['error']}, data=${res['data']}');
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

  void resetLoginForm() {
    phoneCtrl.clear();
    passwordCtrl.clear();
    obscurePassword.value = true;
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    cityCtrl.dispose();
    regPhoneCtrl.dispose();
    regPasswordCtrl.dispose();
    specializationCtrl.dispose();
    super.onClose();
  }
}
