import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../controller/session_controller.dart';

class ApiRequest {
  final SessionController _session = Get.find<SessionController>();

  // Default network timeout for all requests
  static const Duration _timeout = Duration(seconds: 12);

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
    try {
      final res = await http
          .get(
            Uri.parse(url),
            headers: _headers(extra: headers),
          )
          .timeout(_timeout);
      return _decode(res);
    } on TimeoutException catch (e) {
      return _timeoutError(url, e);
    } on SocketException catch (e) {
      return _networkError(url, e);
    } catch (e) {
      return _unknownError(url, e);
    }
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: _headers(extra: headers),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decode(res);
    } on TimeoutException catch (e) {
      return _timeoutError(url, e);
    } on SocketException catch (e) {
      return _networkError(url, e);
    } catch (e) {
      return _unknownError(url, e);
    }
  }

  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final res = await http
          .put(
            Uri.parse(url),
            headers: _headers(extra: headers),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decode(res);
    } on TimeoutException catch (e) {
      return _timeoutError(url, e);
    } on SocketException catch (e) {
      return _networkError(url, e);
    } catch (e) {
      return _unknownError(url, e);
    }
  }

  Future<Map<String, dynamic>> patch(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final res = await http
          .patch(
            Uri.parse(url),
            headers: _headers(extra: headers),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decode(res);
    } on TimeoutException catch (e) {
      return _timeoutError(url, e);
    } on SocketException catch (e) {
      return _networkError(url, e);
    } catch (e) {
      return _unknownError(url, e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final finalHeaders = _headers(extra: headers);
      print('🔐 DELETE HEADERS: $finalHeaders');
      final res = await http
          .delete(
            Uri.parse(url),
            headers: finalHeaders,
          )
          .timeout(_timeout);
      print('📥 DELETE STATUS CODE: ${res.statusCode}');
      print('📥 DELETE BODY: ${res.body}');
      return _decode(res);
    } on TimeoutException catch (e) {
      return _timeoutError(url, e);
    } on SocketException catch (e) {
      return _networkError(url, e);
    } catch (e) {
      return _unknownError(url, e);
    }
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

  Map<String, dynamic> _timeoutError(String url, TimeoutException e) {
    return {
      'statusCode': 0,
      'ok': false,
      'data': {
        'message': 'Request timed out',
        'url': url,
        'type': 'timeout',
        'error': e.toString(),
      },
    };
  }

  Map<String, dynamic> _networkError(String url, SocketException e) {
    return {
      'statusCode': 0,
      'ok': false,
      'data': {
        'message': 'Network error',
        'url': url,
        'type': 'network',
        'error': e.toString(),
      },
    };
  }

  Map<String, dynamic> _unknownError(String url, Object e) {
    return {
      'statusCode': 0,
      'ok': false,
      'data': {
        'message': 'Unknown error',
        'url': url,
        'type': 'unknown',
        'error': e.toString(),
      },
    };
  }
}
