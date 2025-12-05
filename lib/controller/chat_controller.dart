import 'package:get/get.dart';
import '../service_layer/services/chat_service.dart';
import '../service_layer/services/user_service.dart';
import 'session_controller.dart';

class ChatController extends GetxController {
  final ChatService _service = ChatService();
  final UserService _userService = UserService();

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

  // Cache for user images (userId -> imageUrl)
  final Map<String, String> _userImageCache = {};
  final Map<String, bool> _loadingUserImages = {};

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

          // Filter conversations based on user role
          if (userRole == 'user') {
            // For users/patients: show only conversations with doctors (not secretaries)
            convList = convList.where((conv) {
              return _isConversationWithType(conv, currentUser?.id ?? '', 'doctor');
            }).toList();
            
            print('✅ Filtered conversations for user: ${convList.length} doctor conversations');
          } else if (userRole == 'doctor') {
            // For doctors: show only conversations with patients/users (not other doctors or secretaries)
            convList = convList.where((conv) {
              return _isConversationWithType(conv, currentUser?.id ?? '', 'user');
            }).toList();
            
            print('✅ Filtered conversations for doctor: ${convList.length} patient conversations');
          }
          // For secretary: already handled by _loadSecretaryConversations above

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
    print('Current Conversation ID: ${currentConversationId.value}');
    print('Current Receiver ID: ${receiverId.value}');
    print('Current Receiver Name: ${receiverName.value}');

    // Clear previous messages only if switching to a different conversation
    final isDifferentConversation =
        currentConversationId.value != conversationId;
    if (isDifferentConversation) {
      messages.clear();
      print('🔄 Cleared previous messages (switching conversation)');
    } else {
      print('✅ Same conversation, keeping existing messages if any');
    }

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
        } else {
          // If no messages found, clear messages
          messages.clear();
          print('No messages found, cleared messages list');
        }
      } else {
        print('Failed to load messages: ${res['data']}');
        // Clear messages if loading failed
        messages.clear();
        // For secretary, if conversation loading fails, try to create one
        final SessionController session = Get.find<SessionController>();
        if (session.role.value == 'secretary' && receiverId.value.isNotEmpty) {
          print('🔍 Secretary: Trying to create conversation with doctor...');
          await _createSecretaryConversation();
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
      messages.clear();
    } finally {
      isLoadingMessages.value = false;
      print('=== DEBUG: LoadMessages Finished ===');
    }
  }

  /// Get or create conversation with a doctor and load messages
  Future<void> openDoctorChat(String doctorId, String doctorName) async {
    print('=== DEBUG: openDoctorChat Called ===');
    print('Doctor ID: $doctorId');
    print('Doctor Name: $doctorName');
    print('Previous Receiver ID: ${receiverId.value}');
    print('Previous Conversation ID: ${currentConversationId.value}');
    print('Current Messages Count: ${messages.length}');

    // Only clear messages if switching to a different doctor
    final isDifferentDoctor =
        receiverId.value.isNotEmpty && receiverId.value != doctorId;
    if (isDifferentDoctor) {
      print('🔄 Switching to different doctor, clearing messages');
      messages.clear();
      currentConversationId.value = '';
    } else if (receiverId.value.isEmpty) {
      print(
        '🆕 Opening chat for first time or new doctor, ensuring messages are loaded',
      );
      // For first time opening, ensure messages list is ready
      if (messages.isNotEmpty && currentConversationId.value.isNotEmpty) {
        // If we have messages but for different doctor, clear them
        messages.clear();
        currentConversationId.value = '';
      }
    } else {
      print('✅ Same doctor, checking if we need to reload messages');
    }

    receiverId.value = doctorId;
    receiverName.value = doctorName;
    isLoadingMessages.value = true;

    try {
      final SessionController session = Get.find<SessionController>();
      final userRole = session.role.value;

      // For secretary, use the doctor conversation endpoint
      if (userRole == 'secretary') {
        final res = await _service.getDoctorConversation(doctorId: doctorId);
        print('Doctor conversation response (secretary): $res');
        if (res['ok'] == true) {
          final data = res['data'];
          if (data is Map) {
            final convId =
                data['conversationId']?.toString() ??
                data['_id']?.toString() ??
                '';
            if (convId.isNotEmpty) {
              final shouldLoadMessages =
                  currentConversationId.value != convId || messages.isEmpty;
              if (shouldLoadMessages) {
                print('📥 Loading messages for conversation: $convId');
                await loadMessages(convId);
              } else {
                print(
                  '✅ Same conversation ($convId), messages already loaded (${messages.length} messages)',
                );
              }
            } else if (data['data'] is List) {
              final messagesList = (data['data'] as List)
                  .cast<Map<String, dynamic>>();
              print(
                '📥 Received messages directly from API: ${messagesList.length} messages',
              );
              messages.value = messagesList;
            } else {
              print('⚠️ No conversation ID or messages found in response');
              if (isDifferentDoctor || receiverId.value.isEmpty) {
                messages.clear();
              }
            }
          }
        } else {
          print('❌ Failed to get doctor conversation: ${res['message']}');
          if (isDifferentDoctor || receiverId.value.isEmpty) {
            messages.clear();
          }
        }
      } else {
        // For patients/users, search in conversations list for existing conversation
        print('🔍 Searching for existing conversation with doctor...');
        final conversationsRes = await _service.getConversations();
        String? foundConversationId;

        if (conversationsRes['ok'] == true) {
          final data = conversationsRes['data'];
          List<Map<String, dynamic>> convList = [];

          if (data is Map && data['data'] is List) {
            convList = (data['data'] as List).cast<Map<String, dynamic>>();
          } else if (data is List) {
            convList = data.cast<Map<String, dynamic>>();
          }

          // Search for conversation with this doctor
          final currentUserId = session.currentUser.value?.id ?? '';
          for (var conv in convList) {
            // Check if conversation has otherParticipant
            if (conv['otherParticipant'] is Map) {
              final otherParticipant = conv['otherParticipant'] as Map;
              final participantId =
                  otherParticipant['_id']?.toString() ??
                  otherParticipant['id']?.toString() ??
                  '';
              if (participantId == doctorId) {
                foundConversationId =
                    conv['_id']?.toString() ?? conv['id']?.toString() ?? '';
                print(
                  '✅ Found existing conversation via otherParticipant: $foundConversationId',
                );
                break;
              }
            } else if (conv['participants'] is List) {
              // Check participants list
              final participants = conv['participants'] as List;
              bool foundDoctor = false;

              for (var participant in participants) {
                if (participant is Map) {
                  final participantId =
                      participant['_id']?.toString() ??
                      participant['id']?.toString() ??
                      '';
                  if (participantId == doctorId) {
                    foundDoctor = true;
                    break;
                  }
                }
              }

              // Also check if conversation has exactly 2 participants (current user + doctor)
              if (foundDoctor || participants.length == 2) {
                // Double check that one of the participants is the doctor
                bool hasDoctor = false;
                bool hasCurrentUser = false;

                for (var participant in participants) {
                  if (participant is Map) {
                    final participantId =
                        participant['_id']?.toString() ??
                        participant['id']?.toString() ??
                        '';
                    if (participantId == doctorId) {
                      hasDoctor = true;
                    }
                    if (participantId == currentUserId) {
                      hasCurrentUser = true;
                    }
                  }
                }

                if (hasDoctor && hasCurrentUser) {
                  foundConversationId =
                      conv['_id']?.toString() ?? conv['id']?.toString() ?? '';
                  print(
                    '✅ Found existing conversation via participants: $foundConversationId',
                  );
                  break;
                }
              }
            }
          }

          if (foundConversationId != null && foundConversationId.isNotEmpty) {
            // Load messages for existing conversation
            final shouldLoadMessages =
                currentConversationId.value != foundConversationId ||
                messages.isEmpty;
            if (shouldLoadMessages) {
              print(
                '📥 Loading messages for conversation: $foundConversationId',
              );
              await loadMessages(foundConversationId);
            } else {
              print(
                '✅ Same conversation ($foundConversationId), messages already loaded (${messages.length} messages)',
              );
            }
          } else {
            // No existing conversation found - will be created when first message is sent
            print(
              '📝 No existing conversation found - will create when first message is sent',
            );
            messages.clear();
            currentConversationId.value = '';
          }
        } else {
          print(
            '❌ Failed to get conversations: ${conversationsRes['message']}',
          );
          messages.clear();
        }
      }
    } catch (e) {
      print('❌ Error in openDoctorChat: $e');
      // Only clear messages if switching doctor or first time
      if (isDifferentDoctor || receiverId.value.isEmpty) {
        messages.clear();
      }
    } finally {
      isLoadingMessages.value = false;
      print(
        '=== DEBUG: openDoctorChat Finished - Messages: ${messages.length} ===',
      );
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

        // Enrich conversations with participant names
        await _enrichConversationsWithNames(convList);

        // Set receiver info for secretary
        receiverId.value = doctorId;

        // Try to get doctor name from enriched conversations or use default
        if (convList.isNotEmpty && convList[0]['participantName'] != null) {
          receiverName.value = convList[0]['participantName'].toString();
        } else {
          receiverName.value = 'الطبيب';
        }

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

  /// Enrich conversations with participant names and images by loading first message of each
  Future<void> _enrichConversationsWithNames(
    List<Map<String, dynamic>> convList,
  ) async {
    final SessionController session = Get.find<SessionController>();
    final currentUserId = session.currentUser.value?.id ?? '';

    print('=== DEBUG: Enriching conversations with names and images ===');
    print('Current User ID: $currentUserId');
    print('Number of conversations: ${convList.length}');

    // First pass: Extract participant IDs from otherParticipant if available
    final List<String> participantIdsToFetch = [];

    for (int i = 0; i < convList.length; i++) {
      final conv = convList[i];

      // Check if otherParticipant exists and extract participant info
      if (conv['otherParticipant'] is Map) {
        final otherParticipant = conv['otherParticipant'] as Map;
        final participantId =
            otherParticipant['_id']?.toString() ??
            otherParticipant['id']?.toString() ??
            '';
        final participantName = otherParticipant['name']?.toString() ?? '';

        if (participantId.isNotEmpty) {
          conv['participantId'] = participantId;
          if (participantName.isNotEmpty) {
            conv['participantName'] = participantName;
          }

          // Add to list for image fetching if not in cache
          if (!_userImageCache.containsKey(participantId) &&
              !_loadingUserImages.containsKey(participantId)) {
            participantIdsToFetch.add(participantId);
          } else if (_userImageCache.containsKey(participantId)) {
            conv['participantImage'] = _userImageCache[participantId];
          }
        }
        continue; // Skip loading messages if we have otherParticipant
      }

      // Fallback: Load first message to get participant info (for conversations without otherParticipant)
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

              // Determine participant ID and name
              String participantId = '';
              String participantName = '';
              if (senderId == currentUserId) {
                participantId = receiverId;
                participantName = receiverName;
              } else {
                participantId = senderId;
                participantName = senderName;
              }

              // Set participant name and ID
              conv['participantName'] = participantName;
              conv['participantId'] = participantId;

              // Add to list for image fetching if not in cache
              if (!_userImageCache.containsKey(participantId) &&
                  !_loadingUserImages.containsKey(participantId)) {
                participantIdsToFetch.add(participantId);
              } else if (_userImageCache.containsKey(participantId)) {
                conv['participantImage'] = _userImageCache[participantId];
              }

              print(
                'Conversation $convId: participant = ${participantName} (${participantId})',
              );
            }
          }
        }
      } catch (e) {
        print('Error enriching conversation $convId: $e');
        // Continue with next conversation
      }
    }

    // Second pass: Fetch images in parallel for all participants
    if (participantIdsToFetch.isNotEmpty) {
      print(
        '📸 Fetching images for ${participantIdsToFetch.length} participants...',
      );
      final futures = participantIdsToFetch.map((participantId) async {
        _loadingUserImages[participantId] = true;
        try {
          final userRes = await _userService.getUserById(participantId);
          if (userRes['ok'] == true) {
            final userData = userRes['data'];
            final userJson =
                (userData['user'] as Map<String, dynamic>?) ??
                (userData['data'] as Map<String, dynamic>?) ??
                userData;
            final imageUrl = (userJson['image'] ?? '').toString();
            if (imageUrl.isNotEmpty) {
              _userImageCache[participantId] = imageUrl;
              // Update all conversations with this participant ID
              for (var conv in convList) {
                if (conv['participantId']?.toString() == participantId) {
                  conv['participantImage'] = imageUrl;
                }
              }
              print(
                '✅ Fetched image for participant $participantId: $imageUrl',
              );
              return imageUrl;
            }
          }
        } catch (e) {
          print('❌ Error fetching user image for $participantId: $e');
        } finally {
          _loadingUserImages.remove(participantId);
        }
        return null;
      }).toList();

      await Future.wait(futures);

      // Refresh conversations list to update UI with images
      conversations.refresh();
    }

    print('=== DEBUG: Finished enriching conversations ===');
  }

  /// Check if conversation is with a specific user type
  bool _isConversationWithType(
    Map<String, dynamic> conv,
    String currentUserId,
    String targetUserType,
  ) {
    // Check otherParticipant
    if (conv['otherParticipant'] is Map) {
      final otherParticipant = conv['otherParticipant'] as Map;
      final userType = otherParticipant['userType']?.toString().toLowerCase() ?? '';
      return userType == targetUserType.toLowerCase();
    }
    
    // Check participants array
    if (conv['participants'] is List) {
      final participants = conv['participants'] as List;
      for (var participant in participants) {
        if (participant is Map) {
          final participantId = participant['_id']?.toString() ?? 
                               participant['id']?.toString() ?? '';
          // Skip current user
          if (participantId.isNotEmpty && participantId != currentUserId) {
            final participantType = participant['userType']?.toString().toLowerCase() ?? '';
            return participantType == targetUserType.toLowerCase();
          }
        }
      }
    }
    
    // If we can't determine, exclude it to be safe
    return false;
  }
}
