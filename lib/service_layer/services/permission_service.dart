import 'package:location/location.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// خدمة إدارة صلاحيات الموقع
class PermissionService {
  static final Location _location = Location();

  /// فحص صلاحيات الموقع الحالية
  static Future<PermissionStatus> checkLocationPermission() async {
    try {
      return await _location.hasPermission();
    } catch (e) {
      print('خطأ في فحص صلاحيات الموقع: $e');
      return PermissionStatus.denied;
    }
  }

  /// طلب صلاحيات الموقع
  static Future<PermissionStatus> requestLocationPermission() async {
    try {
      return await _location.requestPermission();
    } catch (e) {
      print('خطأ في طلب صلاحيات الموقع: $e');
      return PermissionStatus.denied;
    }
  }

  /// فحص وطلب صلاحيات الموقع بشكل آمن
  static Future<bool> ensureLocationPermission() async {
    try {
      PermissionStatus permission = await checkLocationPermission();

      if (permission == PermissionStatus.granted) {
        return true;
      }

      if (permission == PermissionStatus.deniedForever) {
        _showPermissionDeniedForeverDialog();
        return false;
      }

      permission = await requestLocationPermission();

      if (permission == PermissionStatus.granted) {
        return true;
      } else if (permission == PermissionStatus.deniedForever) {
        _showPermissionDeniedForeverDialog();
        return false;
      } else {
        _showPermissionDeniedDialog();
        return false;
      }
    } catch (e) {
      print('خطأ في ensureLocationPermission: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في فحص صلاحيات الموقع',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// فحص خدمة الموقع
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await _location.serviceEnabled();
    } catch (e) {
      print('خطأ في فحص خدمة الموقع: $e');
      return false;
    }
  }

  /// طلب تفعيل خدمة الموقع
  static Future<bool> requestLocationService() async {
    try {
      return await _location.requestService();
    } catch (e) {
      print('خطأ في طلب تفعيل خدمة الموقع: $e');
      return false;
    }
  }

  /// التأكد من تفعيل خدمة الموقع
  static Future<bool> ensureLocationService() async {
    try {
      bool isEnabled = await isLocationServiceEnabled();

      if (isEnabled) {
        return true;
      }

      isEnabled = await requestLocationService();

      if (!isEnabled) {
        Get.snackbar(
          'تنبيه',
          'يرجى تفعيل خدمة الموقع من إعدادات الجهاز',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.location_off, color: Colors.white),
        );
      }

      return isEnabled;
    } catch (e) {
      print('خطأ في ensureLocationService: $e');
      return false;
    }
  }

  /// عرض حوار رفض الصلاحية
  static void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.red),
            SizedBox(width: 8),
            Text('إذن الموقع مطلوب'),
          ],
        ),
        content: const Text(
          'يحتاج التطبيق لإذن الوصول للموقع لتحديد موقعك الحالي. '
          'يرجى منح الإذن للمتابعة.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('حسناً')),
        ],
      ),
    );
  }

  /// عرض حوار رفض الصلاحية نهائياً
  static void _showPermissionDeniedForeverDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.orange),
            SizedBox(width: 8),
            Text('إعدادات مطلوبة'),
          ],
        ),
        content: const Text(
          'تم رفض إذن الموقع نهائياً. يرجى فتح إعدادات التطبيق '
          'وتفعيل إذن الموقع يدوياً.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('حسناً')),
        ],
      ),
    );
  }
}
