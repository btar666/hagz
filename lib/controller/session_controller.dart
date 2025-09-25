import 'package:get/get.dart';

class SessionController extends GetxController {
  // Roles: 'doctor', 'user', 'secretary', 'delegate'
  var role = 'doctor'.obs;

  void setRole(String r) {
    role.value = r;
  }
}
