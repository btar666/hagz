import '../../utils/constants.dart';
import 'api_request.dart';

class OpinionService {
  final ApiRequest _api = ApiRequest();

  Future<Map<String, dynamic>> getOpinionsByTarget(String targetId) async {
    final url = '${ApiConstants.opinions}target/$targetId';
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
}
