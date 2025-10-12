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
    return await _api.post(ApiConstants.doctorCases, body);
  }

  /// جلب حالات طبيب معين
  Future<Map<String, dynamic>> getDoctorCases(String doctorId) async {
    final url = '${ApiConstants.doctorCases}/$doctorId/cases';
    return await _api.get(url);
  }

  /// جلب حالة محددة
  Future<Map<String, dynamic>> getCaseById(String caseId) async {
    final url = '${ApiConstants.cases}/$caseId';
    return await _api.get(url);
  }

  /// حذف حالة
  Future<Map<String, dynamic>> deleteCase(String caseId) async {
    final url = '${ApiConstants.cases}/$caseId';
    return await _api.delete(url);
  }
}
