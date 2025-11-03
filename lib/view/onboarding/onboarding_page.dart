import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../utils/app_colors.dart';
import '../../service_layer/services/get_storage_service.dart';
import '../../controller/locale_controller.dart';
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
                        'skip'.tr,
                        style: TextStyle(
                          fontFamily: 'Expo Arabic',
                          color: AppColors.textSecondary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _showLanguageDialog(context),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        child: Row(
                          children: [
                            Text(
                              Get.locale?.languageCode == 'en'
                                  ? 'English'
                                  : 'العربية',
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
                      ),
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
                        'back'.tr,
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
                        _currentIndex == _slides.length - 1
                            ? 'start'.tr
                            : 'next'.tr,
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

  void _showLanguageDialog(BuildContext context) {
    final storage = GetStorageService();
    final currentLanguage = Get.locale?.languageCode ?? 'ar';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        // Use a ValueNotifier to hold the selected language state
        final selectedLanguageNotifier = ValueNotifier<String>(currentLanguage);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ValueListenableBuilder<String>(
            valueListenable: selectedLanguageNotifier,
            builder: (context, selectedLanguage, _) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FEFF),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        margin: EdgeInsets.only(bottom: 20.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    // Title
                    Text(
                      'select_language'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Expo Arabic',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Language options
                    _buildLanguageOption(
                      context: context,
                      languageCode: 'ar',
                      languageName: 'العربية',
                      flag: '🇸🇦',
                      isSelected: selectedLanguage == 'ar',
                      onTap: () {
                        selectedLanguageNotifier.value = 'ar';
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildLanguageOption(
                      context: context,
                      languageCode: 'en',
                      languageName: 'English',
                      flag: '🇬🇧',
                      isSelected: selectedLanguage == 'en',
                      onTap: () {
                        selectedLanguageNotifier.value = 'en';
                      },
                    ),
                    SizedBox(height: 24.h),
                    // Confirm button
                    ElevatedButton(
                      onPressed: () {
                        final finalLanguage = selectedLanguageNotifier.value;
                        Navigator.pop(context);

                        if (finalLanguage != currentLanguage) {
                          // Save language preference
                          storage.write('selected_language', finalLanguage);

                          // Update locale
                          final newLocale = finalLanguage == 'en'
                              ? const Locale('en')
                              : const Locale('ar');
                          Get.updateLocale(newLocale);
                          // Update LocaleController to rebuild GetMaterialApp
                          final localeController = Get.find<LocaleController>();
                          localeController.updateLocale(newLocale);

                          // Force rebuild by accessing locale to trigger Obx
                          final _ = localeController.locale.value;

                          // Show success message
                          Future.delayed(const Duration(milliseconds: 300), () {
                            Get.snackbar(
                              'success'.tr,
                              'language_changed'.tr,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'confirm'.tr,
                        style: TextStyle(
                          fontFamily: 'Expo Arabic',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          fontFamily: 'Expo Arabic',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Flag emoji
            Text(flag, style: TextStyle(fontSize: 32.sp)),
            SizedBox(width: 16.w),
            // Language name
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontFamily: 'Expo Arabic',
                  fontSize: 18.sp,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            // Radio indicator
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                  : null,
            ),
          ],
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
