import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../controller/session_controller.dart';

class ApiRequest {
  final SessionController _session = Get.find<SessionController>();

  Map<String, String> _headers({Map<String, String>? extra}) {
    final Map<String, String> base = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final String? token = _session.token.value;
    if (token != null && token.isNotEmpty) {
      base['Authorization'] = 'Bearer $token'; // إرسال الـ token مع Bearer
    }
    if (extra != null) base.addAll(extra);
    return base;
  }

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final res = await http.get(
      Uri.parse(url),
      headers: _headers(extra: headers),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final res = await http.post(
      Uri.parse(url),
      headers: _headers(extra: headers),
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final res = await http.put(
      Uri.parse(url),
      headers: _headers(extra: headers),
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> patch(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final res = await http.patch(
      Uri.parse(url),
      headers: _headers(extra: headers),
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    final finalHeaders = _headers(extra: headers);
    print('🔐 DELETE HEADERS: $finalHeaders');
    final res = await http.delete(Uri.parse(url), headers: finalHeaders);
    print('📥 DELETE STATUS CODE: ${res.statusCode}');
    print('📥 DELETE BODY: ${res.body}');
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    final decoded = _safeDecode(res.bodyBytes);
    return {
      'statusCode': res.statusCode,
      'ok': res.statusCode >= 200 && res.statusCode < 300,
      'data': decoded,
    };
  }

  Map<String, dynamic> _safeDecode(List<int> bytes) {
    try {
      final json = jsonDecode(utf8.decode(bytes));
      if (json is Map<String, dynamic>) return json;
      return {'data': json};
    } catch (_) {
      return {'raw': utf8.decode(bytes)};
    }
  }
}
