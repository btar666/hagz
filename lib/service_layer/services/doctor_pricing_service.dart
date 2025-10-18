import '../../utils/constants.dart';
import 'api_request.dart';

class DoctorPricingService {
  final ApiRequest _api = ApiRequest();

  /// POST /api/doctor-pricing/create-or-update
  /// Creates or updates doctor pricing
  Future<Map<String, dynamic>> createOrUpdatePricing({
    required String doctorId,
    required double defaultPrice,
    String currency = 'IQ',
  }) async {
    final url = '${ApiConstants.doctorPricing}/create-or-update';
    final body = {
      'doctorId': doctorId,
      'defaultPrice': defaultPrice,
      'currency': currency,
    };
    return await _api.post(url, body);
  }

  /// GET /api/doctor-pricing/doctor/{doctorId}
  /// Gets pricing for a specific doctor
  Future<Map<String, dynamic>> getPricingByDoctorId(String doctorId) async {
    final url = '${ApiConstants.doctorPricing}/doctor/$doctorId';
    return await _api.get(url);
  }

  /// GET /api/doctor-pricing/doctor/{doctorId}/default
  /// Gets default pricing for a specific doctor
  Future<Map<String, dynamic>> getDefaultPricing(String doctorId) async {
    final url = '${ApiConstants.doctorPricing}/doctor/$doctorId/default';
    return await _api.get(url);
  }

  /// GET /api/doctor-pricing/all
  /// Gets all pricing records (with optional pagination)
  Future<Map<String, dynamic>> getAllPricing({
    String? page,
    String? limit,
  }) async {
    String url = '${ApiConstants.doctorPricing}/all';
    final params = <String>[];
    if (page != null && page.isNotEmpty) params.add('page=$page');
    if (limit != null && limit.isNotEmpty) params.add('limit=$limit');
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    return await _api.get(url);
  }
}
