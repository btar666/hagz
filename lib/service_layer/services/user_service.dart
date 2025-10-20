import 'package:get/get.dart';

import '../../controller/session_controller.dart';
import '../../utils/constants.dart';
import '../../model/user_model.dart';
import 'api_request.dart';

class UserService {
  final ApiRequest _api = ApiRequest();
  final SessionController _session = Get.find<SessionController>();

  Future<Map<String, dynamic>> getUserInfo() async {
    final res = await _api.get(ApiConstants.userInfo);
    if (res['ok'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      try {
        final userJson = (data['user'] as Map<String, dynamic>?) ?? data;
        final user = UserModel.fromJson(userJson);
        _session.setCurrentUser(user);
      } catch (_) {}
    }
    return res;
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final body = {'oldPassword': oldPassword, 'newPassword': newPassword};
    final res = await _api.put(ApiConstants.changePassword, body);
    return res;
  }

  Future<Map<String, dynamic>> getDoctors({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search.trim().isNotEmpty) params['search'] = search.trim();

    final uri = Uri.parse(
      ApiConstants.doctors,
    ).replace(queryParameters: params);
    final res = await _api.get(uri.toString());
    return res;
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    final url = '${ApiConstants.baseUrl}/api/users/$userId';
    final res = await _api.get(url);
    return res;
  }

  Future<Map<String, dynamic>> updateUserInfo({
    required String name,
    required String city,
    required String phone,
    required String gender,
    required int age,
    String? specialization,
    String? company,
    String? deviceToken,
    Map<String, String>? socialMedia,
  }) async {
    final Map<String, dynamic> body = {
      'name': name,
      'city': city,
      'phone': phone,
      'gender': gender,
      'age': age,
    };
    
    // Add optional fields if provided
    if (specialization != null && specialization.isNotEmpty) {
      body['specialization'] = specialization;
    }
    if (company != null && company.isNotEmpty) {
      body['company'] = company;
    }
    if (deviceToken != null && deviceToken.isNotEmpty) {
      body['deviceToken'] = deviceToken;
    }
    if (socialMedia != null && socialMedia.isNotEmpty) {
      body['socialMedia'] = socialMedia;
    }
    
    final res = await _api.put(ApiConstants.userInfo, body);
    return res;
  }

  /// Updates only social media info (Facebook, Instagram, WhatsApp).
  Future<Map<String, dynamic>> updateSocialMedia({
    String? facebook,
    String? instagram,
    String? whatsapp,
  }) async {
    final Map<String, String> socialMediaMap = {};
    if (facebook != null && facebook.isNotEmpty) socialMediaMap['facebook'] = facebook;
    if (instagram != null && instagram.isNotEmpty) socialMediaMap['instagram'] = instagram;
    if (whatsapp != null && whatsapp.isNotEmpty) socialMediaMap['whatsapp'] = whatsapp;

    final body = {
      'socialMedia': socialMediaMap,
    };
    final res = await _api.put(ApiConstants.userInfo, body);
    return res;
  }
}
