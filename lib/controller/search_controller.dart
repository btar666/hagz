import 'dart:async';

import 'package:get/get.dart';

import '../service_layer/services/hospital_service.dart';
import '../service_layer/services/user_service.dart';

class SearchController extends GetxController {
  final HospitalService _hospitalService = HospitalService();
  final UserService _userService = UserService();

  var isLoading = false.obs;
  var results = <Map<String, dynamic>>[].obs;
  var total = 0.obs;

  var page = 1.obs;
  var limit = 20.obs;
  var query = ''.obs;
  // وضع البحث: 'doctors' | 'hospitals' | 'complexes' | 'all'
  var mode = 'all'.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    // استماع لتغير نص البحث مع ديباونس
    ever<String>(query, (text) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 350), () {
        page.value = 1;
        fetch(reset: true);
      });
    });
  }

  void initMode(String m) {
    mode.value = m;
    page.value = 1;
    results.clear();
    fetch(reset: true);
  }

  Future<void> fetch({bool reset = false}) async {
    if (reset) {
      results.clear();
      page.value = 1; // Reset page when resetting
    }
    isLoading.value = true;

    Map<String, dynamic> res;
    // اختيار الـ endpoint حسب الوضع
    if (mode.value == 'doctors') {
      // جلب الأطباء فقط (بالبحث إن وُجد)
      res = await _userService.getDoctors(
        page: page.value,
        limit: limit.value,
        search: query.value,
      );
      if (res['ok'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final List list = (data['data'] as List? ?? []);
        total.value =
            int.tryParse((data['total'] ?? '0').toString()) ?? list.length;
        // طباعة النتائج مباشرة بنمط موحد
        results.addAll(
          list.map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            m['type'] = 'طبيب';
            return m;
          }).cast<Map<String, dynamic>>(),
        );
        results.refresh();
        isLoading.value = false;
        return;
      }
    } else {
      if (query.value.isEmpty) {
        // عرض المستشفيات/المجمعات دون بحث
        res = await _hospitalService.getHospitals();
        // تطبيع البنية إلى شكل البحث الشامل
        if (res['ok'] == true) {
          final d = res['data'] as Map<String, dynamic>;
          final list = (d['data'] as List? ?? []);
          final hospitalsWrapped = {
            'ok': true,
            'data': {
              'data': {
                'hospitals': {'data': list},
                'doctors': {'data': []},
              },
              'pagination': {'totalResults': list.length},
            },
          };
          res = hospitalsWrapped;
        }
      } else {
        // بحث نصي شامل (نفلتر لاحقاً بالوضع)
        res = await _hospitalService.searchHospitalsAndDoctors(
          searchQuery: query.value,
          page: page.value,
          limit: limit.value,
        );
      }
    }

    if (res['ok'] == true) {
      final responseData = res['data'] as Map<String, dynamic>;
      final innerData = responseData['data'] as Map<String, dynamic>?;

      if (innerData != null) {
        // دمج بيانات المستشفيات والأطباء وفق الوضع
        final hospitalsData = innerData['hospitals'] as Map<String, dynamic>?;
        final doctorsData = innerData['doctors'] as Map<String, dynamic>?;

        final List<Map<String, dynamic>> allResults = [];

        // إضافة المستشفيات (أو المجمعات) عندما يكون الوضع يسمح بذلك
        if (mode.value != 'doctors' &&
            hospitalsData != null &&
            hospitalsData['data'] != null) {
          final hospitalsList = hospitalsData['data'] as List;
          for (var hospital in hospitalsList) {
            final hospitalMap = hospital as Map<String, dynamic>;
            // إضافة حقل type للمستشفى إذا لم يكن موجوداً
            hospitalMap['type'] = hospitalMap['type'] ?? 'مستشفى';
            if (mode.value == 'hospitals' && hospitalMap['type'] != 'مستشفى')
              continue;
            if (mode.value == 'complexes' && hospitalMap['type'] != 'مجمع طبي')
              continue;
            allResults.add(hospitalMap);
          }
        }

        // إضافة الأطباء عندما يكون الوضع يسمح بذلك
        if (mode.value != 'hospitals' &&
            mode.value != 'complexes' &&
            doctorsData != null &&
            doctorsData['data'] != null) {
          final doctorsList = doctorsData['data'] as List;
          for (var doctor in doctorsList) {
            final doctorMap = doctor as Map<String, dynamic>;
            // إضافة حقل type للطبيب
            doctorMap['type'] = 'طبيب';
            allResults.add(doctorMap);
          }
        }

        // إضافة النتائج
        results.addAll(allResults);
        results.refresh();

        // تحديث inquiries
        final accomplishedData =
            innerData['pagination'] as Map<String, dynamic>?;
        total.value =
            (accomplishedData?['totalResults'] as num?)?.toInt() ??
            allResults.length;
      }
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
