import 'package:get/get.dart';
import '../service_layer/services/about_service.dart';

class AboutController extends GetxController {
  final AboutService _service = AboutService();

  var isLoading = false.obs;
  var appName = ''.obs;
  var appVersion = ''.obs;
  var appAbout = ''.obs;
  var supportLink = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAboutInfo();
  }

  Future<void> loadAboutInfo() async {
    isLoading.value = true;
    try {
      final res = await _service.getAboutInfo();
      if (res['ok'] == true) {
        final data = res['data'];
        // Handle nested data structure
        final actualData = (data is Map && data['data'] is Map)
            ? data['data']
            : data;

        if (actualData is Map) {
          appName.value = actualData['name']?.toString() ?? '';
          appVersion.value = actualData['version']?.toString() ?? '';
          appAbout.value = actualData['about']?.toString() ?? '';
          supportLink.value = actualData['support']?.toString() ?? '';
          print('✅ Loaded about info: $appName, $appVersion');
        }
      } else {
        print('❌ Failed to load about info: ${res['message'] ?? res['data']}');
      }
    } catch (e) {
      print('❌ Error loading about info: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
