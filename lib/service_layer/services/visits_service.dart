import 'api_request.dart';
import '../../utils/constants.dart';

class VisitsService {
  final ApiRequest _api = ApiRequest();

  /// إنشاء زيارة جديدة
  Future<Map<String, dynamic>> createVisit({
    required String representative,
    required String doctorName,
    required String doctorSpecialization,
    required String doctorAddress,
    required String doctorPhone,
    required Map<String, double> coordinates,
    required String governorate,
    required String district,
    required String visitStatus,
    String? nonSubscriptionReason,
    String? notes,
    int? visitCount,
  }) async {
    final body = {
      'representative': representative,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'doctorAddress': doctorAddress,
      'doctorPhone': doctorPhone,
      'coordinates': coordinates,
      'governorate': governorate,
      'district': district,
      'visitStatus': visitStatus,
      'nonSubscriptionReason': nonSubscriptionReason ?? '',
      'notes': notes ?? '',
      'visitCount': visitCount ?? 1,
    };

    print('📋 CREATE VISIT URL: ${ApiConstants.visits}');
    print('📋 CREATE VISIT BODY: $body');
    final result = await _api.post(ApiConstants.visits, body);
    print('📋 CREATE VISIT RESPONSE: $result');
    return result;
  }

  /// جلب قائمة الزيارات
  Future<Map<String, dynamic>> getVisits({
    int? page,
    int? limit,
    String? visitStatus,
    String? startDate,
    String? endDate,
    String? governorate,
    String? district,
    String? doctorName,
    String? representativeId,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (visitStatus != null && visitStatus.isNotEmpty) {
      queryParams['visitStatus'] = visitStatus;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }
    if (governorate != null && governorate.isNotEmpty) {
      queryParams['governorate'] = governorate;
    }
    if (district != null && district.isNotEmpty) {
      queryParams['district'] = district;
    }
    if (doctorName != null && doctorName.isNotEmpty) {
      queryParams['doctorName'] = doctorName;
    }
    if (representativeId != null && representativeId.isNotEmpty) {
      queryParams['representativeId'] = representativeId;
    }

    final uri = Uri.parse(
      ApiConstants.visits,
    ).replace(queryParameters: queryParams);
    print('📋 GET VISITS URL: $uri');
    final result = await _api.get(uri.toString());
    print('📋 GET VISITS RESPONSE: $result');
    return result;
  }

  /// جلب زيارات مندوب معين
  Future<Map<String, dynamic>> getRepresentativeVisits({
    required String representativeId,
    int? page,
    int? limit,
    String? visitStatus,
    String? startDate,
    String? endDate,
    String? governorate,
    String? district,
    String? doctorName,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (visitStatus != null && visitStatus.isNotEmpty) {
      queryParams['visitStatus'] = visitStatus;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }
    if (governorate != null && governorate.isNotEmpty) {
      queryParams['governorate'] = governorate;
    }
    if (district != null && district.isNotEmpty) {
      queryParams['district'] = district;
    }
    if (doctorName != null && doctorName.isNotEmpty) {
      queryParams['doctorName'] = doctorName;
    }

    final uri = Uri.parse(
      '${ApiConstants.representatives}/$representativeId/visits',
    ).replace(queryParameters: queryParams);
    print('📋 GET REPRESENTATIVE VISITS URL: $uri');
    final result = await _api.get(uri.toString());
    print('📋 GET REPRESENTATIVE VISITS RESPONSE: $result');
    return result;
  }

  /// تحديث زيارة
  Future<Map<String, dynamic>> updateVisit({
    required String visitId,
    String? doctorName,
    String? doctorSpecialization,
    String? doctorAddress,
    String? doctorPhone,
    Map<String, double>? coordinates,
    String? governorate,
    String? district,
    String? visitStatus,
    String? nonSubscriptionReason,
    String? notes,
    int? visitCount,
  }) async {
    final body = <String, dynamic>{};
    if (doctorName != null) body['doctorName'] = doctorName;
    if (doctorSpecialization != null) {
      body['doctorSpecialization'] = doctorSpecialization;
    }
    if (doctorAddress != null) body['doctorAddress'] = doctorAddress;
    if (doctorPhone != null) body['doctorPhone'] = doctorPhone;
    if (coordinates != null) body['coordinates'] = coordinates;
    if (governorate != null) body['governorate'] = governorate;
    if (district != null) body['district'] = district;
    if (visitStatus != null) body['visitStatus'] = visitStatus;
    if (nonSubscriptionReason != null) {
      body['nonSubscriptionReason'] = nonSubscriptionReason;
    }
    if (notes != null) body['notes'] = notes;
    if (visitCount != null) body['visitCount'] = visitCount;

    final url = '${ApiConstants.visits}/$visitId';
    print('📋 UPDATE VISIT URL: $url');
    print('📋 UPDATE VISIT BODY: $body');
    final result = await _api.put(url, body);
    print('📋 UPDATE VISIT RESPONSE: $result');
    return result;
  }

  /// حذف زيارة
  Future<Map<String, dynamic>> deleteVisit(String visitId) async {
    final url = '${ApiConstants.visits}/$visitId';
    print('📋 DELETE VISIT URL: $url');
    final result = await _api.delete(url);
    print('📋 DELETE VISIT RESPONSE: $result');
    return result;
  }

  /// جلب إحصائيات الزيارات
  Future<Map<String, dynamic>> getVisitsStats({
    String? representativeId,
    String? startDate,
    String? endDate,
    String? governorate,
  }) async {
    final queryParams = <String, String>{};
    if (representativeId != null && representativeId.isNotEmpty) {
      queryParams['representativeId'] = representativeId;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }
    if (governorate != null && governorate.isNotEmpty) {
      queryParams['governorate'] = governorate;
    }

    final uri = Uri.parse(
      ApiConstants.visitsStats,
    ).replace(queryParameters: queryParams);
    print('📋 GET VISITS STATS URL: $uri');
    final result = await _api.get(uri.toString());
    print('📋 GET VISITS STATS RESPONSE: $result');
    return result;
  }

  /// جلب الزيارات حسب المحافظة
  Future<Map<String, dynamic>> getVisitsByGovernorate({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    final uri = Uri.parse(
      ApiConstants.visitsByGovernorate,
    ).replace(queryParameters: queryParams);
    print('📋 GET VISITS BY GOVERNORATE URL: $uri');
    final result = await _api.get(uri.toString());
    print('📋 GET VISITS BY GOVERNORATE RESPONSE: $result');
    return result;
  }

  /// جلب الزيارات حسب المندوب
  Future<Map<String, dynamic>> getVisitsByRepresentative({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    final uri = Uri.parse(
      ApiConstants.visitsByRepresentative,
    ).replace(queryParameters: queryParams);
    print('📋 GET VISITS BY REPRESENTATIVE URL: $uri');
    final result = await _api.get(uri.toString());
    print('📋 GET VISITS BY REPRESENTATIVE RESPONSE: $result');
    return result;
  }
}
