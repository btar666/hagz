import '../../utils/constants.dart';
import 'api_request.dart';

class OpinionService {
  final ApiRequest _api = ApiRequest();

  Future<Map<String, dynamic>> getOpinionsByTarget(String targetId) async {
    final url = '${ApiConstants.opinions}target/$targetId';
    // بعض السرفرات تتطلب Authorization حتى للمنشور؛ ApiRequest يضيفها تلقائياً إن وجدت
    return await _api.get(url);
  }

  Future<Map<String, dynamic>> getDoctorOpinions() async {
    // Requires Authorization header (handled by ApiRequest)
    final url = '${ApiConstants.opinions}doctor/';
    return await _api.get(url);
  }

  Future<Map<String, dynamic>> getOpinionById(String id) async {
    final url = '${ApiConstants.opinions}$id';
    return await _api.get(url);
  }

  Future<Map<String, dynamic>> addOpinion({
    required String userId,
    required String targetId,
    required String targetModel,
    required String comment,
  }) async {
    final body = {
      'user': userId,
      'target': targetId,
      'targetModel': targetModel,
      'comment': comment,
    };
    return await _api.post(ApiConstants.opinions, body);
  }

  Future<Map<String, dynamic>> updateOpinion({
    required String id,
    String? name,
    String? image,
    String? comment,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (image != null) body['image'] = image;
    if (comment != null) body['comment'] = comment;
    final url = '${ApiConstants.opinions}$id';
    return await _api.put(url, body);
  }

  Future<Map<String, dynamic>> deleteOpinion(String id) async {
    final url = '${ApiConstants.opinions}$id';
    return await _api.delete(url);
  }

  Future<Map<String, dynamic>> patchOpinionStatus({
    required String id,
    required String status, // 'puplish' | 'hidden' (or 'publish')
  }) async {
    final url = '${ApiConstants.opinions}$id/status';
    // API docs show key 'stuats' with typo; send both to be safe
    final body = {
      'stuats': status,
      'status': status, // fallback for servers expecting 'status'
    };
    return await _api.patch(url, body);
  }
}
