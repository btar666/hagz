import 'package:get/get.dart';
import '../service_layer/services/opinion_service.dart';

class DoctorProfileController extends GetxController {
  // Observable variables for each section's expansion state
  var isBioExpanded = false.obs;
  var isAddressExpanded = false.obs;
  var isOpinionsExpanded = false.obs;
  var isCasesExpanded = false.obs;
  var isInsuranceExpanded = false.obs;
  var isAvailabilityExpanded = false.obs; // المواعيد المتاحة
  var isSequenceExpanded = false.obs; // تسلسل المواعيد
  // Manage page UI states
  var isEditingSocial = false.obs;

  // Toggle methods for each section
  void toggleBioExpansion() {
    isBioExpanded.value = !isBioExpanded.value;
  }

  void toggleAddressExpansion() {
    isAddressExpanded.value = !isAddressExpanded.value;
  }

  void toggleOpinionsExpansion() {
    isOpinionsExpanded.value = !isOpinionsExpanded.value;
  }

  void toggleCasesExpansion() {
    isCasesExpanded.value = !isCasesExpanded.value;
  }

  void toggleInsuranceExpansion() {
    isInsuranceExpanded.value = !isInsuranceExpanded.value;
  }

  void toggleAvailabilityExpansion() {
    isAvailabilityExpanded.value = !isAvailabilityExpanded.value;
  }

  void toggleSequenceExpansion() {
    isSequenceExpanded.value = !isSequenceExpanded.value;
  }

  // Sample doctor data - you can replace this with API calls
  var doctorName = 'د. أحمد محمد'.obs;
  var doctorSpecialty = 'طبيب أطفال'.obs;
  var doctorRating = 4.8.obs;
  var doctorExperience = '15 سنة خبرة'.obs;
  var doctorBio =
      'طبيب أطفال متخصص مع خبرة واسعة في علاج الأطفال والرضع. حاصل على شهادات متقدمة في طب الأطفال من جامعات مرموقة.'
          .obs;
  var doctorAddress = 'شارع الملك فهد، الرياض، المملكة العربية السعودية'.obs;
  var doctorPhone = '+966501234567'.obs;
  // Certificates images (paths or URLs)
  var certificateImages = <String>[].obs;
  // Paths can be absolute files or asset paths
  // Addresses: each item has value and isLink (website)
  var addresses = <Map<String, dynamic>>[
    {'value': 'مركز العيون التخصصي , دهوك', 'isLink': false},
    {
      'value': '',
      'isLink': true, // رابط موقع
    },
  ].obs;

  // Opinions from API
  var opinions = <Map<String, dynamic>>[].obs;
  final OpinionService _opinionService = OpinionService();

  // Sample treated cases
  var treatedCases = <Map<String, String>>[
    {
      'title': 'علاج الربو عند الأطفال',
      'description': 'برنامج شامل لعلاج ومتابعة حالات الربو',
      'image': 'assets/images/asthma_treatment.jpg',
    },
    {
      'title': 'التطعيمات الأساسية',
      'description': 'جدول التطعيمات المعتمد من وزارة الصحة',
      'image': 'assets/images/vaccination.jpg',
    },
  ].obs;

  // Availability calendar state
  var selectedMonth = DateTime.now().obs; // always first day semantics in view
  // status per day: 'available' | 'full' | 'holiday' | 'closed'
  var dayStatuses = <int, String>{}.obs;

  // Treated cases (legacy single-case editors)
  var treatedCaseName = 'جفاف و حساسية'.obs;
  var treatedCaseImages = <String>[].obs;

  // New: Managed cases list (each with name + one image) + form state
  var managedCases =
      <Map<String, String>>[].obs; // { 'name': ..., 'image': path }
  var newCaseName = ''.obs;
  var newCaseImage = ''.obs;

  // Appointments sequence (order queue)
  var sequenceAppointments = <Map<String, dynamic>>[
    {
      'order': 1,
      'patient': 'اسم المريض',
      'time': '6:40 صباحاً',
      'status': 'completed',
    },
    {
      'order': 2,
      'patient': 'اسم المريض',
      'time': '6:40 صباحاً',
      'status': 'pending',
    },
    {
      'order': 4,
      'patient': 'اسم المريض',
      'time': '6:40 صباحاً',
      'status': 'cancelled',
    },
  ].obs;

  // Insurance companies
  var acceptedInsurance = <String>[
    'التأمين الطبي الشامل',
    'بوبا العربية',
    'الشركة السعودية للتأمين التعاوني',
    'شركة الراجحي للتأمين',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize any data loading here
    loadDoctorData();
    // opinions will be fetched by view when doctorId is known

    // Seed sample calendar statuses similar to design
    _seedCurrentMonthStatuses();
  }

  Future<void> loadOpinionsForTarget(String targetId) async {
    try {
      final res = await _opinionService.getOpinionsByTarget(targetId);
      if (res['ok'] == true) {
        final List<dynamic> data = (res['data']?['data'] as List? ?? []);
        opinions.value = data.map((item) {
          final Map<String, dynamic> m = item as Map<String, dynamic>;
          final user = (m['user'] as Map<String, dynamic>?);
          return {
            'patientName': user?['name']?.toString() ?? 'مستخدم',
            'rating': 5.0,
            'comment': m['comment']?.toString() ?? '',
            'date': m['createdAt']?.toString(),
            'avatar': 'assets/icons/home/doctor.png',
          };
        }).toList();
      }
    } catch (_) {
      // ignore network errors silently
    }
  }

  void loadDoctorData() {
    // Here you can load doctor data from API
    // For now using sample data
  }

  // Mutations used by manage page
  void toggleEditingSocial() {
    isEditingSocial.toggle();
  }

  void updateBio(String value) {
    doctorBio.value = value;
  }

  void addCertificate(String path) {
    certificateImages.add(path);
  }

  void removeCertificateAt(int index) {
    if (index >= 0 && index < certificateImages.length) {
      certificateImages.removeAt(index);
    }
  }

  // Address mutations
  void addAddress({required bool isLink, String value = ''}) {
    addresses.add({'value': value, 'isLink': isLink});
  }

  void removeAddressAt(int index) {
    if (index >= 0 && index < addresses.length) {
      addresses.removeAt(index);
    }
  }

  void updateAddressValue(int index, String value) {
    if (index >= 0 && index < addresses.length) {
      addresses[index] = {
        'value': value,
        'isLink': addresses[index]['isLink'] as bool,
      };
      addresses.refresh();
    }
  }

  void toggleAddressType(int index) {
    if (index >= 0 && index < addresses.length) {
      final current = addresses[index];
      addresses[index] = {
        'value': current['value'],
        'isLink': !(current['isLink'] as bool),
      };
      addresses.refresh();
    }
  }

  // Availability helpers
  void _seedCurrentMonthStatuses() {
    dayStatuses.clear();
    // Example: days 8, 16, 26, 30 => available (green tint in UI)
    for (final d in [8, 16, 26, 30]) {
      dayStatuses[d] = 'available';
    }
    // days 10, 17, 31 => holiday
    for (final d in [10, 17, 31]) {
      dayStatuses[d] = 'holiday';
    }
    // days 11, 18, 19 => closed
    for (final d in [11, 18, 19]) {
      dayStatuses[d] = 'closed';
    }
    // the rest default to 'open' (light grey)
  }

  void nextMonth() {
    final current = selectedMonth.value;
    final next = DateTime(current.year, current.month + 1, 1);
    selectedMonth.value = next;
    _seedCurrentMonthStatuses();
  }

  void prevMonth() {
    final current = selectedMonth.value;
    final prev = DateTime(current.year, current.month - 1, 1);
    selectedMonth.value = prev;
    _seedCurrentMonthStatuses();
  }

  // Treated case mutations
  void updateTreatedCaseName(String name) {
    treatedCaseName.value = name;
  }

  void addTreatedCaseImage(String path) {
    treatedCaseImages.add(path);
  }

  void removeTreatedCaseImageAt(int index) {
    if (index >= 0 && index < treatedCaseImages.length) {
      treatedCaseImages.removeAt(index);
    }
  }

  void clearTreatedCase() {
    treatedCaseImages.clear();
    treatedCaseName.value = '';
  }

  // Managed cases form actions
  void updateNewCaseName(String name) {
    newCaseName.value = name;
  }

  void updateNewCaseImage(String path) {
    newCaseImage.value = path;
  }

  bool get canAddCase =>
      newCaseName.value.trim().isNotEmpty &&
      newCaseImage.value.trim().isNotEmpty;

  void addManagedCase() {
    if (canAddCase) {
      managedCases.add({
        'name': newCaseName.value.trim(),
        'image': newCaseImage.value,
      });
      newCaseName.value = '';
      newCaseImage.value = '';
    }
  }

  void removeManagedCaseAt(int index) {
    if (index >= 0 && index < managedCases.length) managedCases.removeAt(index);
  }

  void updateManagedCaseNameAt(int index, String name) {
    if (index >= 0 && index < managedCases.length) {
      final current = managedCases[index];
      managedCases[index] = {...current, 'name': name.trim()};
      managedCases.refresh();
    }
  }

  void updateManagedCaseImageAt(int index, String path) {
    if (index >= 0 && index < managedCases.length) {
      final current = managedCases[index];
      managedCases[index] = {...current, 'image': path};
      managedCases.refresh();
    }
  }

  // Opinions mutations
  void toggleOpinionPublished(int index) {
    if (index >= 0 && index < opinions.length) {
      final current = opinions[index];
      opinions[index] = {
        ...current,
        'published': !(current['published'] as bool? ?? false),
      };
      opinions.refresh();
    }
  }

  void removeOpinionAt(int index) {
    if (index >= 0 && index < opinions.length) {
      opinions.removeAt(index);
    }
  }
}
