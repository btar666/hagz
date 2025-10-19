import '../../utils/constants.dart';
import 'api_request.dart';

class ChatService {
  final ApiRequest _api = ApiRequest();

  /// POST /api/chats/send
  /// Send a message to a receiver
  Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    return await _api.post(ApiConstants.chatSend, {
      'receiverId': receiverId,
      'content': content,
    });
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
    final url = '${ApiConstants.chatMessages}/$conversationId/messages?page=$page&limit=$limit';
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
    final url = '${ApiConstants.chatDoctorConversations}/$doctorId/conversations?page=$page&limit=$limit';
    return await _api.get(url);
  }
}
