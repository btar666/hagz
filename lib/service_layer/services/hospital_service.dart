import '../../utils/constants.dart';
import 'api_request.dart';

class HospitalService {
  final ApiRequest _api = ApiRequest();

  Future<Map<String, dynamic>> getHospitals({String? query}) async {
    var url = ApiConstants.hospitals;
    if (query != null && query.isNotEmpty) {
      url = '$url?query=${Uri.encodeComponent(query)}';
    }
    final res = await _api.get(url);
    return res;
  }

  Future<Map<String, dynamic>> getHospitalById(String id) async {
    final url = '${ApiConstants.hospitals}$id';
    final res = await _api.get(url);
    return res;
  }

  /// جلب قائمة الأطباء في مستشفى محدد
  Future<Map<String, dynamic>> getHospitalDoctors({
    required String hospitalId,
    String? search,
    String? specialization,
    String? city,
    String? sortBy,
    String? order,
    int? limit,
  }) async {
    var url = '${ApiConstants.hospitals}$hospitalId/doctors';

    // إضافة query parameters
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (specialization != null && specialization.isNotEmpty)
      params['specialization'] = specialization;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (sortBy != null && sortBy.isNotEmpty) params['sortBy'] = sortBy;
    if (order != null && order.isNotEmpty) params['order'] = order;
    if (limit != null) params['limit'] = limit.toString();

    if (params.isNotEmpty) {
      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url = '$url?$queryString';
    }

    print('🏥 GET HOSPITAL DOCTORS URL: $url');
    final res = await _api.get(url);
    print('🏥 GET HOSPITAL DOCTORS RESPONSE: $res');
    return res;
  }

  /// البحث الشامل في المستشفيات والأطباء (يستخدم GET /api/hospitals/search)
  Future<Map<String, dynamic>> searchHospitalsAndDoctors({
    String? searchQuery,
    String? city,
    String? specialization,
    int? page,
    int? limit,
  }) async {
    var url = '${ApiConstants.hospitals}search';

    // إضافة query parameters
    final params = <String, String>{};
    if (searchQuery != null && searchQuery.isNotEmpty)
      params['search'] = searchQuery; // تغيير من 'query' إلى 'search'
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (specialization != null && specialization.isNotEmpty)
      params['specialization'] = specialization;
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();

    if (params.isNotEmpty) {
      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url = '$url?$queryString';
    }

    print('🔍 SEARCH HOSPITALS URL: $url');
    final res = await _api.get(url);
    print('🔍 SEARCH HOSPITALS RESPONSE: $res');
    return res;
  }
}
