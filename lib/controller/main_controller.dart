import 'package:get/get.dart';
import 'banner_controller.dart';

class MainController extends GetxController {
  // Current page index for bottom navigation
  var currentIndex = 0.obs;
  
  // Home page tab index (أطباء، مستشفيات، مجمعات)
  var homeTabIndex = 0.obs;
  
  // Banner controller
  late BannerController bannerController;
  
  void changeTab(int index) {
    currentIndex.value = index;
  }
  
  void changeHomeTab(int index) {
    homeTabIndex.value = index;
  }
  
  @override
  void onInit() {
    super.onInit();
    // تهيئة banner controller
    bannerController = Get.put(BannerController());
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
