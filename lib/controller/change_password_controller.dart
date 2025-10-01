import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../service_layer/services/user_service.dart';
import '../widget/loading_dialog.dart';
import '../widget/status_dialog.dart';

class ChangePasswordController extends GetxController {
  final TextEditingController oldCtrl = TextEditingController();
  final TextEditingController newCtrl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool hideOld = true.obs;
  final RxBool hideNew = true.obs;
  final UserService _userService = UserService();

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    await LoadingDialog.show(message: 'جاري تحديث كلمة السر...');
    try {
      final res = await _userService.changePassword(
        oldPassword: oldCtrl.text.trim(),
        newPassword: newCtrl.text.trim(),
      );
      if (res['ok'] == true) {
        Get.back();
        await showStatusDialog(
          title: 'تم التعديل',
          message: 'تم تغيير كلمة السر بنجاح',
          color: AppColors.primary,
          icon: Icons.check_circle_outline,
          buttonText: 'حسناً',
        );
      } else {
        await showStatusDialog(
          title: 'حدث خطأ',
          message: 'لم يتم تغيير كلمة السر',
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
          buttonText: 'حسناً',
        );
      }
    } catch (_) {
      await showStatusDialog(
        title: 'حدث خطأ',
        message: 'لم يتم تغيير كلمة السر',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
        buttonText: 'حسناً',
      );
    } finally {
      LoadingDialog.hide();
    }
  }
}
