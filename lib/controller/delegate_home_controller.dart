import 'package:get/get.dart';
import '../service_layer/services/visits_service.dart';
import 'session_controller.dart';

class DelegateHomeController extends GetxController {
  final VisitsService _service = VisitsService();
  final SessionController _session = Get.find<SessionController>();

  // البيانات من الـ API
  final recentVisits = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentVisits();
  }

  /// جلب الزيارات الأخيرة (آخر 10 زيارة)
  Future<void> loadRecentVisits() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      final res = await _service.getRepresentativeVisits(
        representativeId: userId,
        limit: 10, // آخر 10 زيارات
      );

      if (res['ok'] == true) {
        final responseData = res['data'];
        List<dynamic> dataList = [];

        // معالجة الاستجابة
        if (responseData != null) {
          if (responseData['data'] != null && responseData['data'] is List) {
            dataList = responseData['data'];
          } else if (responseData is List) {
            dataList = responseData;
          }
        }

        recentVisits.value = dataList.map((item) {
          return {
            'id': item['_id']?.toString() ?? '',
            'title': item['doctorName']?.toString() ?? 'غير معروف',
            'subtitle': item['doctorSpecialization']?.toString() ?? '',
            'isSubscribed': item['visitStatus']?.toString() == 'مشترك',
            'visits': item['visitCount'] as int?,
            'reason': item['nonSubscriptionReason']?.toString(),
          };
        }).toList();

        print('✅ Loaded ${recentVisits.length} recent visits');
      } else {
        print('❌ Failed to load recent visits: ${res['message']}');
        recentVisits.value = [];
      }
    } catch (e) {
      print('❌ Error loading recent visits: $e');
      recentVisits.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// إعادة تحميل البيانات
  Future<void> refresh() async {
    await loadRecentVisits();
  }

  @override
  void onClose() {
    // حذف البيانات عند مغادرة الصفحة
    recentVisits.clear();
    isLoading.value = false;
    super.onClose();
  }
}
