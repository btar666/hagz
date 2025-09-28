import 'package:get/get.dart';

class SessionController extends GetxController {
  // Roles: 'doctor', 'user', 'secretary', 'delegate'
  var role = 'doctor'.obs;
  // Auth token (in-memory)
  final RxnString token = RxnString();

  void setRole(String r) {
    role.value = r;
  }

  void setToken(String? value) {
    token.value = value;
  }

  void clearSession() {
    token.value = null;
  }

  bool get isAuthenticated => (token.value ?? '').isNotEmpty;

  // Maps internal role to API userType values
  String get apiUserType {
    switch (role.value) {
      case 'user':
        return 'User';
      case 'doctor':
        return 'Doctor';
      case 'secretary':
        return 'Secretary';
      case 'delegate':
        return 'Representative';
      default:
        return 'User';
    }
  }
}
