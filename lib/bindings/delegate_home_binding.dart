import 'package:get/get.dart';
import '../controller/delegate_home_controller.dart';

class DelegateHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DelegateHomeController>(
      () => DelegateHomeController(),
      fenix: true, // إعادة إنشاء Controller عند الحاجة
    );
  }
}
