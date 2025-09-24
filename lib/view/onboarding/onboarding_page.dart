import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../utils/app_colors.dart';
import 'user_type_selection_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_SlideData> _slides = const [
    _SlideData(
      imagePath: 'assets/icons/home/sblash1.png',
      title: '" ابحث عن طبيبك بسهولة "',
      description: 'تصفح مئات الأطباء من مختلف\nالاختصاصات في مكان واحد.',
    ),
    _SlideData(
      imagePath: 'assets/icons/home/sblash2.png',
      title: '" رعاية موثوقة دوماً "',
      description: 'أطباء معتمدون، معلومات دقيقة،\nوتجربة سهلة في كل خطوة.',
    ),
    _SlideData(
      imagePath: 'assets/icons/home/sblash3.png',
      title: '" احجز موعدك بثوانٍ "',
      description:
          'اختر اليوم و الوقت المناسبين\nلك من المواعيد المتاحة فوراً.',
    ),
  ];

  void _goNext() {
    if (_currentIndex == _slides.length - 1) {
      Get.offAll(() => const UserTypeSelectionPage());
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBack() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              // Top Row (Skip on the left, Language on the right)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Get.offAll(() => const UserTypeSelectionPage()),
                      child: Text(
                        'تخطي',
                        style: TextStyle(
                          fontFamily: 'Expo Arabic',
                          color: AppColors.textSecondary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'العربية',
                          style: TextStyle(
                            fontFamily: 'Expo Arabic',
                            color: AppColors.textPrimary,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        const Icon(
                          Icons.language,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return _OnboardingSlide(
                      imagePath: slide.imagePath,
                      title: slide.title,
                      description: slide.description,
                    );
                  },
                ),
              ),

              SizedBox(height: 10.h),

              // Page Indicator
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _slides.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8.h,
                    dotWidth: 8.w,
                    spacing: 8.w,
                    expansionFactor: 3,
                    activeDotColor: AppColors.textPrimary,
                    dotColor: AppColors.textLight,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Bottom navigation (Back / Next)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _currentIndex == 0 ? null : _goBack,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.chevron_left),
                      label: Text(
                        'عودة',
                        style: TextStyle(
                          fontFamily: 'Expo Arabic',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: _currentIndex == 0
                              ? AppColors.textLight
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _goNext,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                      label: Text(
                        _currentIndex == _slides.length - 1 ? 'ابدأ' : 'التالي',
                        style: TextStyle(
                          fontFamily: 'Expo Arabic',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _OnboardingSlide({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8.h),
          // Illustration
          SizedBox(
            height: 360.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 120.h,
                  left: 24.w,
                  right: 24.w,
                  child: Container(
                    height: 90.h,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                ),
                Image.asset(
                  imagePath,
                  width: 300.w,
                  height: 300.h,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Expo Arabic',
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Expo Arabic',
              fontSize: 18.sp,
              height: 1.6,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final String imagePath;
  final String title;
  final String description;

  const _SlideData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}
