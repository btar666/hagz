import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../bindings/delegate_home_binding.dart';
import '../../controller/delegate_home_controller.dart';
import '../../controller/session_controller.dart';
import '../../controller/locale_controller.dart';
import 'add_visit_page.dart';
import 'visit_details_page.dart';

class DelegateHomePage extends StatelessWidget {
  const DelegateHomePage({super.key});

  void _showVisitTypeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GetBuilder<LocaleController>(
        builder: (localeController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyText(
                  'select_visit_type'.tr,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 24.h),
                _buildTypeOption(
                  context,
                  title: 'doctor'.tr,
                  icon: Icons.person,
                  type: 'doctor',
                ),
                SizedBox(height: 12.h),
                _buildTypeOption(
                  context,
                  title: 'hospitals'.tr,
                  icon: Icons.local_hospital,
                  type: 'hospital',
                ),
                SizedBox(height: 12.h),
                _buildTypeOption(
                  context,
                  title: 'medical_complex'.tr,
                  icon: Icons.business,
                  type: 'complex',
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String type,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Get.to(() => const AddVisitPage(), arguments: {'type': type});
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 28.sp),
            SizedBox(width: 16.w),
            MyText(
              title,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // التأكد من تهيئة Controller
    if (!Get.isRegistered<DelegateHomeController>()) {
      DelegateHomeBinding().dependencies();
    }
    final controller = Get.find<DelegateHomeController>();
    final sessionController = Get.find<SessionController>();

    // Wrap with GetBuilder to listen to locale changes
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left avatar - User profile image
                      Obx(() {
                        final user = sessionController.currentUser.value;
                        final imageUrl = user?.image;
                        return Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: 56.w,
                                    height: 56.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 56.w,
                                        height: 56.w,
                                        color: AppColors.primary.withOpacity(
                                          0.2,
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: AppColors.primary,
                                          size: 32.sp,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 56.w,
                                    height: 56.w,
                                    color: AppColors.primary.withOpacity(0.2),
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                      size: 32.sp,
                                    ),
                                  ),
                          ),
                        );
                      }),
                      SizedBox(width: 12.w),
                      // Search
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: TextField(
                            key: ValueKey(
                              'search_${localeController.selectedLanguage.value}',
                            ),
                            controller: controller.searchController,
                            onChanged: controller.updateSearch,
                            decoration: InputDecoration(
                              hintText: 'search_recent_visits'.tr,
                              hintStyle: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 16.sp,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.textLight,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                              ),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Add button
                      GestureDetector(
                        onTap: () => _showVisitTypeDialog(context),
                        child: Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      MyText(
                        'recently_visited'.tr,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.right,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.tune,
                        color: AppColors.textSecondary,
                        size: 22.sp,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Skeletonizer(
                        enabled: true,
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                          itemBuilder: (_, i) => _VisitedCard(
                            item: _VisitItem(
                              title: 'loading'.tr,
                              subtitle: '...',
                              isSubscribed: false,
                            ),
                          ),
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemCount: 5,
                        ),
                      );
                    }

                    if (controller.recentVisits.isEmpty) {
                      return Center(
                        child: MyText(
                          'no_recent_visits'.tr,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.refresh,
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                        itemBuilder: (_, i) {
                          final visit = controller.filteredRecentVisits[i];
                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                () => const VisitDetailsPage(),
                                arguments: visit,
                              );
                            },
                            child: _VisitedCard(
                              item: _VisitItem(
                                title: visit['title'] as String,
                                subtitle: visit['subtitle'] as String,
                                isSubscribed: visit['isSubscribed'] as bool,
                                visits: visit['visits'] as int?,
                                reason: visit['reason'] as String?,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemCount: controller.filteredRecentVisits.length,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VisitedCard extends StatelessWidget {
  final _VisitItem item;
  const _VisitedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and subtitle on the right (RTL alignment)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        item.title,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 6.h),
                      MyText(
                        item.subtitle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                // Status badge on the left
                _StatusBadge(
                  isSubscribed: item.isSubscribed,
                  visits: item.visits,
                ),
              ],
            ),

            if (!item.isSubscribed) ...[
              SizedBox(height: 12.h),
              Divider(color: AppColors.divider, height: 1),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Expo Arabic',
                      fontSize: 16.sp,
                    ),
                    children: [
                      TextSpan(
                        text: 'unsubscription_reason'.tr,
                        style: const TextStyle(
                          color: Color(0xFFFF3B30),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: item.reason ?? '',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isSubscribed;
  final int? visits;
  const _StatusBadge({required this.isSubscribed, this.visits});

  @override
  Widget build(BuildContext context) {
    if (isSubscribed) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F7EA),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: MyText(
          'subscribed'.tr,
          fontSize: 16.sp,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF2ECC71),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECE8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            'not_subscribed'.tr,
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFF3B30),
          ),
          if (visits != null) ...[
            SizedBox(height: 2.h),
            MyText(
              'visits_count'.tr.replaceAll('{visits}', visits.toString()),
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}

class _VisitItem {
  final String title;
  final String subtitle;
  final bool isSubscribed;
  final int? visits;
  final String? reason;
  _VisitItem({
    required this.title,
    required this.subtitle,
    required this.isSubscribed,
    this.visits,
    this.reason,
  });
}
