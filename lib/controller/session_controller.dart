import 'package:get/get.dart';
import '../service_layer/services/get_storage_service.dart';

class SessionController extends GetxController {
  // Roles: 'doctor', 'user', 'secretary', 'delegate'
  var role = 'doctor'.obs;
  // Auth token (in-memory)
  final RxnString token = RxnString();

  static const String _kTokenKey = 'auth_token';
  static const String _kRoleKey = 'user_role';
  final GetStorageService _storage = GetStorageService();

  @override
  void onInit() {
    super.onInit();
    _loadPersistedSession();
  }

  void setRole(String r) {
    role.value = r;
    _storage.write(_kRoleKey, r);
  }

  void setToken(String? value) {
    token.value = value;
    if ((value ?? '').isNotEmpty) {
      _storage.write(_kTokenKey, value);
    } else {
      _storage.remove(_kTokenKey);
    }
  }

  void clearSession() {
    token.value = null;
    _storage.remove(_kTokenKey);
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

  void _loadPersistedSession() {
    final savedToken = _storage.read<String>(_kTokenKey);
    final savedRole = _storage.read<String>(_kRoleKey);
    if ((savedToken ?? '').isNotEmpty) {
      token.value = savedToken;
    }
    if ((savedRole ?? '').isNotEmpty) {
      role.value = savedRole!;
    }
  }
}
