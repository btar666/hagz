import 'dart:async';

import 'package:get/get.dart';

import '../service_layer/services/user_service.dart';

class SearchController extends GetxController {
  final UserService _userService = UserService();

  var isLoading = false.obs;
  var results = <Map<String, dynamic>>[].obs;
  var total = 0.obs;

  var page = 1.obs;
  var limit = 20.obs;
  var query = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    // تحميل أولي لكل الأطباء
    fetch(reset: true);
    // استماع لتغير نص البحث مع ديباونس
    ever<String>(query, (text) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 350), () {
        page.value = 1;
        fetch(reset: true);
      });
    });
  }

  Future<void> fetch({bool reset = false}) async {
    if (reset) {
      results.clear();
    }
    isLoading.value = true;
    final res = await _userService.getDoctors(
      page: page.value,
      limit: limit.value,
      search: query.value,
    );
    if (res['ok'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      final List list = (data['data'] as List? ?? []);
      total.value = int.tryParse((data['total'] ?? '0').toString()) ?? 0;
      results.addAll(list.cast<Map<String, dynamic>>());
      results.refresh();
    }
    isLoading.value = false;
  }

  void onQueryChanged(String text) {
    query.value = text;
  }

  Future<void> loadMore() async {
    if (results.length >= total.value) return;
    page.value += 1;
    await fetch();
  }
}
