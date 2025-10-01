import 'package:get/get.dart';

import '../controller/hospitals_controller.dart';

class HospitalsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HospitalsController>(() => HospitalsController());
  }
}
