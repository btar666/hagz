import 'package:get/get.dart';
import '../controller/delegate_doctors_visits_controller.dart';

class DelegateDoctorsVisitsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DelegateDoctorsVisitsController>(
      () => DelegateDoctorsVisitsController(),
      fenix: true,
    );
  }
}
