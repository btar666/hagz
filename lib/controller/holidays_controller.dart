import 'package:get/get.dart';
import '../service_layer/services/holidays_service.dart';
import 'session_controller.dart';

class HolidaysController extends GetxController {
  final HolidaysService _service = HolidaysService();
  final SessionController _session = Get.find<SessionController>();

  // حالة التحميل
  RxBool isLoading = false.obs;

  // قائمة العطل
  RxList<Map<String, dynamic>> holidays = <Map<String, dynamic>>[].obs;

  // قائمة العطل القادمة
  RxList<Map<String, dynamic>> upcomingHolidays = <Map<String, dynamic>>[].obs;

  // قائمة العطل المتكررة
  RxList<Map<String, dynamic>> recurringHolidays = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHolidays();
    loadUpcomingHolidays();
  }

  /// جلب جميع العطل
  Future<void> loadHolidays({
    String? startDate,
    String? endDate,
    bool? isRecurring,
  }) async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      final res = await _service.getDoctorHolidays(
        doctorId: userId,
        startDate: startDate,
        endDate: endDate,
        isRecurring: isRecurring,
      );
      if (res['ok'] == true) {
        final data = res['data']?['data'];
        if (data != null && data is List) {
          holidays.value = data.map((item) {
            return {
              '_id': item['_id']?.toString() ?? '',
              'date': item['date']?.toString() ?? '',
              'reason': item['reason']?.toString() ?? '',
              'isRecurring': item['isRecurring'] ?? false,
              'isFullDay': item['isFullDay'] ?? true,
              'startTime': item['startTime']?.toString(),
              'endTime': item['endTime']?.toString(),
              'createdAt': item['createdAt']?.toString() ?? '',
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error loading holidays: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب العطل القادمة
  Future<void> loadUpcomingHolidays({int limit = 10}) async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    try {
      final res = await _service.getUpcomingHolidays(
        doctorId: userId,
        limit: limit,
      );
      if (res['ok'] == true) {
        final data = res['data']?['data'];
        if (data != null && data is List) {
          upcomingHolidays.value = data.map((item) {
            return {
              '_id': item['_id']?.toString() ?? '',
              'date': item['date']?.toString() ?? '',
              'reason': item['reason']?.toString() ?? '',
              'isRecurring': item['isRecurring'] ?? false,
              'isFullDay': item['isFullDay'] ?? true,
              'startTime': item['startTime']?.toString(),
              'endTime': item['endTime']?.toString(),
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error loading upcoming holidays: $e');
    }
  }

  /// جلب العطل المتكررة
  Future<void> loadRecurringHolidays() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    try {
      final res = await _service.getRecurringHolidays(userId);
      if (res['ok'] == true) {
        final data = res['data']?['data'];
        if (data != null && data is List) {
          recurringHolidays.value = data.map((item) {
            return {
              '_id': item['_id']?.toString() ?? '',
              'date': item['date']?.toString() ?? '',
              'reason': item['reason']?.toString() ?? '',
              'isRecurring': item['isRecurring'] ?? false,
              'isFullDay': item['isFullDay'] ?? true,
              'startTime': item['startTime']?.toString(),
              'endTime': item['endTime']?.toString(),
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error loading recurring holidays: $e');
    }
  }

  /// إضافة عطلة جديدة
  Future<Map<String, dynamic>> addHoliday({
    required String date,
    required String reason,
    required bool isRecurring,
    required bool isFullDay,
    String? startTime,
    String? endTime,
  }) async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) {
      return {'ok': false, 'message': 'معرف المستخدم غير موجود'};
    }

    final res = await _service.createHoliday(
      doctorId: userId,
      date: date,
      reason: reason,
      isRecurring: isRecurring,
      isFullDay: isFullDay,
      startTime: startTime,
      endTime: endTime,
    );

    if (res['ok'] == true) {
      await loadHolidays();
      await loadUpcomingHolidays();
    }

    return res;
  }

  /// تحديث عطلة
  Future<Map<String, dynamic>> updateHoliday({
    required String holidayId,
    required String date,
    required String reason,
    required bool isRecurring,
    required bool isFullDay,
    String? startTime,
    String? endTime,
  }) async {
    final res = await _service.updateHoliday(
      holidayId: holidayId,
      date: date,
      reason: reason,
      isRecurring: isRecurring,
      isFullDay: isFullDay,
      startTime: startTime,
      endTime: endTime,
    );

    if (res['ok'] == true) {
      await loadHolidays();
      await loadUpcomingHolidays();
    }

    return res;
  }

  /// حذف عطلة
  Future<Map<String, dynamic>> deleteHoliday(String holidayId) async {
    final res = await _service.deleteHoliday(holidayId);

    if (res['ok'] == true) {
      holidays.removeWhere((h) => h['_id'] == holidayId);
      upcomingHolidays.removeWhere((h) => h['_id'] == holidayId);
    }

    return res;
  }

  /// إنشاء عطل متكررة لسنة معينة
  Future<Map<String, dynamic>> createRecurringHolidays({int? year}) async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) {
      return {'ok': false, 'message': 'معرف المستخدم غير موجود'};
    }

    final res = await _service.createRecurringHolidays(
      doctorId: userId,
      year: year,
    );

    if (res['ok'] == true) {
      await loadHolidays();
      await loadUpcomingHolidays();
    }

    return res;
  }

  /// التحقق من وجود عطلة في تاريخ معين
  Future<Map<String, dynamic>> checkHoliday(String date) async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) {
      return {'ok': false, 'message': 'معرف المستخدم غير موجود'};
    }

    return await _service.checkHoliday(doctorId: userId, date: date);
  }
}

