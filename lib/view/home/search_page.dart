import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/specialization_text.dart';
import '../../controller/search_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchController c = Get.find<SearchController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FEFF),
        elevation: 0,
        title: MyText(
          'نتائج البحث',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: MyText(
            'الغاء',
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                onChanged: c.onQueryChanged,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن طبيب...',
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textLight,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerRight,
              child: MyText(
                'نتائج البحث',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                final items = c.results;
                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 100 &&
                        !c.isLoading.value) {
                      c.loadMore();
                    }
                    return false;
                  },
                  child: Skeletonizer(
                    enabled:
                        c.isLoading.value && items.isEmpty ||
                        c.isLoading.value && items.isNotEmpty,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 178 / 247,
                      ),
                      itemCount: items.isEmpty
                          ? 8 // أول تحميل
                          : items.length +
                                (c.isLoading.value ? 4 : 0), // تحميل المزيد
                      itemBuilder: (context, index) {
                        final bool showingReal =
                            index < items.length && items.isNotEmpty;
                        final item = showingReal
                            ? items[index]
                            : {'name': '—', 'specialization': ''};
                        final name = (item['name'] ?? '').toString();
                        final spec = (item['specialization'] ?? '').toString();
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 8.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Image.asset(
                                        'assets/icons/home/doctor.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              MyText(
                                name,
                                fontSize: 15.sp,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6.h),
                              SpecializationText(
                                specializationId: spec.isEmpty ? null : spec,
                                fontSize: 12.45.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                textAlign: TextAlign.center,
                                defaultText: '—',
                              ),
                              const Spacer(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
