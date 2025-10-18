import 'package:get/get.dart';

import '../service_layer/services/user_service.dart';
import '../service_layer/services/ratings_service.dart';
import 'package:flutter/widgets.dart';

class HomeController extends GetxController {
  final UserService _userService = UserService();
  final RatingsService _ratingsService = RatingsService();

  var isLoadingDoctors = false.obs;
  var isLoadingMoreDoctors = false.obs;
  var doctors = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var page = 1.obs;
  var limit = 10.obs;
  var search = ''.obs;
  var hasMoreDoctors = true.obs;
  final ScrollController scrollController = ScrollController();

  // Top-rated doctors
  var isLoadingTopRated = false.obs;
  var topRatedDoctors = <Map<String, dynamic>>[].obs; // {doctorId, name, specialty, avg, count}

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchDoctors(reset: true);
    fetchTopRatedDoctors();
  }

  Future<void> fetchDoctors({bool reset = false}) async {
    if (reset) {
      page.value = 1;
      hasMoreDoctors.value = true;
      doctors.clear();
      isLoadingDoctors.value = true;
    } else {
      if (!hasMoreDoctors.value || isLoadingMoreDoctors.value) return;
      isLoadingMoreDoctors.value = true;
    }
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
      // has more if fetched less than total
      hasMoreDoctors.value = doctors.length < total.value;
      if (hasMoreDoctors.value) page.value = page.value + 1;
    }
    isLoadingDoctors.value = false;
    isLoadingMoreDoctors.value = false;
  }

  Future<void> fetchTopRatedDoctors({int page = 1, int limit = 10}) async {
    if (isLoadingTopRated.value) return;
    isLoadingTopRated.value = true;
    try {
      final res = await _ratingsService.getTopDoctors(page: page, limit: limit);
      if (res['ok'] == true) {
        final data = res['data'];
        final list = (data is Map && data['data'] is List)
            ? data['data'] as List
            : (data as List? ?? const []);
        topRatedDoctors.value = list.map<Map<String, dynamic>>((e) {
          final m = e as Map<String, dynamic>;
          // API returns doctor object directly with averageRating and totalRatings
          return {
            'doctorId': m['_id']?.toString() ?? '',
            'name': m['name']?.toString() ?? '',
            'specialty': m['specialization']?.toString() ?? '',
            'avg': (m['averageRating'] is num) ? (m['averageRating'] as num).toDouble() : 0.0,
            'count': (m['totalRatings'] is num) ? (m['totalRatings'] as num).toInt() : 0,
          };
        }).toList(growable: false);
      }
    } catch (_) {
    } finally {
      isLoadingTopRated.value = false;
    }
  }
  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      fetchDoctors(reset: false);
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}
