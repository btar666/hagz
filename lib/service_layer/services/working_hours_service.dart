import 'api_request.dart';
import '../../utils/constants.dart';

class WorkingHoursService {
  final ApiRequest _api = ApiRequest();

  /// إضافة أوقات عمل للطبيب
  Future<Map<String, dynamic>> createWorkingHours({
    required String doctorId,
    required List<Map<String, dynamic>> workingHours,
  }) async {
    final url = '${ApiConstants.doctorsWorkingHours}/$doctorId/working-hours';
    final body = {'workingHours': workingHours};
    print('➕ CREATE WORKING HOURS URL: $url');
    print('➕ CREATE WORKING HOURS BODY: $body');
    final result = await _api.post(url, body);
    print('➕ CREATE WORKING HOURS RESPONSE: $result');
    return result;
  }

  /// جلب أوقات عمل طبيب معين
  Future<Map<String, dynamic>> getDoctorWorkingHours(String doctorId) async {
    final url = '${ApiConstants.doctorsWorkingHours}/$doctorId/working-hours';
    print('📋 GET WORKING HOURS URL: $url');
    final result = await _api.get(url);
    print('📋 GET WORKING HOURS RESPONSE: $result');
    return result;
  }

  /// تحديث وقت عمل محدد
  Future<Map<String, dynamic>> updateWorkingHour({
    required String workingHoursId,
    required String startTime,
    required String endTime,
    required bool isWorking,
    required int slotDuration,
  }) async {
    final url = '${ApiConstants.workingHours}/$workingHoursId';
    final body = {
      'startTime': startTime,
      'endTime': endTime,
      'isWorking': isWorking,
      'slotDuration': slotDuration,
    };
    print('✏️ UPDATE WORKING HOUR URL: $url');
    print('✏️ UPDATE WORKING HOUR BODY: $body');
    final result = await _api.put(url, body);
    print('✏️ UPDATE WORKING HOUR RESPONSE: $result');
    return result;
  }

  /// حذف جميع أوقات عمل الطبيب
  Future<Map<String, dynamic>> deleteAllWorkingHours(String doctorId) async {
    final url = '${ApiConstants.doctorsWorkingHours}/$doctorId/working-hours';
    print('🗑️ DELETE ALL WORKING HOURS URL: $url');
    final result = await _api.delete(url);
    print('🗑️ DELETE ALL WORKING HOURS RESPONSE: $result');
    return result;
  }

  /// التحقق من توفر الطبيب في تاريخ ووقت معين
  Future<Map<String, dynamic>> checkAvailability({
    required String doctorId,
    required String date,
    required String time,
  }) async {
    final url =
        '${ApiConstants.doctorsWorkingHours}/$doctorId/check-availability/$date/$time';
    print('🔍 CHECK AVAILABILITY URL: $url');
    final result = await _api.get(url);
    print('🔍 CHECK AVAILABILITY RESPONSE: $result');
    return result;
  }
}
