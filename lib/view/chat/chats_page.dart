import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import 'chat_details_page.dart';
import '../../controller/chat_controller.dart';
import '../../controller/session_controller.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController ctrl = Get.find<ChatController>();
    final session = Get.find<SessionController>();
    final currentUserId = session.currentUser.value?.id ?? '';
    // Load conversations on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ctrl.isLoadingConversations.value && ctrl.conversations.isEmpty) {
        ctrl.loadConversations();
      }
    });

    final isSecretary = session.role.value == 'secretary';

    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FEFF),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: MyText(
          'المحادثات',
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        leading: isSecretary
            ? const SizedBox.shrink()
            : IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.primary,
                ),
              ),
      ),
      body: Obx(() {
        final list = ctrl.conversations;
        if (ctrl.isLoadingConversations.value && list.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemBuilder: (_, i) {
            final item = list[i];
            // Extract name from conversation data (now enriched with participant info)
            String name = 'محادثة';

            // First try otherParticipant (direct from API)
            if (item['otherParticipant'] is Map) {
              final otherParticipant = item['otherParticipant'] as Map;
              final otherName = otherParticipant['name']?.toString() ?? '';
              if (otherName.isNotEmpty) {
                name = otherName;
              }
            }

            // Second try the enriched participant name (added by controller)
            if (name == 'محادثة' &&
                item['participantName'] != null &&
                item['participantName'].toString().isNotEmpty &&
                item['participantName'].toString() != 'محادثة') {
              name = item['participantName'].toString();
            }

            // Third try to extract from participants array if exists
            if (name == 'محادثة' &&
                item['participants'] is List &&
                (item['participants'] as List).isNotEmpty) {
              final participants = item['participants'] as List;
              final SessionController session = Get.find<SessionController>();
              final currentUserId = session.currentUser.value?.id ?? '';

              for (var participant in participants) {
                if (participant is Map) {
                  final participantId =
                      participant['_id']?.toString() ??
                      participant['id']?.toString() ??
                      '';
                  if (participantId.isNotEmpty &&
                      participantId != currentUserId) {
                    final participantName =
                        participant['name']?.toString() ??
                        participant['fullName']?.toString() ??
                        '';
                    if (participantName.isNotEmpty) {
                      name = participantName;
                      break;
                    }
                  }
                }
              }
            }

            // Final fallback to direct fields
            if (name == 'محادثة') {
              name =
                  (item['doctorName'] ??
                          item['userName'] ??
                          item['receiverName'] ??
                          item['senderName'] ??
                          item['name'] ??
                          'محادثة')
                      .toString();
            }

            // Handle lastMessage type safely - it could be a Map or String
            final lastMessage = item['lastMessage'];
            String last = '';
            if (lastMessage is Map) {
              // If lastMessage is a Map, try to get content from it
              last = (lastMessage['content'] ?? lastMessage['text'] ?? '')
                  .toString();
            } else if (lastMessage != null) {
              // If lastMessage is a String or other type, use it directly
              last = lastMessage.toString();
            }
            // Fallback to other fields if still empty
            if (last.isEmpty) {
              last = (item['last'] ?? '').toString();
            }
            final unread =
                int.tryParse(
                  (item['unreadCount'] ?? item['unread'] ?? '0').toString(),
                ) ??
                0;
            final convId = (item['_id'] ?? item['conversationId'] ?? '')
                .toString();

            // Extract receiverId and image from conversation data (now enriched)
            String receiverId = '';
            String? userImageUrl;

            // First try otherParticipant (direct from API)
            if (item['otherParticipant'] is Map) {
              final otherParticipant = item['otherParticipant'] as Map;
              final otherId =
                  otherParticipant['_id']?.toString() ??
                  otherParticipant['id']?.toString() ??
                  '';
              if (otherId.isNotEmpty) {
                receiverId = otherId;
              }
              // Extract user image from otherParticipant
              // Try multiple possible field names for image
              final image =
                  otherParticipant['image']?.toString() ??
                  otherParticipant['avatar']?.toString() ??
                  otherParticipant['profileImage']?.toString() ??
                  otherParticipant['photo']?.toString() ??
                  '';
              if (image.isNotEmpty) {
                userImageUrl = image;
                print('✅ Found image in otherParticipant: $image');
              } else {
                print(
                  '⚠️ No image found in otherParticipant. Fields: ${otherParticipant.keys}',
                );
              }
            }

            // Second try the enriched participant ID
            if (receiverId.isEmpty &&
                item['participantId'] != null &&
                item['participantId'].toString().isNotEmpty) {
              receiverId = item['participantId'].toString();
            }

            // Final fallback to direct fields
            if (receiverId.isEmpty) {
              receiverId =
                  (item['receiverId'] ??
                          item['doctorId'] ??
                          item['userId'] ??
                          '')
                      .toString();
            }

            // Try to get image from enriched participant image (from controller cache)
            if ((userImageUrl == null || userImageUrl.isEmpty) &&
                item['participantImage'] != null) {
              userImageUrl = item['participantImage']?.toString();
              print('✅ Found image in participantImage: $userImageUrl');
            }

            // DEBUG: Print conversation item data
            print('=== DEBUG: Conversation Item ===');
            print('Conversation ID: $convId');
            print('Receiver ID: $receiverId');
            print('Name: $name');
            print('User Image URL: $userImageUrl');
            print('Current User ID: $currentUserId');
            print('Full item: $item');
            print('================================');

            return InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () async {
                print('=== DEBUG: Opening Chat ===');
                print('Conversation ID: $convId');
                print('Initial receiverId: $receiverId');
                print('Initial name: $name');

                // Clear previous receiver info only if switching to a different conversation
                final isDifferentConversation =
                    ctrl.currentConversationId.value != convId;
                if (isDifferentConversation) {
                  print(
                    '🔄 Switching to different conversation, clearing messages',
                  );
                  ctrl.receiverId.value = '';
                  ctrl.receiverName.value = '';
                  ctrl.messages.clear();
                  ctrl.currentConversationId.value = '';
                } else {
                  print('✅ Returning to same conversation, keeping messages');
                }

                // Set initial values if available
                if (receiverId.isNotEmpty) {
                  ctrl.receiverId.value = receiverId;
                  ctrl.receiverName.value = name;
                }

                // Load messages - this will extract receiver info from messages
                if (convId.isNotEmpty) {
                  print('Loading messages for conversation: $convId');
                  await ctrl.loadMessages(convId);
                } else {
                  // If no conversation ID, ensure messages are cleared
                  if (ctrl.currentConversationId.value.isNotEmpty) {
                    ctrl.messages.clear();
                    ctrl.currentConversationId.value = '';
                  }
                }

                // Use the name extracted from messages if available, otherwise fallback
                final finalName = ctrl.receiverName.value.isNotEmpty
                    ? ctrl.receiverName.value
                    : name;
                print('Final name for chat: $finalName');

                Get.to(() => ChatDetailsPage(title: finalName));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // image at the right
                    CircleAvatar(
                      radius: 28.r,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: userImageUrl != null && userImageUrl.isNotEmpty
                            ? Image.network(
                                userImageUrl,
                                width: 56.w,
                                height: 56.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/icons/home/doctor.png',
                                    width: 56.w,
                                    height: 56.w,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/icons/home/doctor.png',
                                width: 56.w,
                                height: 56.w,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // name + last message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            name,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 6.h),
                          MyText(
                            last,
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // arrow + unread badge at the end (left)
                    Column(
                      children: [
                        const Icon(
                          Icons.keyboard_arrow_left,
                          color: AppColors.textSecondary,
                        ),
                        if (unread > 0)
                          Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7CC7D0),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: MyText(
                                '$unread',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) =>
              Divider(color: AppColors.divider, height: 1),
          itemCount: list.length,
        );
      }),
    );
  }
}
