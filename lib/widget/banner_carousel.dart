import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controller/banner_controller.dart';
import '../model/banner_model.dart';
import '../utils/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({Key? key}) : super(key: key);

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  Timer? _timer;
  bool _isUserScrolling = false;
  
  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      // إيقاف التشغيل التلقائي إذا كان المستخدم يتفاعل
      if (_isUserScrolling) return;
      
      final bannerController = Get.find<BannerController>();
      if (bannerController.activeBanners.isNotEmpty && _pageController.hasClients) {
        final currentIndex = bannerController.activeIndex.value;
        final nextIndex = (currentIndex + 1) % bannerController.activeBanners.length;
        
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  
  void _onUserInteractionStart() {
    setState(() {
      _isUserScrolling = true;
    });
  }
  
  void _onUserInteractionEnd() {
    // إعادة تشغيل التمرير التلقائي بعد ثانيتين من توقف التفاعل
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isUserScrolling = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final BannerController bannerController = Get.find<BannerController>();

    return Obx(() {
      if (bannerController.isLoading.value) {
        return _buildLoadingSkeleton(context);
      }

      if (bannerController.activeBanners.isEmpty) {
        return const SizedBox.shrink();
      }

      return _buildCarousel(bannerController, context);
    });
  }

  Widget _buildCarousel(BannerController bannerController, BuildContext context) {
    return SizedBox(
      height: 180.h, // الارتفاع الأصلي
      width: double.infinity,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollStartNotification) {
                _onUserInteractionStart();
              } else if (notification is ScrollEndNotification) {
                _onUserInteractionEnd();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: bannerController.activeBanners.length,
              physics: const BouncingScrollPhysics(), // تأثير ارتداد عند الوصول للنهاية
              pageSnapping: true, // تأكيد الانتقال إلى الصفحة التالية
              allowImplicitScrolling: true,
              onPageChanged: (index) {
                bannerController.updateActiveIndex(index);
                print('Banner changed to index: $index');
              },
              itemBuilder: (context, index) {
                final banner = bannerController.activeBanners[index];
                return _buildBannerItem(banner, index);
              },
            ),
          ),
          // النقاط داخل الصورة
          if (bannerController.activeBanners.length > 1)
            Positioned(
              bottom: 20.h,
              left: 0,
              right: 0,
              child: Center(
                child: _buildIndicators(bannerController),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(BannerModel banner, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        } else {
          value = index == 0 ? 1.0 : 0.0;
        }
        
        return Transform.scale(
          scale: Curves.easeOut.transform(value),
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: 8.w * (1 - value), // تأثير هامش ديناميكي
              vertical: 4.h * (1 - value),
            ),
            child: GestureDetector(
              onTap: () {
                // إضافة اهتزاز خفيف عند الضغط
                // HapticFeedback.lightImpact();
                print('Banner tapped: ${banner.title}');
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1 * value),
                      blurRadius: 10 * value,
                      offset: Offset(0, 5 * value),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        banner.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primaryLight,
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                      // تأثير لوني خفيف عند عدم التركيز
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1 * (1 - value)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicators(BannerController bannerController) {
    if (bannerController.activeBanners.length <= 1) {
      return const SizedBox.shrink();
    }

    return Obx(() => AnimatedSmoothIndicator(
      activeIndex: bannerController.activeIndex.value,
      count: bannerController.activeBanners.length,
      effect: ExpandingDotsEffect(
        dotHeight: 10.h,
        dotWidth: 10.w,
        activeDotColor: Colors.white,
        dotColor: Colors.white.withOpacity(0.5),
        expansionFactor: 2.5,
        spacing: 6.w,
      ),
    ));
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180.h, // نفس الارتفاع الأصلي
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
