import 'package:get/get.dart';

import '../../controller/session_controller.dart';
import '../../utils/constants.dart';
import '../../model/user_model.dart';
import 'api_request.dart';

class UserService {
  final ApiRequest _api = ApiRequest();
  final SessionController _session = Get.find<SessionController>();

  Future<Map<String, dynamic>> getUserInfo() async {
    print('📋 GET USER INFO REQUEST: ${ApiConstants.userInfo}');
    print('📋 Token: ${_session.token.value}');

    final res = await _api.get(ApiConstants.userInfo);

    print('📋 GET USER INFO RESPONSE: $res');

    if (res['ok'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      print('📋 USER DATA: $data');
      try {
        final userJson = (data['user'] as Map<String, dynamic>?) ?? data;
        print('📋 USER JSON: $userJson');
        final user = UserModel.fromJson(userJson);
        _session.setCurrentUser(user);
        print('📋 USER MODEL CREATED: ${user.name} - ${user.id}');
      } catch (e) {
        print('📋 ERROR PARSING USER: $e');
      }
    } else {
      print('📋 GET USER INFO FAILED: ${res['message']}');
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
    String? specializationId,
    String? company,
    String? deviceToken,
    Map<String, String>? socialMedia,
    String? image,
    String? address,
  }) async {
    final Map<String, dynamic> body = {
      'name': name,
      'city': city,
      'phone': phone,
      'gender': gender,
      'age': age,
    };

    // Add optional fields if provided
    if (specializationId != null && specializationId.isNotEmpty) {
      // Try both field names to ensure compatibility
      body['specialization'] = specializationId;
      body['specializationId'] = specializationId;
      print('✅ Adding specialization/Id to body: $specializationId');
    } else {
      print('⚠️ specializationId is null or empty: $specializationId');
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
    if (image != null && image.isNotEmpty) {
      body['image'] = image;
    }
    if (address != null && address.isNotEmpty) {
      body['address'] = address;
    }

    print('📤 UPDATE USER INFO REQUEST BODY:');
    print('URL: ${ApiConstants.userInfo}');
    print('Body: $body');

    final res = await _api.put(ApiConstants.userInfo, body);

    print('📥 UPDATE USER INFO SERVICE RESPONSE:');
    print('Response: $res');

    return res;
  }

  /// Updates only social media info (Facebook, Instagram, WhatsApp).
  Future<Map<String, dynamic>> updateSocialMedia({
    String? facebook,
    String? instagram,
    String? whatsapp,
  }) async {
    final Map<String, String> socialMediaMap = {};
    if (facebook != null && facebook.isNotEmpty)
      socialMediaMap['facebook'] = facebook;
    if (instagram != null && instagram.isNotEmpty)
      socialMediaMap['instagram'] = instagram;
    if (whatsapp != null && whatsapp.isNotEmpty)
      socialMediaMap['whatsapp'] = whatsapp;

    final body = {'socialMedia': socialMediaMap};
    final res = await _api.put(ApiConstants.userInfo, body);
    return res;
  }

  /// Update only profile image
  Future<Map<String, dynamic>> updateProfileImage(String imageUrl) async {
    final body = {'image': imageUrl};
    final res = await _api.put(ApiConstants.userInfo, body);
    return res;
  }
}
