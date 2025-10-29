import 'package:get/get.dart';
import '../service_layer/services/visits_service.dart';
import 'session_controller.dart';

class DelegateComplexesVisitsController extends GetxController {
  final VisitsService _service = VisitsService();
  final SessionController _session = Get.find<SessionController>();

  final complexesVisits = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadComplexesVisits();
  }

  Future<void> loadComplexesVisits() async {
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

        final filteredVisits = dataList
            .where((item) {
              final type = item['type']?.toString() ?? '';
              return type == 'complex' || type == 'مجمع';
            })
            .map((item) {
              return {
                'id': item['_id']?.toString() ?? '',
                'title':
                    item['hospitalName']?.toString() ??
                    item['doctorName']?.toString() ??
                    'غير معروف',
                'subtitle': item['address']?.toString() ?? '',
                'isSubscribed': item['visitStatus']?.toString() == 'مشترك',
                'visits': item['visitCount'] as int?,
                'reason': item['nonSubscriptionReason']?.toString(),
              };
            })
            .toList();

        complexesVisits.value = filteredVisits;
        print('✅ Loaded ${complexesVisits.length} complex visits');
      } else {
        print('❌ Failed to load complex visits: ${res['message']}');
        complexesVisits.value = [];
      }
    } catch (e) {
      print('❌ Error loading complex visits: $e');
      complexesVisits.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadComplexesVisits();
  }

  @override
  void onClose() {
    complexesVisits.clear();
    isLoading.value = false;
    super.onClose();
  }
}
