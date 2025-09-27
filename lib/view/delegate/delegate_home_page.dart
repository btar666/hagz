import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/search_widget.dart';
import '../home/search_page.dart';
import 'delegate_register_page.dart';

class DelegateHomePage extends StatelessWidget {
  const DelegateHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_VisitItem> items = [
      _VisitItem(title: 'د . بالا', subtitle: 'طب الشبكية', isSubscribed: true),
      _VisitItem(
        title: 'د . صوفيا',
        subtitle: 'طب الشبكية',
        isSubscribed: false,
        visits: 6,
        reason: 'يحتاج وقت للتفكير',
      ),
      _VisitItem(
        title: 'د . نيلوفر',
        subtitle: 'الجراحة العامة',
        isSubscribed: true,
      ),
      _VisitItem(
        title: 'مستشفى روما',
        subtitle: 'طب الشبكية',
        isSubscribed: false,
        visits: 6,
        reason: 'يحتاج وقت للتفكير',
      ),
      _VisitItem(
        title: 'د . هريستو',
        subtitle: 'طب الشبكية',
        isSubscribed: false,
        visits: 6,
        reason: '—',
      ),
    ];

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
                  // Left avatar
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Search
                  Expanded(
                    child: SearchWidget(
                      hint: 'ابحث عن طبيب أو مستشفى ..',
                      readOnly: true,
                      onTap: () => Get.to(() => const SearchPage()),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Add button
                  GestureDetector(
                    onTap: () => Get.to(() => const DelegateRegisterPage()),
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
                    'تمت زيارتهم مؤخرًا',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.right,
                  ),
                  const Spacer(),
                  Icon(Icons.tune, color: AppColors.textSecondary, size: 22.sp),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                itemBuilder: (_, i) => _VisitedCard(item: items[i]),
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemCount: items.length,
              ),
            ),
          ],
        ),
      ),
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
                        text: 'سبب عدم الاشتراك : ',
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
          'مشترك',
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
            'غير مشترك',
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFF3B30),
          ),
          if (visits != null) ...[
            SizedBox(height: 2.h),
            MyText(
              'زيارات $visits',
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
