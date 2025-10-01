import 'package:get/get.dart';

import '../model/hospital_model.dart';
import '../service_layer/services/hospital_service.dart';

class HospitalsController extends GetxController {
  final HospitalService _service = HospitalService();
  var isLoading = false.obs;
  var hospitals = <HospitalModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHospitals();
  }

  Future<void> fetchHospitals() async {
    isLoading.value = true;
    final res = await _service.getHospitals();
    if (res['ok'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      final List list = (data['data'] as List? ?? []);
      hospitals.value = list
          .map((e) => HospitalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    isLoading.value = false;
  }
}
