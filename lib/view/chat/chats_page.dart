import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import 'chat_details_page.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {
        'name': 'اسم الطبيب',
        'last': 'هذا العلاج قبل أو بعد الطعام ؟',
        'unread': 6,
      },
      {
        'name': 'اسم الطبيب',
        'last': 'هذا العلاج قبل أو بعد الطعام ؟',
        'unread': 0,
      },
      {
        'name': 'اسم الطبيب',
        'last': 'هذا العلاج قبل أو بعد الطعام ؟',
        'unread': 6,
      },
      {
        'name': 'اسم الطبيب',
        'last': 'هذا العلاج قبل أو بعد الطعام ؟',
        'unread': 0,
      },
      {
        'name': 'اسم الطبيب',
        'last': 'هذا العلاج قبل أو بعد الطعام ؟',
        'unread': 0,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FEFF),
        elevation: 0,
        title: MyText(
          'المحادثات',
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemBuilder: (_, i) {
          final item = chats[i];
          return InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () =>
                Get.to(() => ChatDetailsPage(title: item['name'] as String)),
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
                      child: Image.asset(
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
                          item['name'] as String,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 6.h),
                        MyText(
                          item['last'] as String,
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
                      if ((item['unread'] as int) > 0)
                        Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7CC7D0),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: MyText(
                              '${item['unread']}',
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
        itemCount: chats.length,
      ),
    );
  }
}
