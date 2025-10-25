import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service_layer/services/secretary_service.dart';
import '../widget/status_dialog.dart';
import '../utils/app_colors.dart';

class SecretaryAccountsController extends GetxController {
  final SecretaryService _secretaryService = SecretaryService();

  // Secretary data: { 'id': String, 'name': String, 'phone': String, 'gender': String, 'age': int, 'city': String, 'address': String, 'image': String, 'status': String }
  final secretaries = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSecretaries();
  }

  /// جلب جميع السكرتارية من API
  Future<void> fetchSecretaries() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('📋 Fetching secretaries...');
      final res = await _secretaryService.getSecretaries();

      if (res['ok'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final responseData = data['data'] as Map<String, dynamic>? ?? {};
        final secretariesList = responseData['data'] as List<dynamic>? ?? [];

        print('🔍 Response data structure: $responseData');
        print('🔍 Secretaries list: $secretariesList');

        secretaries.clear();
        for (final secretary in secretariesList) {
          if (secretary is Map<String, dynamic>) {
            secretaries.add({
              'id':
                  secretary['_id']?.toString() ??
                  secretary['id']?.toString() ??
                  '',
              'name': secretary['name']?.toString() ?? '',
              'phone': secretary['phone']?.toString() ?? '',
              'gender': secretary['gender']?.toString() ?? '',
              'age': secretary['age']?.toString() ?? '0',
              'city': secretary['city']?.toString() ?? '',
              'address': secretary['address']?.toString() ?? '',
              'image': secretary['image']?.toString() ?? '',
              'status': secretary['status']?.toString() ?? 'نشط',
            });
          }
        }

        print('✅ Loaded ${secretaries.length} secretaries');
      } else {
        errorMessage.value =
            res['message']?.toString() ?? 'فشل في جلب السكرتارية';
        print('❌ Failed to fetch secretaries: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ Error fetching secretaries: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// إنشاء سكرتير جديد
  Future<bool> createSecretary({
    required String name,
    required String phone,
    required String password,
    required String gender,
    required int age,
    required String city,
    required String address,
    String image = '',
  }) async {
    try {
      isCreating.value = true;

      print('👤 Creating secretary: $name');
      final res = await _secretaryService.createSecretary(
        name: name,
        phone: phone,
        password: password,
        gender: gender,
        age: age,
        city: city,
        address: address,
        image: image,
      );

      if (res['ok'] == true) {
        print('✅ Secretary created successfully');
        // إعادة جلب القائمة لتحديثها
        await fetchSecretaries();
        return true;
      } else {
        final message = res['message']?.toString() ?? 'فشل في إنشاء السكرتير';
        print('❌ Failed to create secretary: $message');
        await showStatusDialog(
          title: 'فشل في إنشاء السكرتير',
          message: message,
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
        );
        return false;
      }
    } catch (e) {
      print('❌ Error creating secretary: $e');
      await showStatusDialog(
        title: 'خطأ في إنشاء السكرتير',
        message: 'حدث خطأ غير متوقع: $e',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  /// حذف سكرتير
  Future<bool> deleteSecretary(String secretaryId) async {
    try {
      print('🗑️ Deleting secretary: $secretaryId');
      final res = await _secretaryService.deleteSecretary(secretaryId);

      if (res['ok'] == true) {
        print('✅ Secretary deleted successfully');
        // إعادة جلب القائمة لتحديثها
        await fetchSecretaries();
        return true;
      } else {
        final message = res['message']?.toString() ?? 'فشل في حذف السكرتير';
        print('❌ Failed to delete secretary: $message');
        await showStatusDialog(
          title: 'فشل في حذف السكرتير',
          message: message,
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
        );
        return false;
      }
    } catch (e) {
      print('❌ Error deleting secretary: $e');
      await showStatusDialog(
        title: 'خطأ في حذف السكرتير',
        message: 'حدث خطأ غير متوقع: $e',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
      return false;
    }
  }

  /// تحديث حالة السكرتير (نشط/معطل)
  Future<bool> updateSecretaryStatus(
    String secretaryId,
    String newStatus,
  ) async {
    try {
      print('🔄 Updating secretary status: $secretaryId to $newStatus');
      final res = await _secretaryService.updateSecretaryStatus(
        secretaryId: secretaryId,
        status: newStatus,
      );

      if (res['ok'] == true) {
        print('✅ Secretary status updated successfully');
        // إعادة جلب القائمة لتحديثها
        await fetchSecretaries();
        return true;
      } else {
        final message =
            res['message']?.toString() ?? 'فشل في تحديث حالة السكرتير';
        print('❌ Failed to update secretary status: $message');
        await showStatusDialog(
          title: 'فشل في تحديث الحالة',
          message: message,
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
        );
        return false;
      }
    } catch (e) {
      print('❌ Error updating secretary status: $e');
      await showStatusDialog(
        title: 'خطأ في تحديث الحالة',
        message: 'حدث خطأ غير متوقع: $e',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
      return false;
    }
  }

  /// تغيير كلمة مرور السكرتير
  Future<bool> changeSecretaryPassword(
    String secretaryId,
    String newPassword,
  ) async {
    try {
      print('🔐 Changing secretary password: $secretaryId');
      final res = await _secretaryService.changeSecretaryPassword(
        secretaryId: secretaryId,
        newPassword: newPassword,
      );

      if (res['ok'] == true) {
        print('✅ Secretary password changed successfully');
        await showStatusDialog(
          title: 'تم تغيير كلمة المرور',
          message: 'تم تغيير كلمة مرور السكرتير بنجاح',
          color: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
        return true;
      } else {
        final message =
            res['message']?.toString() ?? 'فشل في تغيير كلمة المرور';
        print('❌ Failed to change secretary password: $message');
        await showStatusDialog(
          title: 'فشل في تغيير كلمة المرور',
          message: message,
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
        );
        return false;
      }
    } catch (e) {
      print('❌ Error changing secretary password: $e');
      await showStatusDialog(
        title: 'خطأ في تغيير كلمة المرور',
        message: 'حدث خطأ غير متوقع: $e',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
      return false;
    }
  }

  /// تحديث معلومات السكرتير
  Future<bool> updateSecretary({
    required String secretaryId,
    String? name,
    String? phone,
    String? city,
    String? address,
    int? age,
    String? image,
  }) async {
    try {
      print('✏️ Updating secretary: $secretaryId');
      final res = await _secretaryService.updateSecretary(
        secretaryId: secretaryId,
        name: name,
        phone: phone,
        city: city,
        address: address,
        age: age,
        image: image,
      );

      if (res['ok'] == true) {
        print('✅ Secretary updated successfully');
        // إعادة جلب القائمة لتحديثها
        await fetchSecretaries();
        return true;
      } else {
        final message = res['message']?.toString() ?? 'فشل في تحديث السكرتير';
        print('❌ Failed to update secretary: $message');
        await showStatusDialog(
          title: 'فشل في تحديث السكرتير',
          message: message,
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
        );
        return false;
      }
    } catch (e) {
      print('❌ Error updating secretary: $e');
      await showStatusDialog(
        title: 'خطأ في تحديث السكرتير',
        message: 'حدث خطأ غير متوقع: $e',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
      return false;
    }
  }
}
