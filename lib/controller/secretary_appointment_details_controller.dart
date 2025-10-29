import 'package:get/get.dart';
import '../service_layer/services/appointments_service.dart';
import 'secretary_appointments_controller.dart';
import '../utils/app_colors.dart';
import 'package:flutter/material.dart';

class SecretaryAppointmentDetailsController extends GetxController {
  final AppointmentsService _service = AppointmentsService();

  // Observable status
  final status = 'مؤكد'.obs;

  // Appointment ID
  String? appointmentId;

  @override
  void onInit() {
    super.onInit();
    // Initialize with passed status
    if (Get.arguments != null && Get.arguments['status'] != null) {
      status.value = Get.arguments['status'];
    }
    if (Get.arguments != null && Get.arguments['appointmentId'] != null) {
      appointmentId = Get.arguments['appointmentId'];
    }
  }

  Future<void> updateStatus(String newStatus) async {
    print('🔵 ========== START updateStatus ==========');
    print('🔵 New Status to set: $newStatus');
    print('🔵 Appointment ID: $appointmentId');
    
    if (appointmentId == null || appointmentId!.isEmpty) {
      print('❌ ERROR: appointmentId is null or empty!');
      Get.snackbar(
        'فشل',
        'معرّف الموعد غير موجود',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('🔵 Calling API to update status...');
    print('🔵 appointmentId: $appointmentId');
    print('🔵 newStatus: $newStatus');
    
    final res = await _service.updateAppointmentStatus(
      appointmentId: appointmentId!,
      status: newStatus,
    );

    print('🔵 API Response: $res');
    print('🔵 res[ok]: ${res['ok']}');

    if (res['ok'] == true) {
      print('✅ SUCCESS: Status updated successfully');
      print('✅ Old status: ${status.value}');
      status.value = newStatus;
      print('✅ New status: ${status.value}');
      
      Get.snackbar(
        'تم',
        'تم تحديث حالة الموعد إلى $newStatus',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );

      // Reload appointments
      print('🔵 Attempting to reload appointments...');
      try {
        final secretaryCtrl = Get.find<SecretaryAppointmentsController>();
        print('✅ Found SecretaryAppointmentsController, calling loadAppointments()');
        secretaryCtrl.loadAppointments();
        print('✅ loadAppointments() called successfully');
      } catch (e) {
        print('⚠️ WARNING: Could not find SecretaryAppointmentsController: $e');
      }
      
      print('✅ ========== END updateStatus (SUCCESS) ==========');
    } else {
      print('❌ FAILED: Status update failed');
      print('❌ Response: $res');
      print('❌ Message: ${res['message']}');
      
      Get.snackbar(
        'فشل',
        'تعذر تغيير الحالة - تحقق من الاتصال',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      print('❌ ========== END updateStatus (FAILED) ==========');
    }
  }
}
