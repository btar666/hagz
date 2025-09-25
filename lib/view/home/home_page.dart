import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hagz/view/home/hospital/hospital_details_page.dart';
import 'package:hagz/view/home/complex/complex_details_page.dart';
import '../../controller/main_controller.dart';
import '../../utils/app_colors.dart';
import '../../widget/search_widget.dart';
import 'search_page.dart';
import '../../widget/banner_carousel.dart';
import '../../widget/my_text.dart';
import '../../widget/specialty_text.dart';
import '../../widget/doctors_filter_dialog.dart';
import '../chat/chats_page.dart';
import 'doctors/top_rated_doctors_page.dart';
import 'doctors/doctor_profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      body: Column(
        children: [
          // Top section with header and search
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Chat icon
                  GestureDetector(
                    onTap: () => Get.to(() => const ChatsPage()),
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/home/Message Icon.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 22,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Search bar (expanded to take remaining space)
                  Expanded(
                    child: SearchWidget(
                      hint: 'ابحث عن طبيب أو مستشفى...',
                      readOnly: true,
                      onTap: () => Get.to(() => const SearchPage()),
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Profile avatar
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Rest of the content (scrollable)
          Expanded(
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          // Banner carousel section
                          const BannerCarousel(),
                          SizedBox(height: 20.h),

                          // Top rated doctors section - يظهر فقط في تبويب الأطباء
                          Obx(() {
                            if (controller.homeTabIndex.value == 0) {
                              return Column(
                                children: [
                                  _buildTopRatedDoctorsSection(),
                                  SizedBox(height: 20.h),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          }),

                          // Tab buttons (الكل)
                          _buildTabHeader(),
                          SizedBox(height: 20.h),

                          // Content tabs
                          SizedBox(
                            height: 400.h, // Fixed height for the grid
                            child: Obx(
                              () => IndexedStack(
                                index: controller.homeTabIndex.value,
                                children: [
                                  _buildDoctorsTab(),
                                  _buildHospitalsTab(),
                                  _buildMedicalCentersTab(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ), // Space before fixed bottom tabs
                        ],
                      ),
                    ),
                  ),
                ),
                // Fixed bottom tab selector
                Container(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                  child: _buildBottomTabs(controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader() {
    return Row(
      children: [
        MyText(
          'الكل',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          textAlign: TextAlign.start,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            final result = await Get.dialog(const DoctorsFilterDialog());
            if (result is Map) {
              // TODO: apply filters to data source if needed
            }
          },
          child: Icon(Icons.tune, color: AppColors.textSecondary, size: 24.sp),
        ),
      ],
    );
  }

  Widget _buildDoctorsTab() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio:
            178 / 247, // نسبة العرض إلى الارتفاع للحصول على 178h × 247w
      ),
      itemCount: 6, // Sample count
      itemBuilder: (context, index) {
        return _buildDoctorCard(index);
      },
    );
  }

  Widget _buildHospitalsTab() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio:
            178 / 209, // نسبة العرض إلى الارتفاع للحصول على 178w × 209h
      ),
      itemCount: 4, // Sample count
      itemBuilder: (context, index) {
        return _buildHospitalCard(index);
      },
    );
  }

  Widget _buildMedicalCentersTab() {
    // عرض المجمعات بقائمة منفصلة لكن بنفس تصميم المستشفيات وبنفس شبكة العرض
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 178 / 209,
      ),
      itemCount: _complexNames.length,
      itemBuilder: (context, index) {
        return _buildComplexCard(index);
      },
    );
  }

  Widget _buildDoctorCard(int index) {
    final List<String> doctorNames = [
      'د. آرين',
      'د. صوفيا',
      'د. سونجوز',
      'د. آرين',
      'د. مالوون',
      'د. آرين',
    ];

    final List<String> specialties = [
      'جراحة القلب',
      'جراحة القلب',
      'جراحة القلب',
      'جراحة القلب',
      'جراحة العيون',
      'جراحة القلب',
    ];

    return GestureDetector(
      onTap: () {
        // الانتقال إلى صفحة تفاصيل الطبيب
        Get.to(
          () => DoctorProfilePage(
            doctorName: doctorNames[index % doctorNames.length],
            specialization: specialties[index % specialties.length],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
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
            // Doctor image with rounded rectangle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: AspectRatio(
                aspectRatio: 1.0, // Perfect square
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
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Doctor name
            MyText(
              doctorNames[index % doctorNames.length],
              fontSize: 15.sp, // حجم أكبر للأطباء في الكاردات السفلية
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h), // زيادة المسافة بين الاسم والتخصص
            // Specialty
            SpecialtyText(
              specialties[index % specialties.length],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // بيانات المجمعات (منفصلة عن المستشفيات)
  final List<String> _complexNames = const [
    'مجمع الشفاء الطبي',
    'مجمع الرفاه الطبي',
    'مجمع الحياة الطبي',
    'مجمع النخيل الطبي',
  ];
  final List<String> _complexLocations = const [
    'شارع الزهور قرب دوار الجامعة',
    'المنطقة الطبية قرب المستشفى التعليمي',
    'شارع المدينة مجاور مجمع الأطباء',
    'الحي الراقي قرب حديقة النخيل',
  ];

  Widget _buildHospitalCard(int index) {
    final List<String> hospitalNames = [
      'مستشفى روما',
      'مستشفى النور',
      'مستشفى الحياة',
      'مستشفى الأمل',
    ];

    final List<String> hospitalLocations = [
      'شارع المتحف قرب نقابة الأطباء',
      'شارع الكندي بجانب الجامعة الأردنية',
      'شارع الملكة رانيا قرب المدينة الطبية',
      'شارع عبدون بجانب مجمع النخيل',
    ];

    return GestureDetector(
      onTap: () {
        // الانتقال إلى صفحة تفاصيل المستشفى
        Get.to(
          () => HospitalDetailsPage(
            hospitalName: hospitalNames[index % hospitalNames.length],
            hospitalLocation:
                hospitalLocations[index % hospitalLocations.length],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
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
            SizedBox(height: 8.h), // تقليل المسافة العلوية
            // Hospital image with rounded rectangle - أبعاد محددة 155w × 160h مع مسافات محددة
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 9.w,
              ), // مسافة 9 من الجوانب
              child: Container(
                width: 155.w, // عرض محدد للصورة
                height: 140.h, // تقليل ارتفاع الصورة لحل overflow
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    'assets/icons/home/hospital.png', // صورة المستشفى المخصصة
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.local_hospital,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h), // تقليل المسافة
            // Hospital name
            Flexible(
              child: MyText(
                hospitalNames[index % hospitalNames.length],
                fontFamily: 'Expo Arabic',
                color: AppColors.textPrimary,
                fontSize: 16.46.sp,
                fontWeight: FontWeight.w700, // Bold
                height: 1.0, // line-height: 100%
                letterSpacing: 0, // letter-spacing: 0%
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8.h), // مسافة سفلية
          ],
        ),
      ),
    );
  }

  Widget _buildComplexCard(int index) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ComplexDetailsPage(
            complexName: _complexNames[index % _complexNames.length],
            complexLocation:
                _complexLocations[index % _complexLocations.length],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
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
              padding: EdgeInsets.symmetric(horizontal: 9.w),
              child: Container(
                width: 155.w,
                height: 140.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    'assets/icons/home/hospital.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.apartment,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Flexible(
              child: MyText(
                _complexNames[index % _complexNames.length],
                fontFamily: 'Expo Arabic',
                color: AppColors.textPrimary,
                fontSize: 16.46.sp,
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: 0,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRatedDoctorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Get.to(() => const TopRatedDoctorsPage()),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MyText(
                    'الأطباء الأعلى تقييماً',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.start,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 197.h, // ارتفاع محدد للكاردات العلوية
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 0),
            physics: const BouncingScrollPhysics(),
            itemCount: 8, // زيادة عدد الأطباء لضمان السكرول
            separatorBuilder: (context, index) =>
                SizedBox(width: 12.w), // مسافة موحدة بين جميع الكاردات
            itemBuilder: (context, index) {
              return SizedBox(
                width: 137.w, // عرض محدد للكاردات العلوية
                height: 197.h, // ارتفاع محدد
                child: _buildTopRatedDoctorCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopRatedDoctorCard(int index) {
    final List<String> doctorNames = [
      'د. آرين',
      'د. صوفيا',
      'د. سونجوز',
      'د. مالوون',
      'د. أحمد',
      'د. فاطمة',
      'د. خالد',
      'د. مريم',
    ];

    final List<String> specialties = [
      'جراحة القلب',
      'طب العيون',
      'جراحة القلب',
      'جراحة العيون',
      'طب الأسنان',
      'طب الأطفال',
      'جراحة العظام',
      'طب الجلدية',
    ];

    return GestureDetector(
      onTap: () {
        // الانتقال إلى صفحة تفاصيل الطبيب
        Get.to(
          () => DoctorProfilePage(
            doctorName: doctorNames[index],
            specialization: specialties[index],
          ),
        );
      },
      child: Container(
        width: double.infinity, // يملأ عرض الـ SizedBox المحدد
        height: double.infinity, // يملأ ارتفاع الـ SizedBox المحدد
        decoration: BoxDecoration(
          color: AppColors.surface,
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
            SizedBox(height: 5.h),
            // Doctor image with rounded rectangle - مثل الكاردات السفلية
            Center(
              child: Container(
                width: 126.w, // عرض محدد للصورة
                height: 135.h, // ارتفاع محدد للصورة
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    'assets/icons/home/doctor.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Doctor name
            MyText(
              doctorNames[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h), // زيادة المسافة بين الاسم والتخصص
            // Specialty
            SpecialtyText(
              specialties[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTabs(MainController controller) {
    final List<String> tabLabels = ['أطباء', 'مستشفيات', 'مجمعات'];

    return Obx(
      () => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // أبيض
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Row(
          children: List.generate(3, (index) {
            final isSelected = controller.homeTabIndex.value == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changeHomeTab(index),
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
                      fontWeight: FontWeight.w600, // SemiBold
                      fontSize: 16.sp,
                      height: 1.0, // line-height: 100%
                      letterSpacing: 0, // letter-spacing: 0%
                      color: isSelected ? Colors.white : AppColors.primary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
