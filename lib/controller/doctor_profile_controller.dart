import 'package:get/get.dart';

class DoctorProfileController extends GetxController {
  // Observable variables for each section's expansion state
  var isBioExpanded = false.obs;
  var isAddressExpanded = false.obs;
  var isOpinionsExpanded = false.obs;
  var isCasesExpanded = false.obs;
  var isInsuranceExpanded = false.obs;
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

  // Sample opinions data
  var opinions = <Map<String, dynamic>>[
    {
      'patientName': 'أم سارة',
      'rating': 5.0,
      'comment': 'طبيب ممتاز ومتفهم، يتعامل مع الأطفال بلطف',
      'date': '2024-01-15',
    },
    {
      'patientName': 'أبو أحمد',
      'rating': 4.5,
      'comment': 'خبرة واضحة وتشخيص دقيق',
      'date': '2024-01-10',
    },
  ].obs;

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
}
