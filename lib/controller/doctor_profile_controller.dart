import 'package:get/get.dart';
import '../service_layer/services/opinion_service.dart';
import '../service_layer/services/cv_service.dart';
import '../service_layer/services/case_service.dart';
import 'session_controller.dart';

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
  final CvService _cvService = CvService();
  final CaseService _caseService = CaseService();
  final SessionController _session = Get.find<SessionController>();

  // CV state
  var cvId = ''.obs;
  var cvDescription = ''.obs;
  var cvCertificates = <String>[].obs;
  var isLoadingCv = false.obs;

  // Cases state from API
  var apiCases = <Map<String, dynamic>>[].obs;
  var isLoadingCases = false.obs;

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

  Future<void> fetchMyCvIfAny() async {
    final String? uid = _session.currentUser.value?.id;
    if (uid == null || uid.isEmpty) return;
    isLoadingCv.value = true;
    try {
      final res = await _cvService.getUserCvByUserId(uid);
      if (res['ok'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final Map<String, dynamic>? cvData =
            data['data'] as Map<String, dynamic>?;
        if (cvData != null) {
          cvId.value = (cvData['_id']?.toString() ?? '');
          cvDescription.value = (cvData['description']?.toString() ?? '');
          final certs =
              (cvData['certificates'] as List?)?.cast<dynamic>() ?? [];
          cvCertificates.value = certs.map((e) => e.toString()).toList();
          // reflect into existing UI state
          doctorBio.value = cvDescription.value.isNotEmpty
              ? cvDescription.value
              : doctorBio.value;
          certificateImages.value = List<String>.from(cvCertificates);
        }
      }
    } catch (_) {
    } finally {
      isLoadingCv.value = false;
    }
  }

  Future<void> loadCvForUserId(String userId) async {
    if (userId.isEmpty) return;
    isLoadingCv.value = true;
    try {
      final res = await _cvService.getUserCvByUserId(userId);
      if (res['ok'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final Map<String, dynamic>? cvData =
            data['data'] as Map<String, dynamic>?;
        if (cvData != null) {
          cvDescription.value = (cvData['description']?.toString() ?? '');
          final certs =
              (cvData['certificates'] as List?)?.cast<dynamic>() ?? [];
          cvCertificates.value = certs.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {
    } finally {
      isLoadingCv.value = false;
    }
  }

  Future<Map<String, dynamic>> saveMyCv({
    required String description,
    required List<String> certificates,
  }) async {
    final bool hasExisting = cvId.value.isNotEmpty;
    if (hasExisting) {
      final res = await _cvService.updateCv(
        cvId: cvId.value,
        description: description,
        certificates: certificates,
      );
      if (res['ok'] == true) {
        cvDescription.value = description;
        cvCertificates.value = certificates;
      }
      return res;
    } else {
      final res = await _cvService.createCv(
        description: description,
        certificates: certificates,
      );
      if (res['ok'] == true) {
        try {
          final created = (res['data']?['data']) as Map<String, dynamic>?;
          if (created != null) {
            cvId.value = created['_id']?.toString() ?? '';
          }
        } catch (_) {}
        cvDescription.value = description;
        cvCertificates.value = certificates;
      }
      return res;
    }
  }

  Future<Map<String, dynamic>> deleteMyCv() async {
    if (cvId.value.isEmpty)
      return {
        'ok': false,
        'data': {'message': 'لا توجد سيرة لحذفها'},
      };
    final res = await _cvService.deleteCv(cvId.value);
    if (res['ok'] == true) {
      cvId.value = '';
      cvDescription.value = '';
      cvCertificates.clear();
    }
    return res;
  }

  // Mutations used by manage page
  void toggleEditingSocial() {
    isEditingSocial.toggle();
  }

  void updateBio(String value) {
    doctorBio.value = value;
  }

  void addCertificate(String path) {
    // إضافة إلى القائمتين
    if (cvCertificates.isNotEmpty || cvId.value.isNotEmpty) {
      cvCertificates.add(path);
    } else {
      certificateImages.add(path);
    }
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

  // ==================== Cases Management ====================

  /// جلب حالات الطبيب من API
  Future<void> loadDoctorCases(String doctorId) async {
    if (isLoadingCases.value) return;
    isLoadingCases.value = true;
    try {
      final res = await _caseService.getDoctorCases(doctorId);
      if (res['ok'] == true) {
        final List<dynamic> data = (res['data']?['data'] as List? ?? []);
        apiCases.value = data.map((item) {
          final Map<String, dynamic> m = item as Map<String, dynamic>;
          return {
            '_id': m['_id']?.toString() ?? '',
            'title': m['title']?.toString() ?? '',
            'description': m['description']?.toString() ?? '',
            'visibility': m['visibility']?.toString() ?? 'public',
            'images': (m['images'] as List?)?.cast<String>() ?? <String>[],
            'createdAt': m['createdAt']?.toString() ?? '',
          };
        }).toList();
      }
    } catch (_) {
      // ignore network errors
    } finally {
      isLoadingCases.value = false;
    }
  }

  /// إنشاء حالة جديدة
  Future<Map<String, dynamic>> createNewCase({
    required String title,
    required String description,
    required String visibility,
    required List<String> images,
  }) async {
    final res = await _caseService.createCase(
      title: title,
      description: description,
      visibility: visibility,
      images: images,
    );
    if (res['ok'] == true) {
      // إعادة تحميل الحالات
      final String? userId = _session.currentUser.value?.id;
      if (userId != null && userId.isNotEmpty) {
        await loadDoctorCases(userId);
      }
    }
    return res;
  }

  /// حذف حالة
  Future<Map<String, dynamic>> deleteCase(String caseId) async {
    final res = await _caseService.deleteCase(caseId);
    if (res['ok'] == true) {
      // إزالة الحالة من القائمة المحلية
      apiCases.removeWhere((c) => c['_id'] == caseId);
    }
    return res;
  }
}
