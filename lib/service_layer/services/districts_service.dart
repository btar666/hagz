import '../../utils/constants.dart';
import 'api_request.dart';

class DistrictsService {
  final ApiRequest _api = ApiRequest();

  /// جلب قائمة المناطق النشطة حسب المدينة
  /// GET /api/districts/city/{city}/active
  Future<Map<String, dynamic>> getDistrictsByCity({
    required String city,
    int? page,
    int? limit,
  }) async {
    var url = ApiConstants.getDistrictsByCity(city);

    // إضافة query parameters
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();

    if (params.isNotEmpty) {
      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url = '$url?$queryString';
    }

    print('📍 GET DISTRICTS BY CITY URL: $url');
    final res = await _api.get(url);
    print('📍 GET DISTRICTS BY CITY RESPONSE: $res');
    return res;
  }
}

