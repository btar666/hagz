import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service_layer/services/visits_service.dart';
import 'delegate_doctors_visits_controller.dart';
import 'delegate_all_visits_controller.dart';

class EditVisitController extends GetxController {
  final VisitsService _service = VisitsService();

  late final String visitId;
  
  final nameCtrl = TextEditingController();
  final specializationCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final governorateCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final selectedStatus = RxnString();
  final reasonCtrl = TextEditingController();

  // Location coordinates
  final selectedLatitude = RxnDouble();
  final selectedLongitude = RxnDouble();

  final isSubmitting = false.obs;
  final List<String> subscriptionStatuses = ['مشترك', 'غير مشترك'];
  final List<String> iraqiGovernorates = [
    'بغداد',
    'البصرة',
    'الموصل',
    'أربيل',
    'السليمانية',
    'دهوك',
    'كركوك',
    'ديالى',
    'الأنبار',
    'بابل',
    'كربلاء',
    'النجف',
    'واسط',
    'ميسان',
    'ذي قار',
    'القادسية',
    'المثنى',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments ?? {}) as Map<String, dynamic>;
    visitId = (args['id'] ?? '') as String;
    
    nameCtrl.text = (args['title'] ?? '') as String;
    specializationCtrl.text = (args['subtitle'] ?? '') as String;
    addressCtrl.text = (args['address'] ?? '') as String;
    phoneCtrl.text = (args['phone'] ?? '') as String;
    governorateCtrl.text = (args['governorate'] ?? '') as String;
    districtCtrl.text = (args['district'] ?? '') as String;
    notesCtrl.text = (args['notes'] ?? '') as String;
    
    final bool isSubscribed = (args['isSubscribed'] ?? false) as bool;
    final String? reason = args['reason'] as String?;
    
    selectedStatus.value = isSubscribed ? 'مشترك' : 'غير مشترك';
    if (reason != null && reason.isNotEmpty) {
      reasonCtrl.text = reason;
    }

    // Set coordinates from args if available
    final coords = args['coordinates'] as Map<String, dynamic>?;
    if (coords != null) {
      selectedLatitude.value = (coords['latitude'] as num?)?.toDouble();
      selectedLongitude.value = (coords['longitude'] as num?)?.toDouble();
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    specializationCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    governorateCtrl.dispose();
    districtCtrl.dispose();
    notesCtrl.dispose();
    reasonCtrl.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    // Validation
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال الاسم');
      return;
    }

    if (specializationCtrl.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال التخصص');
      return;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال رقم الهاتف');
      return;
    }

    if (addressCtrl.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال العنوان');
      return;
    }

    if (governorateCtrl.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى اختيار المحافظة');
      return;
    }

    if (selectedStatus.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار حالة الاشتراك');
      return;
    }

    isSubmitting.value = true;
    try {
      Map<String, double>? coordinatesToSend;
      if (selectedLatitude.value != null && selectedLongitude.value != null) {
        coordinatesToSend = {
          'latitude': selectedLatitude.value!,
          'longitude': selectedLongitude.value!,
        };
      }

      final res = await _service.updateVisit(
        visitId: visitId,
        doctorName: nameCtrl.text.trim(),
        doctorSpecialization: specializationCtrl.text.trim(),
        doctorAddress: addressCtrl.text.trim(),
        doctorPhone: phoneCtrl.text.trim(),
        governorate: governorateCtrl.text.trim(),
        district: districtCtrl.text.trim().isNotEmpty ? districtCtrl.text.trim() : null,
        coordinates: coordinatesToSend,
        visitStatus: selectedStatus.value,
        nonSubscriptionReason:
            selectedStatus.value == 'غير مشترك' ? reasonCtrl.text.trim() : null,
        notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
      );

      if (res['ok'] == true) {
        // حاول تحديث القوائم ذات الصلة
        try {
          final doctorsCtrl = Get.find<DelegateDoctorsVisitsController>();
          await doctorsCtrl.refresh();
        } catch (_) {}
        try {
          final allCtrl = Get.find<DelegateAllVisitsController>();
          await allCtrl.refresh();
        } catch (_) {}

        Get.back(result: 'updated'); // اغلاق صفحة التعديل مع إشارة التحديث
      } else {
        Get.snackbar(
          'خطأ',
          res['message']?.toString() ?? 'فشل تحديث الزيارة',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث الزيارة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
