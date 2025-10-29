import 'package:get/get.dart';
import '../controller/delegate_all_visits_controller.dart';

class DelegateAllVisitsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DelegateAllVisitsController>(
      () => DelegateAllVisitsController(),
      fenix: true, // إعادة إنشاء Controller عند الحاجة
    );
  }
}
