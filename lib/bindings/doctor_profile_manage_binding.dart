import 'package:get/get.dart';
import '../controller/doctor_profile_manage_controller.dart';

class DoctorProfileManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DoctorProfileManageController>(DoctorProfileManageController());
  }
}

