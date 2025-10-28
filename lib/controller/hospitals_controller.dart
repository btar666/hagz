import 'package:get/get.dart';

import '../model/hospital_model.dart';
import '../service_layer/services/hospital_service.dart';

class HospitalsController extends GetxController {
  final HospitalService _service = HospitalService();
  var isLoading = false.obs;
  var hospitals = <HospitalModel>[].obs;

  // Filter variables
  var selectedCity = ''.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHospitals();
  }

  Future<void> fetchHospitals({bool reset = false}) async {
    if (reset) {
      hospitals.clear();
    }
    isLoading.value = true;

    Map<String, dynamic> res;

    // إذا كان هناك فلتر أو بحث، استخدم API البحث
    if (selectedCity.value.isNotEmpty || searchQuery.value.isNotEmpty) {
      res = await _service.searchHospitalsAndDoctors(
        searchQuery: searchQuery.value,
        city: selectedCity.value.isNotEmpty ? selectedCity.value : null,
      );

      // استخراج المستشفيات والمجمعات فقط من نتائج البحث
      if (res['ok'] == true) {
        final responseData = res['data'] as Map<String, dynamic>;
        final innerData = responseData['data'] as Map<String, dynamic>?;

        if (innerData != null) {
          final hospitalsData = innerData['hospitals'] as Map<String, dynamic>?;

          if (hospitalsData != null && hospitalsData['data'] != null) {
            final hospitalsList = hospitalsData['data'] as List;
            hospitals.value = hospitalsList
                .map((e) => HospitalModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
      }
    } else {
      // جلب كل المستشفيات والمجمعات
      res = await _service.getHospitals();
      if (res['ok'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final List list = (data['data'] as List? ?? []);
        hospitals.value = list
            .map((e) => HospitalModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    isLoading.value = false;
  }

  void applyFilters(String city, String query) {
    selectedCity.value = city;
    searchQuery.value = query;
    fetchHospitals(reset: true);
  }

  void clearFilters() {
    selectedCity.value = '';
    searchQuery.value = '';
    fetchHospitals(reset: true);
  }
}
