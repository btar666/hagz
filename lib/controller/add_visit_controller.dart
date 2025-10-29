import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service_layer/services/visits_service.dart';
import 'session_controller.dart';
import 'delegate_home_controller.dart';
import 'delegate_all_visits_controller.dart';

class AddVisitController extends GetxController {
  final VisitsService _service = VisitsService();
  final SessionController _session = Get.find<SessionController>();

  // نوع الزيارة: 'doctor', 'hospital', 'complex'
  final visitType = 'doctor'.obs;

  // Controllers للحقول
  final nameCtrl = TextEditingController();
  final specializationCtrl = TextEditingController();
  final numberOfDoctorsCtrl = TextEditingController();
  final governorateCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  // Selected values
  final selectedSpecialization = RxnString();
  final selectedGovernorate = RxnString();
  final selectedStatus = RxnString();

  // Location coordinates
  final selectedLatitude = RxnDouble();
  final selectedLongitude = RxnDouble();
  final selectedLocationAddress = ''.obs;

  // Lists للاختيار
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

  final List<String> subscriptionStatuses = ['مشترك', 'غير مشترك'];

  // Loading state
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // الحصول على نوع الزيارة من arguments
    if (Get.arguments != null && Get.arguments['type'] != null) {
      visitType.value = Get.arguments['type'] as String;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    specializationCtrl.dispose();
    numberOfDoctorsCtrl.dispose();
    governorateCtrl.dispose();
    districtCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }

  /// تحديث نوع الزيارة
  void setVisitType(String type) {
    visitType.value = type;
  }

  /// تحديث الموقع المحدد
  void setLocation({
    required double latitude,
    required double longitude,
    String address = '',
  }) {
    selectedLatitude.value = latitude;
    selectedLongitude.value = longitude;
    selectedLocationAddress.value = address;
  }

  /// إرسال النموذج
  Future<void> submit() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) {
      Get.snackbar('خطأ', 'المستخدم غير موجود');
      return;
    }

    // التحقق من الحقول المطلوبة
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال الاسم');
      return;
    }

    if (visitType.value == 'doctor' && selectedSpecialization.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار الاختصاص');
      return;
    }

    if (selectedGovernorate.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار المحافظة');
      return;
    }

    if (addressCtrl.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال العنوان');
      return;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال رقم الهاتف');
      return;
    }

    if (selectedStatus.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار حالة الاشتراك');
      return;
    }

    isSubmitting.value = true;

    try {
      // استخدام الإحداثيات من الخريطة إذا كانت موجودة
      Map<String, double> coordinatesToSend;

      if (selectedLatitude.value != null && selectedLongitude.value != null) {
        coordinatesToSend = {
          'latitude': selectedLatitude.value!,
          'longitude': selectedLongitude.value!,
        };
      } else {
        // إذا لم يتم تحديد موقع، استخدم قيم افتراضية (0.0)
        coordinatesToSend = {'latitude': 0.0, 'longitude': 0.0};
      }

      final res = await _service.createVisit(
        representative: userId,
        doctorName: nameCtrl.text.trim(),
        doctorSpecialization: visitType.value == 'doctor'
            ? (selectedSpecialization.value ?? '')
            : (visitType.value == 'hospital' ? 'مستشفى' : 'مجمع طبي'),
        doctorAddress: addressCtrl.text.trim(),
        doctorPhone: phoneCtrl.text.trim(),
        coordinates: coordinatesToSend,
        governorate: selectedGovernorate.value ?? '',
        district: districtCtrl.text.trim().isNotEmpty
            ? districtCtrl.text.trim()
            : 'غير محدد', // إرسال قيمة افتراضية بدلاً من فارغ
        visitStatus: selectedStatus.value ?? 'غير مشترك',
        nonSubscriptionReason: selectedStatus.value == 'غير مشترك'
            ? notesCtrl.text.trim()
            : '',
        notes: notesCtrl.text.trim(),
        visitCount: 1,
      );

      if (res['ok'] == true) {
        Get.snackbar(
          'نجح',
          'تم تسجيل الزيارة بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // تحديث قائمة الزيارات
        try {
          final homeController = Get.find<DelegateHomeController>();
          homeController.refresh();
        } catch (e) {
          // Controller not found, skip refresh
        }

        // تحديث قائمة جميع الزيارات أيضاً
        try {
          final allVisitsController = Get.find<DelegateAllVisitsController>();
          allVisitsController.refresh();
        } catch (e) {
          // Controller not found, skip refresh
        }

        // العودة للصفحة الرئيسية وتحديث البيانات
        Get.until((route) => route.isFirst);

        // تحديث الصفحة الرئيسية للمندوب
        try {
          final homeController = Get.find<DelegateHomeController>();
          homeController.refresh();
        } catch (e) {
          // Controller not found, skip
        }
      } else {
        Get.snackbar(
          'خطأ',
          res['message']?.toString() ?? 'فشل تسجيل الزيارة',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error creating visit: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الزيارة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// الحصول على عنوان الصفحة حسب النوع
  String get pageTitle {
    switch (visitType.value) {
      case 'hospital':
        return 'تسجيل مستشفى جديدة';
      case 'complex':
        return 'تسجيل مجمع طبي جديد';
      default:
        return 'تسجيل طبيب جديد';
    }
  }
}
