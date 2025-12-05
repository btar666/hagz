import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/chat_controller.dart';
import '../../controller/session_controller.dart';

class ChatDetailsPage extends StatelessWidget {
  final String title;
  final String? receiverId;
  const ChatDetailsPage({super.key, required this.title, this.receiverId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _msgCtrl = TextEditingController();
    final ChatController ctrl = Get.find<ChatController>();
    final SessionController session = Get.find<SessionController>();

    // Set receiverId and load doctor conversation if provided
    if (receiverId != null && receiverId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // openDoctorChat will handle clearing messages only if switching to different doctor
        ctrl.openDoctorChat(receiverId!, title);
      });
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FEFF),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyText(
              title,
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF18A2AE),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                MyText('متصل', fontSize: 14.sp, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final items = ctrl.messages;
              final currentUserId = session.currentUser.value?.id ?? '';

              return ListView.builder(
                reverse: false,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final m = items[i];
                  final text = (m['content'] ?? m['text'] ?? '').toString();

                  // Determine if message is from current user
                  bool isMe = false;

                  // First check if it's a local message (from sendMessage)
                  if (m['isMe'] == true || m['sender'] == 'me') {
                    isMe = true;
                  } else {
                    // Check against actual sender ID from API
                    final sender = m['sender'];
                    if (sender is Map && sender['_id'] != null) {
                      final senderId = sender['_id'].toString();
                      isMe = (senderId == currentUserId);
                    } else if (sender is String) {
                      // Sometimes sender might be just an ID string
                      isMe = (sender == currentUserId);
                    }
                  }

                  // Handle message display based on user role
                  final currentRole = session.role.value;
                  
                  if (currentRole == 'secretary') {
                    // For secretary: show doctor and secretary messages on right, patient on left
                    if (isMe) {
                      isMe = true;
                    } else {
                      // Check if sender is doctor or secretary (show on right)
                      final sender = m['sender'];
                      String? senderRole;
                      if (sender is Map) {
                        senderRole = sender['userType']
                            ?.toString()
                            .toLowerCase();
                      }
                      // If sender is doctor or secretary, show on right (isMe = true)
                      // If sender is patient/user, show on left (isMe = false)
                      isMe =
                          (senderRole == 'doctor' || senderRole == 'secretary');
                    }
                  } else if (currentRole == 'user' || currentRole == 'doctor') {
                    // For patients/users: show secretary messages as if from doctor (left side)
                    // For doctors: show secretary messages on right side with their messages
                    if (!isMe) {
                      final sender = m['sender'];
                      String? senderRole;
                      if (sender is Map) {
                        senderRole = sender['userType']
                            ?.toString()
                            .toLowerCase();
                      }
                      
                      // If sender is secretary and current user is patient, show as doctor message (left)
                      if (senderRole == 'secretary' && currentRole == 'user') {
                        isMe = false; // Show on left (as doctor)
                      }
                      // If sender is secretary and current user is doctor, show as own message (right)
                      else if (senderRole == 'secretary' && currentRole == 'doctor') {
                        isMe = true; // Show on right (as own team)
                      }
                    }
                  }

                  print(
                    'Message $i: "$text", isMe: $isMe, sender: ${m['sender']}, currentUserId: $currentUserId',
                  );

                  return _bubble(text, isMe: isMe);
                },
              );
            }),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final text = _msgCtrl.text.trim();
                    if (text.isEmpty) {
                      Get.snackbar(
                        'رسالة فارغة',
                        'يرجى كتابة رسالة قبل الإرسال',
                        backgroundColor: AppColors.warning,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                      return;
                    }

                    // Check if receiverId is set
                    if (ctrl.receiverId.value.isEmpty) {
                      Get.snackbar(
                        'خطأ',
                        'لا يمكن إرسال الرسالة، المستلم غير محدد',
                        backgroundColor: const Color(0xFFFF3B30),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 3),
                      );
                      return;
                    }

                    final ok = await ctrl.sendMessage(text);
                    if (ok) {
                      _msgCtrl.clear();
                    } else {
                      Get.snackbar(
                        'فشل الإرسال',
                        'تعذر إرسال الرسالة، يرجى المحاولة مرة أخرى',
                        backgroundColor: const Color(0xFFFF3B30),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 3),
                      );
                    }
                  },
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالتك',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(String text, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF7CC7D0) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 18.r),
          ),
          border: isMe ? null : Border.all(color: AppColors.divider),
        ),
        child: MyText(
          text,
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: isMe ? Colors.white : AppColors.textSecondary,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
