import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service_layer/services/visits_service.dart';
import 'delegate_doctors_visits_controller.dart';
import 'delegate_all_visits_controller.dart';

class RepeatVisitController extends GetxController {
  final VisitsService _service = VisitsService();

  late final String visitId;
  final selectedStatus = RxnString();
  final reasonCtrl = TextEditingController();

  // current visits count from args; we will increment by 1 automatically
  late int currentVisits;
  int get nextVisits => currentVisits + 1;

  final isSubmitting = false.obs;

  final List<String> subscriptionStatuses = ['مشترك', 'غير مشترك'];

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments ?? {}) as Map<String, dynamic>;
    visitId = (args['id'] ?? '') as String;
    final bool isSubscribed = (args['isSubscribed'] ?? false) as bool;
    final int visits = (args['visits'] ?? 0) as int;
    final String? reason = args['reason'] as String?;

    selectedStatus.value = isSubscribed ? 'مشترك' : 'غير مشترك';
    currentVisits = visits;
    if (reason != null) reasonCtrl.text = reason;
  }

  @override
  void onClose() {
    reasonCtrl.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (selectedStatus.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار حالة الاشتراك');
      return;
    }

    final int count = nextVisits;

    isSubmitting.value = true;
    try {
      final res = await _service.updateVisit(
        visitId: visitId,
        visitStatus: selectedStatus.value,
        nonSubscriptionReason:
            selectedStatus.value == 'غير مشترك' ? reasonCtrl.text.trim() : null,
        visitCount: count,
      );

      if (res['ok'] == true) {
        Get.snackbar(
          'نجح',
          'تم تحديث الزيارة بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // حاول تحديث القوائم ذات الصلة
        try {
          final doctorsCtrl = Get.find<DelegateDoctorsVisitsController>();
          await doctorsCtrl.refresh();
        } catch (_) {}
        try {
          final allCtrl = Get.find<DelegateAllVisitsController>();
          await allCtrl.refresh();
        } catch (_) {}

        Get.back(); // اغلاق صفحة التكرار
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
