import 'package:get/get.dart';

class DoctorsFilterController extends GetxController {
  // Selected filters
  var selectedRegion = ''.obs; // empty = no filter
  var alphaOrder = 'أ-ي'.obs; // or 'ي-أ'

  // UI state
  var isRegionMenuOpen = false.obs;

  // Options
  final List<String> regions = const [
    'الجمعية',
    'شارع 40',
    'شارع 100',
    'شارع 60',
    'شارع 80',
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
    isRegionMenuOpen.value = false;
  }
}
