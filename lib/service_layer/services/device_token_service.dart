import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceTokenService {
  static const String _key = 'device_token';
  static final Uuid _uuid = const Uuid();

  static Future<String> getOrCreateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;
    final token = _uuid.v4();
    await prefs.setString(_key, token);
    return token;
  }
}
