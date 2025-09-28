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
    String specialization = '',
    String company = '',
    String deviceToken = '',
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
      'specialization': specialization,
      'company': company,
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
