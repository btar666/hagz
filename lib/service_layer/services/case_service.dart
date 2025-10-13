import 'api_request.dart';
import '../../utils/constants.dart';

class CaseService {
  final ApiRequest _api = ApiRequest();

  /// إنشاء حالة جديدة
  Future<Map<String, dynamic>> createCase({
    required String title,
    required String description,
    required String visibility, // 'public' or 'private'
    required List<String> images,
  }) async {
    final body = {
      'title': title,
      'description': description,
      'visibility': visibility,
      'images': images,
    };
    final url = '${ApiConstants.doctorCases}/cases';
    print('➕ CREATE CASE URL: $url');
    print('➕ CREATE CASE BODY: $body');
    final result = await _api.post(url, body);
    print('➕ CREATE CASE RESPONSE: $result');
    return result;
  }

  /// جلب حالات طبيب معين
  Future<Map<String, dynamic>> getDoctorCases(String doctorId) async {
    final url = '${ApiConstants.doctorCases}/$doctorId/cases';
    print('📋 GET DOCTOR CASES URL: $url');
    final result = await _api.get(url);
    print('📋 GET DOCTOR CASES RESPONSE: $result');
    return result;
  }

  /// جلب حالة محددة
  Future<Map<String, dynamic>> getCaseById(String caseId) async {
    final url = '${ApiConstants.cases}/$caseId';
    return await _api.get(url);
  }

  /// حذف حالة
  Future<Map<String, dynamic>> deleteCase(String caseId) async {
    final url = '${ApiConstants.cases}/$caseId';
    print('🗑️ DELETE CASE URL: $url');
    final result = await _api.delete(url);
    print('🗑️ DELETE CASE RESPONSE: $result');
    return result;
  }
}
