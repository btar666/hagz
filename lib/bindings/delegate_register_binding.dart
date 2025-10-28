import 'package:get/get.dart';
import '../controller/delegate_register_controller.dart';

class DelegateRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DelegateRegisterController>(DelegateRegisterController());
  }
}
