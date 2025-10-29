import 'package:get/get.dart';
import '../service_layer/services/visits_service.dart';
import 'session_controller.dart';

class DelegateStatisticsController extends GetxController {
  final VisitsService _service = VisitsService();
  final SessionController _session = Get.find<SessionController>();

  // الإحصائيات
  final currentPoints = 0.obs; // النقاط الحالية
  final stats = <String, Map<String, dynamic>>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  /// جلب الإحصائيات
  Future<void> loadStatistics() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      final res = await _service.getVisitsStats(representativeId: userId);

      if (res['ok'] == true) {
        final data = res['data'];
        if (data != null) {
          // استخراج النقاط
          currentPoints.value = data['currentPoints'] as int? ?? 0;

          // استخراج الإحصائيات اليومية/الأسبوعية/الشهرية/السنوية
          stats['daily'] = _extractPeriodStats(data, 'daily');
          stats['weekly'] = _extractPeriodStats(data, 'weekly');
          stats['monthly'] = _extractPeriodStats(data, 'monthly');
          stats['yearly'] = _extractPeriodStats(data, 'yearly');

          print('✅ Loaded statistics: ${currentPoints.value} points');
        }
      } else {
        print('❌ Failed to load statistics: ${res['message']}');
      }
    } catch (e) {
      print('❌ Error loading statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// استخراج إحصائيات فترة معينة
  Map<String, dynamic> _extractPeriodStats(
    Map<String, dynamic> data,
    String period,
  ) {
    final periodData = data[period];
    if (periodData == null) {
      return {
        'subscribed': 0,
        'notSubscribed': 0,
        'subscribedAfterRejection': 0,
        'cancelledSubscription': 0,
        'total': 0,
      };
    }

    return {
      'subscribed': periodData['subscribed'] as int? ?? 0,
      'notSubscribed': periodData['notSubscribed'] as int? ?? 0,
      'subscribedAfterRejection':
          periodData['subscribedAfterRejection'] as int? ?? 0,
      'cancelledSubscription': periodData['cancelledSubscription'] as int? ?? 0,
      'total': periodData['total'] as int? ?? 0,
    };
  }

  /// إعادة تحميل البيانات
  Future<void> refresh() async {
    await loadStatistics();
  }
}
