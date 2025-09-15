import 'package:get/get.dart';

class HospitalDetailsController extends GetxController {
  // Observable variables
  var isRideExpanded = false.obs;
  
  // Toggle ride expansion
  void toggleRideExpansion() {
    isRideExpanded.value = !isRideExpanded.value;
  }
}
