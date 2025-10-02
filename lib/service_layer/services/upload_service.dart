import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import '../../utils/constants.dart';
import '../../controller/session_controller.dart';

class UploadService {
  Future<Map<String, dynamic>> uploadImage(File file) async {
    final uri = Uri.parse(ApiConstants.uploads);
    final request = http.MultipartRequest('POST', uri);
    // Infer content-type from extension (server allows only image types)
    final String ext = file.path.split('.').last.toLowerCase();
    final Map<String, String> allowed = {
      'jpg': 'jpeg',
      'jpeg': 'jpeg',
      'png': 'png',
      'gif': 'gif',
      'webp': 'webp',
      'bmp': 'bmp',
      'heic': 'heic',
    };
    if (!allowed.containsKey(ext)) {
      return {
        'ok': false,
        'statusCode': 400,
        'data': {'message': 'only image files are allowed'},
        'message': 'only image files are allowed',
      };
    }
    final subType = allowed[ext] ?? 'jpeg';
    final mediaType = MediaType('image', subType);
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        file.path,
        contentType: mediaType,
      ),
    );
    request.headers['Accept'] = 'application/json';
    try {
      final SessionController session = Get.find<SessionController>();
      final token = session.token.value;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    Map<String, dynamic> decoded = {};
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      decoded = {'raw': response.body};
    }
    final bool apiStatus = (decoded['status'] as bool?) ?? ok;
    return {
      'ok': ok && apiStatus,
      'statusCode': response.statusCode,
      'data': decoded,
      'message': (decoded['message'] ?? '').toString(),
    };
  }
}
