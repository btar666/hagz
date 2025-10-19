import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../service_layer/services/doctor_statistics_service.dart';
import 'session_controller.dart';

class DoctorStatisticsController extends GetxController {
  final DoctorStatisticsService _service = DoctorStatisticsService();
  final SessionController _session = Get.find<SessionController>();

  // Unified tab state (kept for other screens if needed)
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedTab = 'daily'.obs; // daily | range | yearly | overall
  var date = DateTime.now().obs;
  var rangeStart = Rxn<DateTime>();
  var rangeEnd = Rxn<DateTime>();
  var year = DateTime.now().year.obs;
  var stats = <String, dynamic>{}.obs;

  // Old design needs parallel datasets
  var isLoadingDaily = false.obs;
  var isLoadingMonthly = false.obs;
  var isLoadingYearly = false.obs;
  var isLoadingRange = false.obs;

  var daily = <String, dynamic>{}.obs;
  var monthly = <String, dynamic>{}.obs; // from range
  var yearly = <String, dynamic>{}.obs; // from yearly endpoint
  var rangeData = <String, dynamic>{}.obs; // custom bottom section

  // Selections for old design headers
  var monthlyYear = DateTime.now().year.obs;
  var monthlyMonth = DateTime.now().month.obs;

  String? get doctorId => _session.currentUser.value?.id;

  String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  // =========== Tab-oriented loaders (kept) ==========
  Future<void> loadDaily() async {
    final id = doctorId;
    if (id == null || id.isEmpty) return;
    _start();
    try {
      final res = await _service.getDaily(doctorId: id, date: _fmtDate(date.value));
      _handle(res);
    } finally {
      _end();
    }
  }

  Future<void> loadRange() async {
    final id = doctorId;
    if (id == null || id.isEmpty) return;
    final s = rangeStart.value;
    final e = rangeEnd.value;
    if (s == null || e == null) return;
    _start();
    try {
      final res = await _service.getRange(
        doctorId: id,
        startDate: _fmtDate(s),
        endDate: _fmtDate(e),
      );
      _handle(res);
    } finally {
      _end();
    }
  }

  Future<void> loadYearly() async {
    final id = doctorId;
    if (id == null || id.isEmpty) return;
    _start();
    try {
      final res = await _service.getYearly(doctorId: id, year: year.value.toString());
      _handle(res);
    } finally {
      _end();
    }
  }

  Future<void> loadOverall() async {
    final id = doctorId;
    if (id == null || id.isEmpty) return;
    _start();
    try {
      final res = await _service.getOverall(doctorId: id);
      _handle(res);
    } finally {
      _end();
    }
  }

  // =========== Old design loaders ==========
  Future<void> loadDailyAt(DateTime d) async {
    final id = doctorId;
    if (id == null || id.isEmpty) return;
    isLoadingDaily.value = true;
    try {
      final res = await _service.getDaily(doctorId: id, date: _fmtDate(d));
      if (res['ok'] == true) {
        final data = res['data']?['data'] ?? res['data'];
        daily.value = (data is Map<String, dynamic>) ? data : {};
      }
    } finally {
      isLoadingDaily.value = false;
    }
  }

  Future<void> loadMonthly(int y, int m) async {
    final id = doctorId;
    if (id == null || id.isEmpty) return;
    isLoadingMonthly.value = true;
    monthlyYear.value = y;
    monthlyMonth.value = m;
    try {
      final start = DateTime(y, m, 1);
      final end = DateTime(y, m + 1, 0);
      final res = await _service.getRange(
        doctorId: id,
        startDate: _fmtDate(start),
        endDate: _fmtDate(end),
      );
      if (res['ok'] == true) {
        final data = res['data']?['data'] ?? res['data'];
        monthly.value = (data is Map<String, dynamic>) ? data : {};
      }
    } finally {
      isLoadingMonthly.value = false;
    }
  }

  Future<void> loadYearlyAt(int y) async {
    final id = doctorId;
    if (id == null || id.isEmpty) return;
    isLoadingYearly.value = true;
    year.value = y; // track selection for header
    try {
      final res = await _service.getYearly(doctorId: id, year: y.toString());
      if (res['ok'] == true) {
        final data = res['data']?['data'] ?? res['data'];
        yearly.value = (data is Map<String, dynamic>) ? data : {};
      }
    } finally {
      isLoadingYearly.value = false;
    }
  }

  Future<void> loadRangeCurrent() async {
    final id = doctorId;
    if (id == null || id.isEmpty) return;
    final s = rangeStart.value;
    final e = rangeEnd.value;
    if (s == null || e == null) return;
    isLoadingRange.value = true;
    try {
      final res = await _service.getRange(
        doctorId: id,
        startDate: DateFormat('yyyy-MM-dd').format(s),
        endDate: DateFormat('yyyy-MM-dd').format(e),
      );
      if (res['ok'] == true) {
        final data = res['data']?['data'] ?? res['data'];
        rangeData.value = (data is Map<String, dynamic>) ? data : {};
      }
    } finally {
      isLoadingRange.value = false;
    }
  }

  // =========== Helpers ==========
  void _start() {
    isLoading.value = true;
    errorMessage.value = '';
  }

  void _end() {
    isLoading.value = false;
  }

  void _handle(Map<String, dynamic> res) {
    if (res['ok'] == true) {
      final data = res['data']?['data'] ?? res['data'];
      stats.value = (data is Map<String, dynamic>) ? data : {'raw': data};
    } else {
      errorMessage.value = res['data']?['message']?.toString() ?? 'تعذر جلب البيانات';
    }
  }
}
