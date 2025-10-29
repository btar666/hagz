import 'package:get/get.dart';
import '../service_layer/services/visits_service.dart';
import 'session_controller.dart';

class DelegateDoctorsVisitsController extends GetxController {
  final VisitsService _service = VisitsService();
  final SessionController _session = Get.find<SessionController>();

  // البيانات من الـ API
  final doctorsVisits = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDoctorsVisits();
  }

  /// تحميل زيارات الأطباء
  Future<void> loadDoctorsVisits() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      final res = await _service.getRepresentativeVisits(
        representativeId: userId,
        limit: 100,
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

        // فلترة فقط زيارات الأطباء
        final filteredVisits = dataList
            .where((item) {
              final type = item['type']?.toString() ?? 'doctor';
              return type == 'doctor' || type == 'طبيب';
            })
            .map((item) {
              return {
                'id': item['_id']?.toString() ?? '',
                'title': item['doctorName']?.toString() ?? 'غير معروف',
                'subtitle': item['doctorSpecialization']?.toString() ?? '',
                'isSubscribed': item['visitStatus']?.toString() == 'مشترك',
                'visits': item['visitCount'] as int?,
                'reason': item['nonSubscriptionReason']?.toString(),
              };
            })
            .toList();

        doctorsVisits.value = filteredVisits;
        print('✅ Loaded ${doctorsVisits.length} doctor visits');
      } else {
        print('❌ Failed to load doctor visits: ${res['message']}');
        doctorsVisits.value = [];
      }
    } catch (e) {
      print('❌ Error loading doctor visits: $e');
      doctorsVisits.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// إعادة تحميل البيانات
  Future<void> refresh() async {
    await loadDoctorsVisits();
  }

  @override
  void onClose() {
    doctorsVisits.clear();
    isLoading.value = false;
    super.onClose();
  }
}
