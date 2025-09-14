import 'package:get/get.dart';
import '../model/banner_model.dart';

class BannerController extends GetxController {
  // قائمة الإعلانات
  RxList<BannerModel> banners = <BannerModel>[].obs;
  
  // حالة التحميل
  RxBool isLoading = false.obs;
  
  // فهرس الإعلان النشط في الكاروسيل
  RxInt activeIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadBanners();
  }

  /// تحميل الإعلانات (حالياً من البيانات المحلية)
  void loadBanners() {
    isLoading.value = true;
    
    // محاكاة تأخير التحميل
    Future.delayed(const Duration(milliseconds: 500), () {
      banners.value = _getLocalBanners();
      isLoading.value = false;
    });
  }

  /// الحصول على البيانات المحلية للإعلانات
  List<BannerModel> _getLocalBanners() {
    return [
      BannerModel(
        id: 1,
        image: 'assets/icons/home/news1.png',
        title: 'إعلان رقم 1 - عروض طبية مميزة',
        description: 'احصل على استشارة طبية مجانية مع أفضل الأطباء',
        isActive: true,
      ),
      BannerModel(
        id: 2,
        image: 'assets/icons/home/news1.png',
        title: 'إعلان رقم 2 - فحوصات شاملة',
        description: 'خصم 25% على جميع الفحوصات الطبية والتحاليل',
        isActive: true,
      ),
      BannerModel(
        id: 3,
        image: 'assets/icons/home/news1.png',
        title: 'إعلان رقم 3 - حجز سريع',
        description: 'احجز موعدك بسهولة مع أقرب طبيب لك',
        isActive: true,
      ),
      BannerModel(
        id: 4,
        image: 'assets/icons/home/news1.png',
        title: 'إعلان رقم 4 - خدمات متميزة',
        description: 'أفضل الخدمات الطبية بأعلى جودة',
        isActive: true,
      ),
    ];
  }

  /// تحديث فهرس الإعلان النشط
  void updateActiveIndex(int index) {
    activeIndex.value = index;
  }

  /// إعادة تحميل الإعلانات
  @override
  void refresh() {
    loadBanners();
  }

  /// الحصول على الإعلانات النشطة فقط
  List<BannerModel> get activeBanners {
    return banners.where((banner) => banner.isActive).toList();
  }
}
