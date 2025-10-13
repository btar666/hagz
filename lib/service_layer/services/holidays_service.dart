import 'api_request.dart';
import '../../utils/constants.dart';

class HolidaysService {
  final ApiRequest _api = ApiRequest();

  /// إضافة عطلة جديدة
  Future<Map<String, dynamic>> createHoliday({
    required String doctorId,
    required String date,
    required String reason,
    required bool isRecurring,
    required bool isFullDay,
    String? startTime,
    String? endTime,
  }) async {
    final url = '${ApiConstants.doctorsWorkingHours}/$doctorId/holidays';
    final body = {
      'date': date,
      'reason': reason,
      'isRecurring': isRecurring,
      'isFullDay': isFullDay,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
    print('➕ CREATE HOLIDAY URL: $url');
    print('➕ CREATE HOLIDAY BODY: $body');
    final result = await _api.post(url, body);
    print('➕ CREATE HOLIDAY RESPONSE: $result');
    return result;
  }

  /// جلب عطل الطبيب
  Future<Map<String, dynamic>> getDoctorHolidays({
    required String doctorId,
    String? startDate,
    String? endDate,
    bool? isRecurring,
  }) async {
    var url = '${ApiConstants.doctorsWorkingHours}/$doctorId/holidays';

    final queryParams = <String>[];
    if (startDate != null) queryParams.add('startDate=$startDate');
    if (endDate != null) queryParams.add('endDate=$endDate');
    if (isRecurring != null) queryParams.add('isRecurring=$isRecurring');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    print('📋 GET HOLIDAYS URL: $url');
    final result = await _api.get(url);
    print('📋 GET HOLIDAYS RESPONSE: $result');
    return result;
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
    final url = '${ApiConstants.holidays}/$holidayId';
    final body = {
      'date': date,
      'reason': reason,
      'isRecurring': isRecurring,
      'isFullDay': isFullDay,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
    print('✏️ UPDATE HOLIDAY URL: $url');
    print('✏️ UPDATE HOLIDAY BODY: $body');
    final result = await _api.put(url, body);
    print('✏️ UPDATE HOLIDAY RESPONSE: $result');
    return result;
  }

  /// حذف عطلة
  Future<Map<String, dynamic>> deleteHoliday(String holidayId) async {
    final url = '${ApiConstants.holidays}/$holidayId';
    print('🗑️ DELETE HOLIDAY URL: $url');
    final result = await _api.delete(url);
    print('🗑️ DELETE HOLIDAY RESPONSE: $result');
    return result;
  }

  /// جلب العطل القادمة
  Future<Map<String, dynamic>> getUpcomingHolidays({
    required String doctorId,
    int? limit,
  }) async {
    var url = '${ApiConstants.doctorsWorkingHours}/$doctorId/upcoming-holidays';
    if (limit != null) {
      url += '?limit=$limit';
    }
    print('📅 GET UPCOMING HOLIDAYS URL: $url');
    final result = await _api.get(url);
    print('📅 GET UPCOMING HOLIDAYS RESPONSE: $result');
    return result;
  }

  /// جلب العطل المتكررة
  Future<Map<String, dynamic>> getRecurringHolidays(String doctorId) async {
    final url =
        '${ApiConstants.doctorsWorkingHours}/$doctorId/recurring-holidays';
    print('🔁 GET RECURRING HOLIDAYS URL: $url');
    final result = await _api.get(url);
    print('🔁 GET RECURRING HOLIDAYS RESPONSE: $result');
    return result;
  }

  /// إنشاء عطل متكررة لسنة معينة
  Future<Map<String, dynamic>> createRecurringHolidays({
    required String doctorId,
    int? year,
  }) async {
    var url =
        '${ApiConstants.doctorsWorkingHours}/$doctorId/create-recurring-holidays';
    if (year != null) {
      url += '?year=$year';
    }
    print('🔁➕ CREATE RECURRING HOLIDAYS URL: $url');
    final result = await _api.post(url, {});
    print('🔁➕ CREATE RECURRING HOLIDAYS RESPONSE: $result');
    return result;
  }

  /// التحقق من وجود عطلة في تاريخ معين
  Future<Map<String, dynamic>> checkHoliday({
    required String doctorId,
    required String date,
  }) async {
    final url =
        '${ApiConstants.doctorsWorkingHours}/$doctorId/check-holiday/$date';
    print('🔍 CHECK HOLIDAY URL: $url');
    final result = await _api.get(url);
    print('🔍 CHECK HOLIDAY RESPONSE: $result');
    return result;
  }
}

