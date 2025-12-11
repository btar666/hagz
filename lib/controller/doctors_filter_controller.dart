import 'package:get/get.dart';

class DoctorsFilterController extends GetxController {
  // Selected filters
  var selectedRegion = ''.obs; // empty = no filter
  var alphaOrder = 'أ-ي'.obs; // or 'ي-أ'
  var minFollowers = ''.obs; // نص لتسهيل الإدخال ثم التحويل
  var districtName = ''.obs;

  // UI state
  var isRegionMenuOpen = false.obs;

  // Options
  final List<String> regions = const [
    '',
    'بغداد',
    'البصرة',
    'نينوى',
    'أربيل',
    'النجف',
    'كربلاء',
    'الأنبار',
    'ديالى',
    'صلاح الدين',
    'واسط',
    'ذي قار',
    'بابل',
    'كركوك',
    'السليمانية',
    'المثنى',
    'القادسية',
    'ميسان',
    'دهوك',
  ];

  void toggleRegionMenu() {
    isRegionMenuOpen.toggle();
  }

  void pickRegion(String region) {
    selectedRegion.value = region;
    isRegionMenuOpen.value = false;
  }

  void toggleAlphaOrder() {
    alphaOrder.value = alphaOrder.value == 'أ-ي' ? 'ي-أ' : 'أ-ي';
  }

  void clearAll() {
    selectedRegion.value = '';
    alphaOrder.value = 'أ-ي';
    minFollowers.value = '';
    districtName.value = '';
    isRegionMenuOpen.value = false;
  }
}
