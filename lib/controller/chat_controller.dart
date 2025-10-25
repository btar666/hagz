import 'package:get/get.dart';
import '../service_layer/services/chat_service.dart';
import 'session_controller.dart';

class ChatController extends GetxController {
  final ChatService _service = ChatService();

  // Conversations list
  var conversations = <Map<String, dynamic>>[].obs;
  var isLoadingConversations = false.obs;

  // Current conversation/messages
  var currentConversationId = ''.obs;
  var messages = <Map<String, dynamic>>[].obs;
  var isLoadingMessages = false.obs;
  var isSendingMessage = false.obs;

  // Current receiver (when opening chat from doctor profile)
  var receiverId = ''.obs;
  var receiverName = ''.obs;

  /// Load all conversations
  Future<void> loadConversations() async {
    isLoadingConversations.value = true;
    try {
      final SessionController session = Get.find<SessionController>();
      final currentUser = session.currentUser.value;
      final userRole = session.role.value;

      // For secretary, load conversations with associated doctor
      if (userRole == 'secretary' &&
          currentUser?.associatedDoctor.isNotEmpty == true) {
        print(
          '🔍 Secretary loading conversations with doctor: ${currentUser!.associatedDoctor}',
        );
        await _loadSecretaryConversations(currentUser.associatedDoctor);
      } else {
        // For other roles, load all conversations
        final res = await _service.getConversations();
        if (res['ok'] == true) {
          final data = res['data'];
          List<Map<String, dynamic>> convList = [];
          if (data is Map && data['data'] is List) {
            convList = (data['data'] as List).cast<Map<String, dynamic>>();
          } else if (data is List) {
            convList = data.cast<Map<String, dynamic>>();
          }

          // Extract participant names for each conversation
          await _enrichConversationsWithNames(convList);

          conversations.value = convList;
        }
      }
    } finally {
      isLoadingConversations.value = false;
    }
  }

  /// Load messages for a conversation
  Future<void> loadMessages(String conversationId) async {
    print('=== DEBUG: LoadMessages Called ===');
    print('Conversation ID: $conversationId');
    print('Current Receiver ID: ${receiverId.value}');
    print('Current Receiver Name: ${receiverName.value}');

    currentConversationId.value = conversationId;
    isLoadingMessages.value = true;
    try {
      final res = await _service.getMessages(conversationId: conversationId);
      print('Load messages API response: $res');
      if (res['ok'] == true) {
        final data = res['data'];
        if (data is Map && data['data'] is List) {
          messages.value = (data['data'] as List).cast<Map<String, dynamic>>();
          print('Loaded ${messages.length} messages');

          // Extract receiver info from messages if not already set
          _extractReceiverFromMessages();
        } else if (data is List) {
          messages.value = data.cast<Map<String, dynamic>>();
          print('Loaded ${messages.length} messages (direct list)');

          // Extract receiver info from messages if not already set
          _extractReceiverFromMessages();
        }
      } else {
        print('Failed to load messages: ${res['data']}');
        // For secretary, if conversation loading fails, try to create one
        final SessionController session = Get.find<SessionController>();
        if (session.role.value == 'secretary' && receiverId.value.isNotEmpty) {
          print('🔍 Secretary: Trying to create conversation with doctor...');
          await _createSecretaryConversation();
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      isLoadingMessages.value = false;
      print('=== DEBUG: LoadMessages Finished ===');
    }
  }

  /// Get or create conversation with a doctor and load messages
  Future<void> openDoctorChat(String doctorId, String doctorName) async {
    receiverId.value = doctorId;
    receiverName.value = doctorName;
    isLoadingMessages.value = true;
    try {
      final res = await _service.getDoctorConversation(doctorId: doctorId);
      if (res['ok'] == true) {
        final data = res['data'];
        // Assuming API returns conversation with messages or conversationId
        if (data is Map) {
          final convId =
              data['conversationId']?.toString() ??
              data['_id']?.toString() ??
              '';
          if (convId.isNotEmpty) {
            await loadMessages(convId);
          } else if (data['data'] is List) {
            // If it returns messages directly
            messages.value = (data['data'] as List)
                .cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
    } finally {
      isLoadingMessages.value = false;
    }
  }

  /// Send a message
  Future<bool> sendMessage(String content) async {
    print('=== DEBUG: SendMessage Called ===');
    print('Content: $content');
    print('Receiver ID: ${receiverId.value}');
    print('Receiver Name: ${receiverName.value}');
    print('Current Conversation ID: ${currentConversationId.value}');

    if (content.trim().isEmpty) {
      print('ERROR: Content is empty');
      return false;
    }

    // For secretary, ensure receiverId is set to associated doctor
    final SessionController session = Get.find<SessionController>();
    if (session.role.value == 'secretary') {
      final currentUser = session.currentUser.value;
      if (currentUser?.associatedDoctor.isNotEmpty == true &&
          receiverId.value.isEmpty) {
        receiverId.value = currentUser!.associatedDoctor;
        receiverName.value = 'الطبيب';
        print(
          '🔍 Secretary: Set receiver to associated doctor: ${receiverId.value}',
        );
      }
    }

    if (receiverId.value.isEmpty) {
      print('ERROR: Receiver ID is empty - cannot send message');
      return false;
    }

    isSendingMessage.value = true;

    // Add message locally first for immediate UI update
    final tempMessage = {
      '_id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'content': content.trim(),
      'sender': 'me',
      'isMe': true,
      'createdAt': DateTime.now().toIso8601String(),
      'sending': true, // Flag to show sending state
    };
    messages.add(tempMessage);

    try {
      // Use secretary API if user is secretary
      final SessionController session = Get.find<SessionController>();
      final Map<String, dynamic> res;

      if (session.role.value == 'secretary') {
        res = await _service.sendSecretaryMessage(
          receiverId: receiverId.value,
          content: content.trim(),
        );
      } else {
        res = await _service.sendMessage(
          receiverId: receiverId.value,
          content: content.trim(),
        );
      }

      if (res['ok'] == true) {
        // Remove temp message and reload from server
        messages.removeWhere((m) => m['_id'] == tempMessage['_id']);

        // Add the real message from server response if available
        if (res['data'] != null && res['data']['data'] != null) {
          final newMessage = res['data']['data'];
          messages.add({
            '_id': newMessage['_id']?.toString() ?? '',
            'content': newMessage['content']?.toString() ?? content.trim(),
            'sender': 'me',
            'isMe': true,
            'createdAt':
                newMessage['createdAt']?.toString() ??
                DateTime.now().toIso8601String(),
          });
        } else {
          // If no message data returned, keep temp message but mark as sent
          messages.removeWhere((m) => m['_id'] == tempMessage['_id']);
          tempMessage['_id'] = 'sent_${DateTime.now().millisecondsSinceEpoch}';
          tempMessage.remove('sending');
          messages.add(tempMessage);
        }
        return true;
      } else {
        // Remove temp message on failure
        messages.removeWhere((m) => m['_id'] == tempMessage['_id']);
        return false;
      }
    } catch (e) {
      // Remove temp message on error
      messages.removeWhere((m) => m['_id'] == tempMessage['_id']);
      return false;
    } finally {
      isSendingMessage.value = false;
    }
  }

  /// Delete a message
  Future<bool> deleteMessage(String messageId) async {
    final res = await _service.deleteMessage(messageId: messageId);
    if (res['ok'] == true) {
      // Remove from local list
      messages.removeWhere((m) => m['_id'] == messageId);
      return true;
    }
    return false;
  }

  /// Set receiver ID for direct messaging
  void setReceiverId(String id, {String? name}) {
    receiverId.value = id;
    if (name != null) receiverName.value = name;
  }

  /// Create a conversation for secretary with associated doctor
  Future<void> _createSecretaryConversation() async {
    try {
      print('🔍 Creating secretary conversation...');
      // Send a welcome message to create conversation
      final res = await _service.sendSecretaryMessage(
        receiverId: receiverId.value,
        content: 'مرحباً، أنا السكرتير المساعد لك',
      );

      if (res['ok'] == true) {
        print('✅ Secretary conversation created successfully');
        // Reload conversations
        await _loadSecretaryConversations(receiverId.value);
      } else {
        print('❌ Failed to create secretary conversation: ${res['message']}');
      }
    } catch (e) {
      print('❌ Error creating secretary conversation: $e');
    }
  }

  /// Load conversations for secretary with associated doctor
  Future<void> _loadSecretaryConversations(String doctorId) async {
    try {
      // Use secretary-specific API
      final res = await _service.getSecretaryConversations();
      if (res['ok'] == true) {
        final data = res['data'];
        List<Map<String, dynamic>> convList = [];

        if (data is Map && data['data'] is List) {
          convList = (data['data'] as List).cast<Map<String, dynamic>>();
        } else if (data is List) {
          convList = data.cast<Map<String, dynamic>>();
        }

        // Set receiver info for secretary
        receiverId.value = doctorId;
        receiverName.value = 'الطبيب'; // يمكن تحسين هذا لاحقاً

        conversations.value = convList;
        print('✅ Secretary conversations loaded: ${convList.length}');
      } else {
        print('❌ Failed to load secretary conversations: ${res['message']}');
        conversations.value = [];
      }
    } catch (e) {
      print('❌ Error loading secretary conversations: $e');
      conversations.value = [];
    }
  }

  /// Extract receiver information from loaded messages
  void _extractReceiverFromMessages() {
    if (messages.isEmpty) return;
    if (receiverId.value.isNotEmpty) return; // Already set

    final SessionController session = Get.find<SessionController>();
    final currentUserId = session.currentUser.value?.id ?? '';

    print('=== DEBUG: Extracting receiver from messages ===');
    print('Current User ID: $currentUserId');

    // Look at the first message to determine who the other participant is
    final firstMessage = messages.first;
    final sender = firstMessage['sender'];
    final receiver = firstMessage['receiver'];

    print('First message sender: $sender');
    print('First message receiver: $receiver');

    if (sender is Map && receiver is Map) {
      final senderId = sender['_id']?.toString() ?? '';
      final receiverIdFromMsg = receiver['_id']?.toString() ?? '';
      final senderName = sender['name']?.toString() ?? '';
      final receiverNameFromMsg = receiver['name']?.toString() ?? '';

      print('Sender ID: $senderId, Name: $senderName');
      print('Receiver ID: $receiverIdFromMsg, Name: $receiverNameFromMsg');

      // Set receiverId to the other person (not current user)
      if (senderId == currentUserId) {
        // Current user is sender, so set receiver as the receiverId
        receiverId.value = receiverIdFromMsg;
        receiverName.value = receiverNameFromMsg;
        print(
          'Set receiver as: ID=$receiverIdFromMsg, Name=$receiverNameFromMsg',
        );
      } else {
        // Current user is receiver, so set sender as the receiverId
        receiverId.value = senderId;
        receiverName.value = senderName;
        print('Set sender as: ID=$senderId, Name=$senderName');
      }
    }

    print('Final receiverId: ${receiverId.value}');
    print('Final receiverName: ${receiverName.value}');
    print('=== DEBUG: Receiver extraction finished ===');
  }

  /// Enrich conversations with participant names by loading first message of each
  Future<void> _enrichConversationsWithNames(
    List<Map<String, dynamic>> convList,
  ) async {
    final SessionController session = Get.find<SessionController>();
    final currentUserId = session.currentUser.value?.id ?? '';

    print('=== DEBUG: Enriching conversations with names ===');
    print('Current User ID: $currentUserId');
    print('Number of conversations: ${convList.length}');

    for (int i = 0; i < convList.length; i++) {
      final conv = convList[i];
      final convId = conv['_id']?.toString() ?? '';

      if (convId.isEmpty) continue;

      try {
        // Load first message to get participant info
        final res = await _service.getMessages(conversationId: convId);
        if (res['ok'] == true) {
          final data = res['data'];
          List<Map<String, dynamic>> messages = [];

          if (data is Map && data['data'] is List) {
            messages = (data['data'] as List).cast<Map<String, dynamic>>();
          } else if (data is List) {
            messages = data.cast<Map<String, dynamic>>();
          }

          if (messages.isNotEmpty) {
            final firstMessage = messages.first;
            final sender = firstMessage['sender'];
            final receiver = firstMessage['receiver'];

            if (sender is Map && receiver is Map) {
              final senderId = sender['_id']?.toString() ?? '';
              final receiverId = receiver['_id']?.toString() ?? '';
              final senderName = sender['name']?.toString() ?? '';
              final receiverName = receiver['name']?.toString() ?? '';

              // Set the other participant's name and ID
              if (senderId == currentUserId) {
                // Current user is sender, so show receiver
                conv['participantName'] = receiverName;
                conv['participantId'] = receiverId;
              } else {
                // Current user is receiver, so show sender
                conv['participantName'] = senderName;
                conv['participantId'] = senderId;
              }

              print(
                'Conversation $convId: participant = ${conv['participantName']} (${conv['participantId']})',
              );
            }
          }
        }
      } catch (e) {
        print('Error enriching conversation $convId: $e');
        // Continue with next conversation
      }
    }

    print('=== DEBUG: Finished enriching conversations ===');
  }
}
