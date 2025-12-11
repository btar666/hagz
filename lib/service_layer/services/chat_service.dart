import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../utils/constants.dart';
import '../../controller/session_controller.dart';
import 'api_request.dart';
import 'socket_service.dart';

class ChatService {
  final ApiRequest _api = ApiRequest();
  final SocketService _socketService = SocketService();

  /// Send a message to a receiver using Socket.IO
  /// Note: This uses WebSocket for real-time delivery. The response is immediate
  /// but the actual message object will be received via Socket.IO events.
  Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    // Ensure socket is connected
    if (!_socketService.isConnected) {
      await _socketService.connect();
    }

    // Send via Socket.IO
    _socketService.sendMessage(
      receiverId: receiverId,
      content: content,
    );

    // Return success immediately (actual message will come via Socket.IO event)
    return {
      'ok': true,
      'statusCode': 200,
      'data': {
        'message': 'Message sent',
        'receiverId': receiverId,
      },
    };
  }

  /// GET /api/chats/conversations
  /// Get all conversations for current user
  Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final url = '${ApiConstants.chatConversations}?page=$page&limit=$limit';
    return await _api.get(url);
  }

  /// GET /api/chats/conversations/{conversationId}/messages
  /// Get messages for a specific conversation
  Future<Map<String, dynamic>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    final url =
        '${ApiConstants.chatMessages}/$conversationId/messages?page=$page&limit=$limit';
    return await _api.get(url);
  }

  /// DELETE /api/chats/messages/{messageId}
  /// Delete a message
  Future<Map<String, dynamic>> deleteMessage({
    required String messageId,
  }) async {
    final url = '${ApiConstants.chatDeleteMessage}/$messageId';
    return await _api.delete(url);
  }

  /// GET /api/chats/doctor/{doctorId}/conversations
  /// Get or create conversation with a specific doctor
  Future<Map<String, dynamic>> getDoctorConversation({
    required String doctorId,
    int page = 1,
    int limit = 20,
  }) async {
    final url =
        '${ApiConstants.chatDoctorConversations}/$doctorId/conversations?page=$page&limit=$limit';
    return await _api.get(url);
  }

  /// Send a message as secretary using Socket.IO
  /// Note: This uses WebSocket for real-time delivery. The response is immediate
  /// but the actual message object will be received via Socket.IO events.
  Future<Map<String, dynamic>> sendSecretaryMessage({
    required String receiverId,
    required String content,
  }) async {
    // Ensure socket is connected
    if (!_socketService.isConnected) {
      await _socketService.connect();
    }

    // Send via Socket.IO
    _socketService.sendMessageAsSecretary(
      receiverId: receiverId,
      content: content,
    );

    // Return success immediately (actual message will come via Socket.IO event)
    return {
      'ok': true,
      'statusCode': 200,
      'data': {
        'message': 'Message sent',
        'receiverId': receiverId,
      },
    };
  }

  /// GET /api/chats/secretary/conversations
  /// Get secretary conversations (with associated doctor)
  Future<Map<String, dynamic>> getSecretaryConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final url =
        '${ApiConstants.chatSecretaryConversations}?page=$page&limit=$limit';
    return await _api.get(url);
  }

  /// Send a message with image
  /// First uploads image via REST API, then sends message via Socket.IO
  Future<Map<String, dynamic>> sendMessageWithImage({
    required String receiverId,
    required File imageFile,
    String? content,
  }) async {
    try {
      final uri = Uri.parse(ApiConstants.chatSend);
      final request = http.MultipartRequest('POST', uri);

      // Add receiverId as form field
      request.fields['receiverId'] = receiverId;

      // Add content if provided
      if (content != null && content.trim().isNotEmpty) {
        request.fields['content'] = content.trim();
      }

      // Add image file
      final String ext = imageFile.path.split('.').last.toLowerCase();
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
        };
      }
      final subType = allowed[ext] ?? 'jpeg';
      final mediaType = MediaType('image', subType);
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: mediaType,
        ),
      );

      // Add headers
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
      };
    } catch (e) {
      return {
        'ok': false,
        'statusCode': 0,
        'data': {'message': 'Error sending image: $e'},
      };
    }
  }

  /// POST /api/chats/secretary/send
  /// Send a message with image as secretary using multipart/form-data
  Future<Map<String, dynamic>> sendSecretaryMessageWithImage({
    required String receiverId,
    required File imageFile,
    String? content,
  }) async {
    try {
      final uri = Uri.parse(ApiConstants.chatSecretarySend);
      final request = http.MultipartRequest('POST', uri);

      // Add receiverId as form field
      request.fields['receiverId'] = receiverId;

      // Add content if provided
      if (content != null && content.trim().isNotEmpty) {
        request.fields['content'] = content.trim();
      }

      // Add image file
      final String ext = imageFile.path.split('.').last.toLowerCase();
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
        };
      }
      final subType = allowed[ext] ?? 'jpeg';
      final mediaType = MediaType('image', subType);
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: mediaType,
        ),
      );

      // Add headers
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
      };
    } catch (e) {
      return {
        'ok': false,
        'statusCode': 0,
        'data': {'message': 'Error sending image: $e'},
      };
    }
  }
}
