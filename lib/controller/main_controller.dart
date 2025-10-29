import 'package:get/get.dart';
import 'banner_controller.dart';
import 'home_controller.dart';
import 'hospitals_controller.dart';
import '../bindings/delegate_home_binding.dart';
import '../bindings/delegate_all_visits_binding.dart';
import 'delegate_home_controller.dart';
import 'delegate_all_visits_controller.dart';
import 'session_controller.dart';

class MainController extends GetxController {
  // Current page index for bottom navigation
  var currentIndex = 0.obs;

  // Home page tab index (أطباء، مستشفيات، مجمعات)
  var homeTabIndex = 0.obs;

  // Global nav loading to skeletonize pages on tab switch
  var isNavLoading = false.obs;

  // Banner controller
  late BannerController bannerController;

  void changeTab(int index) {
    currentIndex.value = index;

    // حذف Controllers القديمة عند التنقل بين صفحات المندوب
    final session = Get.find<SessionController>();
    if (session.role.value == 'delegate') {
      // حذف Controller الصفحة السابقة إذا كانت موجودة
      if (index == 0) {
        // دخول صفحة الرئيسية - حذف Controller جميع الزيارات
        if (Get.isRegistered<DelegateAllVisitsController>()) {
          Get.delete<DelegateAllVisitsController>();
        }
        // تهيئة Controller الرئيسية
        DelegateHomeBinding().dependencies();
      } else if (index == 1) {
        // دخول صفحة جميع الزيارات - حذف Controller الرئيسية
        if (Get.isRegistered<DelegateHomeController>()) {
          Get.delete<DelegateHomeController>();
        }
        // تهيئة Controller جميع الزيارات
        DelegateAllVisitsBinding().dependencies();
      }
    }

    // فعّل تأثير Skeleton عام عند كل تبديل تبويب ليظهر على الكروت فوراً
    _pulseNavLoading();
    // وعند الذهاب للرئيسية فعّل تحميل القوائم لعرض بطاقات وهمية من المصدر
    if (index == 0) {
      _triggerHomeRefreshWithSkeletons();
    }
  }

  void changeHomeTab(int index) {
    homeTabIndex.value = index;

    // جلب البيانات عند تغيير التبويب
    if (index == 0) {
      // عند الضغط على تبويب الأطباء، التحديث فقط إذا القائمة فارغة
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        if (home.doctors.isEmpty && !home.isLoadingDoctors.value) {
          home.fetchDoctors(reset: true);
        }
      }
    } else if (index == 1 || index == 2) {
      // عند الضغط على مستشفيات أو مجمعات طبية
      final HospitalsController hospitalsController =
          Get.find<HospitalsController>();
      if (hospitalsController.hospitals.isEmpty &&
          !hospitalsController.isLoading.value) {
        hospitalsController.fetchHospitals();
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    // تهيئة banner controller
    bannerController = Get.put(BannerController());
  }

  void _pulseNavLoading() async {
    isNavLoading.value = true;
    // مدة قصيرة تكفي لعرض التأثير حتى يبدأ تحميل البيانات الفعلي للصفحة
    await Future.delayed(const Duration(milliseconds: 450));
    isNavLoading.value = false;
  }

  void _triggerHomeRefreshWithSkeletons() {
    // Doctors list + Top rated
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      // فقط إذا لم يتم التحميل مسبقاً
      if (!home.isLoadingDoctors.value && home.doctors.isEmpty) {
        // إعداد حالة التحميل لإظهار Skeletonizer في الشبكات
        home.isLoadingDoctors.value = true;
        home.isLoadingMoreDoctors.value = false;
        home.page.value = 1;
        home.doctors.clear();
        // إعادة الجلب (سيظهر Skeleton حتى تكتمل)
        home.fetchDoctors(reset: true);
      }
      // قمة التقييمات: فقط إذا كانت فارغة
      if (home.topRatedDoctors.isEmpty && !home.isLoadingTopRated.value) {
        home.topRatedDoctors.value = <Map<String, dynamic>>[];
        home.fetchTopRatedDoctors();
      }
    }
    // Hospitals grid
    if (Get.isRegistered<HospitalsController>()) {
      final hospitals = Get.find<HospitalsController>();
      if (hospitals.hospitals.isEmpty && !hospitals.isLoading.value) {
        hospitals.isLoading.value = true;
        hospitals.hospitals.clear();
        hospitals.fetchHospitals();
      }
    }
  }

  // Navigation methods using GetX
  void goToDoctorDetails(String doctorId) {
    Get.toNamed('/doctor-details', arguments: {'doctorId': doctorId});
  }

  void goToHospitalDetails(String hospitalId) {
    Get.toNamed('/hospital-details', arguments: {'hospitalId': hospitalId});
  }

  void goToBooking() {
    Get.toNamed('/booking');
  }

  void goToSpecialtyDoctors(String specialty) {
    Get.toNamed('/specialty-doctors', arguments: {'specialty': specialty});
  }
}
