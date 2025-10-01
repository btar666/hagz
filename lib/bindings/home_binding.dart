import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../controller/hospitals_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<HospitalsController>(() => HospitalsController());
  }
}
