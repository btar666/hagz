import 'package:get/get.dart';
import '../controller/delegate_hospitals_visits_controller.dart';

class DelegateHospitalsVisitsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DelegateHospitalsVisitsController>(
      () => DelegateHospitalsVisitsController(),
      fenix: true,
    );
  }
}
