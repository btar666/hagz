import 'package:get/get.dart';
import '../controller/delegate_complexes_visits_controller.dart';

class DelegateComplexesVisitsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DelegateComplexesVisitsController>(
      () => DelegateComplexesVisitsController(),
      fenix: true,
    );
  }
}
