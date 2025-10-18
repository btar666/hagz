import '../../utils/constants.dart';
import 'api_request.dart';

class RatingsService {
  final ApiRequest _api = ApiRequest();

  // POST /api/ratings/
  Future<Map<String, dynamic>> createRating({
    required String appointmentId,
    required int rating,
    String? comment,
  }) async {
    final body = {
      'appointment': appointmentId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    return await _api.post(ApiConstants.ratings + '/', body);
  }

  // PUT /api/ratings/{id}
  Future<Map<String, dynamic>> updateRating({
    required String id,
    required int rating,
    String? comment,
  }) async {
    final body = {
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    return await _api.put('${ApiConstants.ratings}/$id', body);
  }

  // DELETE /api/ratings/{id}
  Future<Map<String, dynamic>> deleteRating(String id) async {
    return await _api.delete('${ApiConstants.ratings}/$id');
  }

  // GET /api/ratings/doctor/{doctorId}
  Future<Map<String, dynamic>> getDoctorRatings(String doctorId, {int? page, int? limit}) async {
    String url = '${ApiConstants.ratings}/doctor/$doctorId';
    final qs = <String>[];
    if (page != null) qs.add('page=$page');
    if (limit != null) qs.add('limit=$limit');
    if (qs.isNotEmpty) url += '?${qs.join('&')}';
    return await _api.get(url);
  }

  // GET /api/ratings/appointment/{appointmentId}
  Future<Map<String, dynamic>> getByAppointment(String appointmentId) async {
    final url = '${ApiConstants.ratings}/appointment/$appointmentId';
    return await _api.get(url);
  }

  // GET /api/ratings/top-doctors
  Future<Map<String, dynamic>> getTopDoctors({int? page, int? limit}) async {
    String url = '${ApiConstants.ratings}/top-doctors';
    final qs = <String>[];
    if (page != null) qs.add('page=$page');
    if (limit != null) qs.add('limit=$limit');
    if (qs.isNotEmpty) url += '?${qs.join('&')}';
    return await _api.get(url);
  }

  // GET /api/ratings/my-ratings
  Future<Map<String, dynamic>> getMyRatings({int? page, int? limit}) async {
    String url = '${ApiConstants.ratings}/my-ratings';
    final qs = <String>[];
    if (page != null) qs.add('page=$page');
    if (limit != null) qs.add('limit=$limit');
    if (qs.isNotEmpty) url += '?${qs.join('&')}';
    return await _api.get(url);
  }

  // POST /api/ratings/recalculate/{doctorId}
  Future<Map<String, dynamic>> recalcDoctor(String doctorId) async {
    final url = '${ApiConstants.ratings}/recalculate/$doctorId';
    return await _api.post(url, {});
  }
}
