import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/locale_controller.dart';
import '../../bindings/delegate_all_visits_binding.dart';
import '../../controller/delegate_all_visits_controller.dart';
import 'add_visit_page.dart';
import 'visit_details_page.dart';

class DelegateAllVisitsPage extends StatelessWidget {
  const DelegateAllVisitsPage({super.key});

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
                  title: 'hospital'.tr,
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
    if (!Get.isRegistered<DelegateAllVisitsController>()) {
      DelegateAllVisitsBinding().dependencies();
    }
    final controller = Get.find<DelegateAllVisitsController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            GetBuilder<LocaleController>(
              builder: (localeController) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: MyText(
                      'all_visits'.tr,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: GetBuilder<LocaleController>(
                        builder: (localeController) {
                          return TextField(
                            key: ValueKey(
                              'search_${localeController.selectedLanguage.value}',
                            ),
                            controller: controller.searchController,
                            onChanged: controller.updateSearch,
                            decoration: InputDecoration(
                              hintText: 'search_doctor_hospital'.tr,
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
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
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

            SizedBox(height: 16.h),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Obx(() => _buildListForTab(controller)),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: _buildBottomTabs(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListForTab(DelegateAllVisitsController controller) {
    if (controller.isLoading.value) {
      return Skeletonizer(
        enabled: true,
        child: GetBuilder<LocaleController>(
          builder: (localeController) {
            return ListView.separated(
              itemBuilder: (_, i) => _VisitCard(
                title: 'loading'.tr,
                subtitle: '...',
                subscribed: false,
              ),
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemCount: 5,
            );
          },
        ),
      );
    }

    final visits = controller.currentTabVisits;

    if (visits.isEmpty) {
      return GetBuilder<LocaleController>(
        builder: (localeController) {
          return Center(
            child: MyText(
              'no_visits'.tr,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.primary,
      child: ListView.separated(
        itemBuilder: (_, i) {
          final visit = visits[i];
          return _VisitCard(
            title: visit['title'] as String,
            subtitle: visit['subtitle'] as String,
            subscribed: visit['isSubscribed'] as bool,
            visits: visit['visits'] as int?,
            reason: visit['reason'] as String?,
            onTap: () {
              Get.to(
                () => const VisitDetailsPage(),
                arguments: {
                  'id': visit['id'],
                  'title': visit['title'],
                  'subtitle': visit['subtitle'],
                  'isSubscribed': visit['isSubscribed'],
                  'visits': visit['visits'],
                  'reason': visit['reason'],
                  'type': visit['type'],
                  'address': visit['address'],
                  'phone': visit['phone'],
                  'governorate': visit['governorate'],
                  'district': visit['district'],
                  'notes': visit['notes'],
                  'coordinates': visit['coordinates'] ?? {},
                },
              );
            },
          );
        },
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemCount: visits.length,
      ),
    );
  }

  Widget _buildBottomTabs(DelegateAllVisitsController controller) {
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        final List<String> tabLabels = [
          'doctors_tab'.tr,
          'hospitals_tab'.tr,
          'complexes_tab'.tr,
        ];
        return Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Obx(
            () => Row(
              children: List.generate(3, (index) {
                final bool isSelected = controller.currentTab.value == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.changeTab(index),
                    child: Container(
                      height: 50.h,
                      decoration: isSelected
                          ? BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(25.r),
                            )
                          : null,
                      child: Center(
                        child: MyText(
                          tabLabels[index],
                          fontFamily: 'Expo Arabic',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          height: 1.0,
                          color: isSelected ? Colors.white : AppColors.primary,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class _VisitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool subscribed;
  final int? visits;
  final String? reason;
  final VoidCallback? onTap;
  const _VisitCard({
    required this.title,
    required this.subtitle,
    required this.subscribed,
    this.visits,
    this.reason,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
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
                  _StatusBadge(isSubscribed: subscribed, visits: visits),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MyText(
                          title,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 6.h),
                        MyText(
                          subtitle,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!subscribed) ...[
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
                          style: TextStyle(
                            color: const Color(0xFFFF3B30),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: reason ?? '',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
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
        child: GetBuilder<LocaleController>(
          builder: (localeController) {
            return MyText(
              'subscribed'.tr,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2ECC71),
            );
          },
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
          GetBuilder<LocaleController>(
            builder: (localeController) {
              return MyText(
                'not_subscribed'.tr,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFF3B30),
              );
            },
          ),
          if (visits != null) ...[
            SizedBox(height: 2.h),
            GetBuilder<LocaleController>(
              builder: (localeController) {
                return MyText(
                  'visits_count'.tr.replaceAll('{visits}', visits.toString()),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
