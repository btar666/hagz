import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../utils/constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final uri = Uri.parse(ApiConstants.login);
    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    final decoded = _decodeBody(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'ok': true, 'data': decoded};
    }
    return {
      'ok': false,
      'error': decoded['message'] ?? 'فشل تسجيل الدخول',
      'data': decoded,
    };
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phone,
    required String password,
    required String gender,
    required int age,
    required String city,
    required String userType,
    String specializationId = '',
    String company = '',
    String deviceToken = '',
    String image = '',
    String address = '',
    String region = '', // المنطقة
    String district = '', // المنطقة (اسم الحقل في API)
    String certificate = '',
    String idFrontImage = '',
    String idBackImage = '',
  }) async {
    final uri = Uri.parse(ApiConstants.register);
    final payload = {
      'name': name,
      'phone': phone,
      'password': password,
      'gender': gender,
      'age': age,
      'city': city,
      'userType': userType,
      if (specializationId.isNotEmpty) 'specialization': specializationId,
      if (company.isNotEmpty) 'company': company,
      if (deviceToken.isNotEmpty) 'deviceToken': deviceToken,
      if (image.isNotEmpty) 'image': image,
      if (address.isNotEmpty) 'address': address,
      if (district.isNotEmpty) 'district': district, // المنطقة (اسم الحقل في API)
      if (certificate.isNotEmpty) 'certificate': certificate,
      if (idFrontImage.isNotEmpty) 'idFrontImage': idFrontImage,
      if (idBackImage.isNotEmpty) 'idBackImage': idBackImage,
    };

    // Print API request details
    print('🌐 ========== API REGISTER USER REQUEST ==========');
    print('🌐 URL: $uri');
    print('🌐 Method: POST');
    print('🌐 Headers: Content-Type: application/json, Accept: application/json');
    print('🌐 Payload (without password):');
    final payloadForLog = Map<String, dynamic>.from(payload);
    payloadForLog['password'] = '[HIDDEN]';
    print('🌐 ${jsonEncode(payloadForLog)}');
    print('🌐 ================================================');

    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    // Print API response details
    print('🌐 ========== API REGISTER USER RESPONSE ==========');
    print('🌐 Status Code: ${response.statusCode}');
    print('🌐 Response Headers: ${response.headers}');
    print('🌐 Response Body: ${response.body}');
    print('🌐 ================================================');

    final decoded = _decodeBody(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'ok': true, 'statusCode': response.statusCode, 'data': decoded};
    }
    return {
      'ok': false,
      'statusCode': response.statusCode,
      'error': decoded['message'] ?? 'فشل إنشاء الحساب',
      'data': decoded,
    };
  }

  Future<Map<String, dynamic>> registerDelegate({
    required String name,
    required String phone,
    required String password,
    required int age,
    String gender = '',
    String city = '',
    String company = '',
    String certificate = '',
    String idFrontImage = '',
    String idBackImage = '',
    String deviceToken = '',
  }) async {
    final uri = Uri.parse(ApiConstants.register);
    final payload = {
      'name': name,
      'phone': phone,
      'password': password,
      'age': age,
      'userType': 'Representative',
      'gender': gender,
      'city': city,
      'company': company,
      'certificate': certificate,
      'idFrontImage': idFrontImage,
      'idBackImage': idBackImage,
      'deviceToken': deviceToken,
    };

    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    final decoded = _decodeBody(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'ok': true, 'data': decoded};
    }
    return {
      'ok': false,
      'error': decoded['message'] ?? 'فشل إنشاء الحساب',
      'data': decoded,
    };
  }

  Map<String, dynamic> _decodeBody(List<int> bodyBytes) {
    try {
      return jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      return {'raw': utf8.decode(bodyBytes)};
    }
  }
}
