import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/chat_controller.dart';
import '../../controller/session_controller.dart';

class ChatDetailsPage extends StatefulWidget {
  final String title;
  final String? receiverId;
  const ChatDetailsPage({super.key, required this.title, this.receiverId});

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatController ctrl = Get.find<ChatController>();
  final SessionController session = Get.find<SessionController>();
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();

    // Set receiverId and load doctor conversation if provided
    if (widget.receiverId != null && widget.receiverId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.openDoctorChat(widget.receiverId!, widget.title);
      });
    }

    // Listen to messages changes for auto-scroll
    ever(ctrl.messages, (_) {
      // Update previous count if it's the first load
      if (_previousMessageCount == 0 && ctrl.messages.isNotEmpty) {
        _previousMessageCount = ctrl.messages.length;
      }
      _scrollToBottom();
    });

    // Initial scroll to bottom after first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _scrollToBottom(force: true);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  /// Scroll to bottom of messages list
  void _scrollToBottom({bool force = false}) {
    if (!_scrollController.hasClients) {
      // If scroll controller is not ready, try again after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom(force: force);
      });
      return;
    }

    if (ctrl.messages.isEmpty) return;

    // Check if new message was added or force scroll
    final currentCount = ctrl.messages.length;
    if (force || currentCount > _previousMessageCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
    _previousMessageCount = currentCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FEFF),
        elevation: 0,
        title: Obx(() {
          // Get receiver name or use widget.title as fallback
          final displayName = ctrl.receiverName.value.isNotEmpty
              ? ctrl.receiverName.value
              : widget.title;

          // Get connection status
          final isConnected = ctrl.isSocketConnected.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyText(
                displayName,
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConnected
                          ? const Color(0xFF18A2AE)
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  MyText(
                    isConnected ? 'متصل' : 'غير متصل',
                    fontSize: 14.sp,
                    color: isConnected ? AppColors.textSecondary : Colors.grey,
                  ),
                ],
              ),
            ],
          );
        }),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
        actions: [
          Obx(() {
            // Get receiver image
            final receiverImage = ctrl.receiverImage.value;

            // Check if current user is a user (patient) to show doctor image
            final currentRole = session.role.value;
            final showImage = currentRole == 'user' && receiverImage.isNotEmpty;

            if (!showImage) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: EdgeInsets.only(right: 10.w, left: 10.w, top: 5.h),
              child: CircleAvatar(
                radius: 26.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: receiverImage.isNotEmpty
                    ? NetworkImage(receiverImage)
                    : null,
                onBackgroundImageError: (exception, stackTrace) {
                  print('Error loading image: $exception');
                },
                child: receiverImage.isEmpty
                    ? Icon(Icons.person, size: 24.r, color: AppColors.primary)
                    : null,
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final items = ctrl.messages;
              final currentUserId = session.currentUser.value?.id ?? '';

              return ListView.builder(
                controller: _scrollController,
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
                      else if (senderRole == 'secretary' &&
                          currentRole == 'doctor') {
                        isMe = true; // Show on right (as own team)
                      }
                    }
                  }

                  print(
                    'Message $i: "$text", isMe: $isMe, sender: ${m['sender']}, currentUserId: $currentUserId',
                  );

                  // Get image URL if present
                  final imageUrl = m['image']?.toString();
                  final imageLocal = m['imageLocal'] == true;
                  final imagePath = imageLocal ? m['image']?.toString() : null;

                  return _bubble(
                    text,
                    isMe: isMe,
                    imageUrl: imageUrl,
                    imagePath: imagePath,
                    isLocalImage: imageLocal,
                  );
                },
              );
            }),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Row(
              children: [
                // Send button
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
                      // Scroll to bottom after sending message
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _scrollToBottom(force: true);
                      });
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
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: GestureDetector(
                            onTap: () async {
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

                              final ImagePicker picker = ImagePicker();
                              final XFile? picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85,
                              );

                              if (picked != null) {
                                final imageFile = File(picked.path);
                                final text = _msgCtrl.text.trim();
                                final ok = await ctrl.sendMessage(
                                  text,
                                  imageFile: imageFile,
                                );
                                if (ok) {
                                  _msgCtrl.clear();
                                  // Scroll to bottom after sending image
                                  Future.delayed(
                                    const Duration(milliseconds: 300),
                                    () {
                                      _scrollToBottom(force: true);
                                    },
                                  );
                                } else {
                                  Get.snackbar(
                                    'فشل الإرسال',
                                    'تعذر إرسال الصورة، يرجى المحاولة مرة أخرى',
                                    backgroundColor: const Color(0xFFFF3B30),
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
                                  );
                                }
                              }
                            },
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.image,
                                color: AppColors.primary,
                                size: 22.sp,
                              ),
                            ),
                          ),
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

  Widget _bubble(
    String text, {
    required bool isMe,
    String? imageUrl,
    String? imagePath,
    bool isLocalImage = false,
  }) {
    final hasImage = imageUrl != null || imagePath != null;
    final hasText = text.isNotEmpty;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Image
            if (hasImage)
              GestureDetector(
                onTap: () {
                  // Show full screen image preview
                  Get.dialog(
                    Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          Center(
                            child: InteractiveViewer(
                              child: isLocalImage && imagePath != null
                                  ? Image.file(
                                      File(imagePath),
                                      fit: BoxFit.contain,
                                    )
                                  : imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              padding: EdgeInsets.all(20.w),
                                              child: const Icon(
                                                Icons.error_outline,
                                                color: Colors.white,
                                                size: 48,
                                              ),
                                            );
                                          },
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                          Positioned(
                            top: 40.h,
                            right: 20.w,
                            child: IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 32,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    topRight: Radius.circular(18.r),
                    bottomLeft: hasText
                        ? Radius.zero
                        : Radius.circular(isMe ? 18.r : 4.r),
                    bottomRight: hasText
                        ? Radius.zero
                        : Radius.circular(isMe ? 4.r : 18.r),
                  ),
                  child: isLocalImage && imagePath != null
                      ? Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          height: 200.h,
                          width: 200.w,
                        )
                      : imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          height: 200.h,
                          width: 200.w,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200.h,
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200.h,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        )
                      : const SizedBox(),
                ),
              ),
            // Text
            if (hasText)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: MyText(
                  text,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: isMe ? Colors.white : AppColors.textSecondary,
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
