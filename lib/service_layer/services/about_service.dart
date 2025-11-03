import 'api_request.dart';
import '../../utils/constants.dart';

class AboutService {
  final ApiRequest _api = ApiRequest();

  /// GET /api/about/
  /// Get application information
  Future<Map<String, dynamic>> getAboutInfo() async {
    final url = ApiConstants.about;
    print('ℹ️ GET ABOUT INFO URL: $url');
    final result = await _api.get(url);
    print('ℹ️ GET ABOUT INFO RESPONSE: $result');
    return result;
  }
}
