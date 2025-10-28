import 'package:get/get.dart';

import '../model/hospital_model.dart';
import '../service_layer/services/hospital_service.dart';

class HospitalDetailsController extends GetxController {
  final HospitalService _service = HospitalService();

  var isRideExpanded = false.obs;
  var isLoading = false.obs;
  var hospital = Rxn<HospitalModel>();
  var doctors = <Map<String, dynamic>>[].obs;
  var isLoadingDoctors = false.obs;

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

  Future<void> loadDoctors(String hospitalId) async {
    isLoadingDoctors.value = true;
    try {
      final res = await _service.getHospitalDoctors(hospitalId: hospitalId);
      if (res['ok'] == true) {
        final data = res['data'] as Map<String, dynamic>;

        // Handle nested response structure
        if (data.containsKey('data') && data['data'] is Map) {
          // New structure: {data: {hospital: {...}, doctors: [...]}}
          final innerData = data['data'] as Map<String, dynamic>;
          final List list = (innerData['doctors'] as List? ?? []);
          doctors.value = list.map((e) => e as Map<String, dynamic>).toList();
        } else if (data.containsKey('data') && data['data'] is List) {
          // Old structure: {data: [...]}
          final List list = (data['data'] as List? ?? []);
          doctors.value = list.map((e) => e as Map<String, dynamic>).toList();
        }
      }
    } catch (e) {
      print('Error loading doctors: $e');
    } finally {
      isLoadingDoctors.value = false;
    }
  }
}
