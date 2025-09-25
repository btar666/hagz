import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';

class ChatDetailsPage extends StatelessWidget {
  final String title;
  const ChatDetailsPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _msgCtrl = TextEditingController();
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
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              children: [
                _timeSeparator('اليوم , 6:36 مساءً'),
                _bubble(
                  'مرحباً دكتور , هل يمكنني حجز موعد اليوم ؟',
                  isMe: true,
                ),
                _time('6:36 م'),
                _bubble(
                  'أهلاً و سهلاً بك , بالتأكيد يمكنك !\nهل الحالة طارئة ؟',
                  isMe: false,
                ),
                _time('6:36 م'),
                _bubble(
                  'مرحباً دكتور , هل يمكنني حجز موعد اليوم ؟',
                  isMe: true,
                ),
                _time('6:36 م'),
                _bubble(
                  'أهلاً و سهلاً بك , بالتأكيد يمكنك !\nهل الحالة طارئة ؟',
                  isMe: false,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
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

  Widget _timeSeparator(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: MyText(text, fontSize: 14.sp, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _time(String t) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, bottom: 12.h),
      child: Align(
        alignment: Alignment.centerRight,
        child: MyText(t, fontSize: 12.sp, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _bubble(String text, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF7CC7D0) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(isMe ? 4.r : 18.r),
            bottomRight: Radius.circular(isMe ? 18.r : 4.r),
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
