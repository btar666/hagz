import '../../utils/constants.dart';
import 'api_request.dart';

class DoctorStatisticsService {
  final ApiRequest _api = ApiRequest();

  Future<Map<String, dynamic>> getDaily({
    required String doctorId,
    String? date, // YYYY-MM-DD
  }) async {
    var url = '${ApiConstants.doctorStatistics}/$doctorId/daily';
    if (date != null && date.isNotEmpty) {
      url += '?date=$date';
    }
    return await _api.get(url);
  }

  Future<Map<String, dynamic>> getRange({
    required String doctorId,
    required String startDate, // YYYY-MM-DD
    required String endDate, // YYYY-MM-DD
  }) async {
    final url = '${ApiConstants.doctorStatistics}/$doctorId/range?startDate=$startDate&endDate=$endDate';
    return await _api.get(url);
  }

  Future<Map<String, dynamic>> getYearly({
    required String doctorId,
    String? year,
  }) async {
    var url = '${ApiConstants.doctorStatistics}/$doctorId/yearly';
    if (year != null && year.isNotEmpty) {
      url += '?year=$year';
    }
    return await _api.get(url);
  }

  Future<Map<String, dynamic>> getOverall({
    required String doctorId,
  }) async {
    final url = '${ApiConstants.doctorStatistics}/$doctorId/overall';
    return await _api.get(url);
  }
}
