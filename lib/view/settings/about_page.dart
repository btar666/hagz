import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
          leadingWidth: 0,
          actions: [
            const BackButtonWidget(),
          ],
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
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

}
