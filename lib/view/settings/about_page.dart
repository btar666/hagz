import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../controller/about_controller.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/back_button_widget.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AboutController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FEFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leadingWidth: 80.w,
          leading: Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: const BackButtonWidget(),
          ),
          title: MyText(
            'about_app_title'.tr,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Obx(
            () => controller.isLoading.value
                ? Skeletonizer(
                    enabled: true,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(28.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 120.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Container(
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Container(
                            height: 200.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(28.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App Icon/Logo Section
                        Container(
                          padding: EdgeInsets.all(32.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 80.w,
                                height: 80.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Icon(
                                  Icons.medical_services,
                                  color: AppColors.primary,
                                  size: 40.sp,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              MyText(
                                controller.appName.value.isNotEmpty
                                    ? controller.appName.value
                                    : 'حاجز',
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.h),
                              MyText(
                                'الإصدار ${controller.appVersion.value.isNotEmpty ? controller.appVersion.value : "1.0.0"}',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // About Section
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                'حول التطبيق',
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(height: 16.h),
                              MyText(
                                controller.appAbout.value.isNotEmpty
                                    ? controller.appAbout.value
                                    : 'تطبيق لإدارة المواعيد والمنشآت الصحية',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Support Section
                        if (controller.supportLink.value.isNotEmpty)
                          GestureDetector(
                            onTap: () =>
                                _openSupportLink(controller.supportLink.value),
                            child: Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48.w,
                                    height: 48.w,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF25D366,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      Icons.help_outline,
                                      color: const Color(0xFF25D366),
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          'الدعم والمساعدة',
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                        ),
                                        SizedBox(height: 4.h),
                                        MyText(
                                          'تواصل معنا عبر واتساب',
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColors.textSecondary,
                                    size: 20.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSupportLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'خطأ',
          'لا يمكن فتح رابط الدعم',
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء فتح رابط الدعم',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }
  }
}
