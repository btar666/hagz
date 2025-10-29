import 'package:get/get.dart';
import '../service_layer/services/visits_service.dart';
import 'session_controller.dart';

class DelegateAllVisitsController extends GetxController {
  final VisitsService _service = VisitsService();
  final SessionController _session = Get.find<SessionController>();

  // البيانات من الـ API
  final doctorsVisits = <Map<String, dynamic>>[].obs;
  final hospitalsVisits = <Map<String, dynamic>>[].obs;
  final complexesVisits = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final currentTab = 0.obs; // 0: أطباء, 1: مستشفيات, 2: مجمعات

  @override
  void onInit() {
    super.onInit();
    loadAllVisits();
  }

  /// تحميل جميع الزيارات
  Future<void> loadAllVisits() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      final res = await _service.getRepresentativeVisits(
        representativeId: userId,
        limit: 100, // جلب عدد كبير من الزيارات
      );

      if (res['ok'] == true) {
        final responseData = res['data'];
        List<dynamic> dataList = [];

        if (responseData != null) {
          if (responseData['data'] != null && responseData['data'] is List) {
            dataList = responseData['data'];
          } else if (responseData is List) {
            dataList = responseData;
          }
        }

        // معالجة البيانات وتحويلها إلى كروت
        final allVisits = dataList.map((item) {
          final specialization = item['doctorSpecialization']?.toString() ?? '';

          // تحديد النوع بناءً على التخصص
          String visitType = 'doctor'; // افتراضي طبيب
          if (specialization == 'مستشفى' ||
              specialization.toLowerCase().contains('مستشفى')) {
            visitType = 'hospital';
          } else if (specialization == 'مجمع طبي' ||
              specialization == 'مجمع' ||
              specialization.toLowerCase().contains('مجمع')) {
            visitType = 'complex';
          }

          return {
            'id': item['_id']?.toString() ?? '',
            'title': item['doctorName']?.toString() ?? 'غير معروف',
            'subtitle': specialization,
            'isSubscribed': item['visitStatus']?.toString() == 'مشترك',
            'visits': item['visitCount'] as int?,
            'reason': item['nonSubscriptionReason']?.toString(),
            'type': visitType,
          };
        }).toList();

        // فلترة حسب النوع
        doctorsVisits.value = allVisits.where((v) {
          final type = v['type']?.toString() ?? '';
          return type == 'doctor';
        }).toList();

        hospitalsVisits.value = allVisits.where((v) {
          final type = v['type']?.toString() ?? '';
          return type == 'hospital';
        }).toList();

        complexesVisits.value = allVisits.where((v) {
          final type = v['type']?.toString() ?? '';
          return type == 'complex';
        }).toList();

        print(
          '✅ Doctors: ${doctorsVisits.length}, Hospitals: ${hospitalsVisits.length}, Complexes: ${complexesVisits.length}',
        );

        print('✅ Loaded visits: ${allVisits.length} total');
      } else {
        print('❌ Failed to load visits: ${res['message']}');
        doctorsVisits.value = [];
        hospitalsVisits.value = [];
        complexesVisits.value = [];
      }
    } catch (e) {
      print('❌ Error loading visits: $e');
      doctorsVisits.value = [];
      hospitalsVisits.value = [];
      complexesVisits.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// تغيير التبويب
  void changeTab(int index) {
    currentTab.value = index;
  }

  /// جلب البيانات للتبويب الحالي
  List<Map<String, dynamic>> get currentTabVisits {
    switch (currentTab.value) {
      case 0:
        return doctorsVisits;
      case 1:
        return hospitalsVisits;
      case 2:
        return complexesVisits;
      default:
        return doctorsVisits;
    }
  }

  /// إعادة تحميل البيانات
  Future<void> refresh() async {
    await loadAllVisits();
  }

  @override
  void onClose() {
    // حذف البيانات عند مغادرة الصفحة
    doctorsVisits.clear();
    hospitalsVisits.clear();
    complexesVisits.clear();
    isLoading.value = false;
    currentTab.value = 0;
    super.onClose();
  }
}
