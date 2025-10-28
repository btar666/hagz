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

  // Filter parameters
  var selectedCity = ''.obs;
  var sortOrder = ''.obs; // 'أ-ي' or 'ي-أ' or ''

  // Top-rated doctors
  var isLoadingTopRated = false.obs;
  var topRatedDoctors =
      <Map<String, dynamic>>[].obs; // {doctorId, name, specialty, avg, count}

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

    // Use filter API if filters are applied
    Map<String, dynamic> res;
    if (selectedCity.value.isNotEmpty || sortOrder.value.isNotEmpty) {
      String? sortBy = sortOrder.value == 'أ-ي' ? 'name' : null;
      String? order = sortOrder.value == 'أ-ي'
          ? 'asc'
          : (sortOrder.value == 'ي-أ' ? 'desc' : null);

      res = await _userService.filterDoctors(
        query: search.value,
        city: selectedCity.value.isNotEmpty ? selectedCity.value : null,
        sortBy: sortBy,
        order: order,
        page: page.value,
        limit: limit.value,
      );
    } else {
      res = await _userService.getDoctors(
        page: page.value,
        limit: limit.value,
        search: search.value,
      );
    }

    if (res['ok'] == true) {
      final data = res['data'] as Map<String, dynamic>;

      // Handle different API response structures
      List list;
      int totalCount = 0;

      if (data.containsKey('data') && data['data'] is Map) {
        // Filter API response structure: {data: {users: [...], pagination: {...}}}
        final innerData = data['data'] as Map<String, dynamic>;
        list = (innerData['users'] as List? ?? []);
        final pagination = innerData['pagination'] as Map<String, dynamic>?;
        totalCount =
            int.tryParse((pagination?['total'] ?? '0').toString()) ?? 0;
      } else if (data.containsKey('data') && data['data'] is List) {
        // Regular API response structure: {data: [...], total: ...}
        list = (data['data'] as List? ?? []);
        totalCount = int.tryParse((data['total'] ?? '0').toString()) ?? 0;
      } else {
        list = [];
      }

      total.value = totalCount;
      doctors.addAll(list.cast<Map<String, dynamic>>());
      doctors.refresh();
      // has more if fetched less than total
      hasMoreDoctors.value = doctors.length < total.value;
      if (hasMoreDoctors.value) page.value = page.value + 1;
    }
    isLoadingDoctors.value = false;
    isLoadingMoreDoctors.value = false;
  }

  void applyFilters(String city, String alpha) {
    selectedCity.value = city;
    sortOrder.value = alpha;
    fetchDoctors(reset: true);
  }

  void clearFilters() {
    selectedCity.value = '';
    sortOrder.value = '';
    fetchDoctors(reset: true);
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
            'image': m['image']?.toString() ?? '',
            'avg': (m['averageRating'] is num)
                ? (m['averageRating'] as num).toDouble()
                : 0.0,
            'count': (m['totalRatings'] is num)
                ? (m['totalRatings'] as num).toInt()
                : 0,
          };
        }).toList();
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
