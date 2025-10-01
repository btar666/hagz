import 'package:get/get.dart';

import '../service_layer/services/user_service.dart';

class HomeController extends GetxController {
  final UserService _userService = UserService();

  var isLoadingDoctors = false.obs;
  var doctors = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var page = 1.obs;
  var limit = 10.obs;
  var search = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoctors(reset: true);
  }

  Future<void> fetchDoctors({bool reset = false}) async {
    if (reset) {
      page.value = 1;
      doctors.clear();
    }
    isLoadingDoctors.value = true;
    final res = await _userService.getDoctors(
      page: page.value,
      limit: limit.value,
      search: search.value,
    );
    if (res['ok'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      final List list = (data['data'] as List? ?? []);
      total.value = int.tryParse((data['total'] ?? '0').toString()) ?? 0;
      doctors.addAll(list.cast<Map<String, dynamic>>());
      doctors.refresh();
    }
    isLoadingDoctors.value = false;
  }
}
