import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/search_widget.dart';
import '../home/search_page.dart';
import '../../bindings/search_binding.dart';

class DelegateAllVisitsPage extends StatefulWidget {
  const DelegateAllVisitsPage({super.key});

  @override
  State<DelegateAllVisitsPage> createState() => _DelegateAllVisitsPageState();
}

class _DelegateAllVisitsPageState extends State<DelegateAllVisitsPage> {
  int _tabIndex = 0; // 0: اطباء, 1: مستشفيات, 2: مجمعات

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: MyText(
                  'جميع الزيارات',
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: SearchWidget(
                      hint: 'ابحث عن طبيب أو مستشفى ..',
                      readOnly: true,
                      onTap: () => Get.to(
                        () => const SearchPage(),
                        binding: SearchBinding(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () {
                      // تم إزالة صفحة تسجيل المندوب
                      Get.snackbar(
                        'معلومة',
                        'تم إزالة تسجيل المندوبين',
                        backgroundColor: AppColors.primary,
                        colorText: Colors.white,
                      );
                    },
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
                child: _buildListForTab(),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: _buildBottomTabs(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListForTab() {
    if (_tabIndex == 0) {
      final items = [
        const _VisitCard(
          title: 'د . بالا',
          subtitle: 'طب الشبكية',
          subscribed: true,
        ),
        const _VisitCard(
          title: 'د . صوفيا',
          subtitle: 'طب الشبكية',
          subscribed: false,
          visits: 6,
          reason: 'يحتاج وقت للتفكير',
        ),
        const _VisitCard(
          title: 'د . نيلوفر',
          subtitle: 'الجراحة العامة',
          subscribed: true,
        ),
        const _VisitCard(
          title: 'د . هريستو',
          subtitle: 'طب الشبكية',
          subscribed: false,
          visits: 6,
          reason: 'يحتاج وقت للتفكير',
        ),
      ];
      return ListView.separated(
        itemBuilder: (_, i) => items[i],
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemCount: items.length,
      );
    } else if (_tabIndex == 1) {
      final items = [
        const _VisitCard(
          title: 'مستشفى الكافي',
          subtitle: 'طب الشبكية',
          subscribed: false,
          visits: 6,
          reason: 'يحتاج وقت للتفكير',
        ),
      ];
      return ListView.separated(
        itemBuilder: (_, i) => items[i],
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemCount: items.length,
      );
    } else {
      final items = [
        const _VisitCard(
          title: 'مجمع روما',
          subtitle: 'طب الشبكية',
          subscribed: false,
          visits: 6,
          reason: 'يحتاج وقت للتفكير',
        ),
      ];
      return ListView.separated(
        itemBuilder: (_, i) => items[i],
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemCount: items.length,
      );
    }
  }

  Widget _buildBottomTabs() {
    final List<String> tabLabels = ['أطباء', 'مستشفيات', 'مجمعات'];
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final bool isSelected = _tabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = index),
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
    );
  }
}

class _VisitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool subscribed;
  final int? visits;
  final String? reason;
  const _VisitCard({
    required this.title,
    required this.subtitle,
    required this.subscribed,
    this.visits,
    this.reason,
  });

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
                      const TextSpan(
                        text: 'سبب عدم الاشتراك : ',
                        style: TextStyle(
                          color: Color(0xFFFF3B30),
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
