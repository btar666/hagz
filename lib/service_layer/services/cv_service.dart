import '../../utils/constants.dart';
import 'api_request.dart';

class CvService {
  final ApiRequest _api = ApiRequest();

  Future<Map<String, dynamic>> createCv({
    required String description,
    required List<Map<String, String>> certificates,
  }) async {
    final body = {'description': description, 'certificates': certificates};
    return await _api.post(ApiConstants.userCv, body);
  }

  Future<Map<String, dynamic>> getUserCvByUserId(String userId) async {
    final url = '${ApiConstants.userCv}/$userId';
    return await _api.get(url);
  }

  Future<Map<String, dynamic>> getCvById(String cvId) async {
    final url = '${ApiConstants.cv}/$cvId';
    return await _api.get(url);
  }

  Future<Map<String, dynamic>> updateCv({
    required String cvId,
    required String description,
    required List<Map<String, String>> certificates,
  }) async {
    final url = '${ApiConstants.cv}/$cvId';
    final body = {'description': description, 'certificates': certificates};
    return await _api.put(url, body);
  }

  Future<Map<String, dynamic>> deleteCv(String cvId) async {
    final url = '${ApiConstants.cv}/$cvId';
    return await _api.delete(url);
  }
}
