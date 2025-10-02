import 'package:get/get.dart';

import '../model/hospital_model.dart';
import '../service_layer/services/hospital_service.dart';

class HospitalDetailsController extends GetxController {
  final HospitalService _service = HospitalService();

  var isRideExpanded = false.obs;
  var isLoading = false.obs;
  var hospital = Rxn<HospitalModel>();

  @override
  void onInit() {
    super.onInit();
    // توقع تمرير المعرف عبر Get.arguments['id']
    final args = Get.arguments;
    final String? id = (args is Map && args['id'] != null)
        ? args['id'].toString()
        : null;
    if (id != null && id.isNotEmpty) {
      fetchById(id);
    }
  }

  Future<void> fetchById(String id) async {
    isLoading.value = true;
    final res = await _service.getHospitalById(id);
    if (res['ok'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      final Map<String, dynamic> obj =
          (data['data'] as Map<String, dynamic>? ?? {});
      hospital.value = HospitalModel.fromJson(obj);
    }
    isLoading.value = false;
  }

  void toggleRideExpansion() {
    isRideExpanded.value = !isRideExpanded.value;
  }
}
