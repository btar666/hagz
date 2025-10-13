import 'package:get/get.dart';
import '../service_layer/services/appointments_service.dart';
import 'session_controller.dart';

class PastAppointmentsController extends GetxController {
  final AppointmentsService _service = AppointmentsService();
  final SessionController _session = Get.find<SessionController>();

  // البيانات من الـ API
  final appointments = <Map<String, dynamic>>[].obs;
  final query = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  /// جلب المواعيد من الـ API
  Future<void> loadAppointments() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      final res = await _service.getPatientAppointments(patientId: userId);

      if (res['ok'] == true) {
        final responseData = res['data'];
        if (responseData != null && responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            appointments.value = data.map((item) {
              print('📋 Processing appointment item: $item');

              // استخراج معلومات الطبيب
              final doctor = item['doctor'];
              String doctorName = 'طبيب غير معروف';
              if (doctor is Map) {
                doctorName = doctor['name']?.toString() ?? 'طبيب غير معروف';
              } else if (doctor is String) {
                doctorName = doctor;
              }

              // تحويل التاريخ
              final dateStr = item['appointmentDate']?.toString() ?? '';
              DateTime appointmentDate = DateTime.now();
              try {
                if (dateStr.isNotEmpty) {
                  appointmentDate = DateTime.parse(dateStr);
                }
              } catch (e) {
                print('Error parsing date: $e');
              }

              // تحويل الحالة
              String status = 'pending';
              final apiStatus = item['status']?.toString() ?? '';
              print('📋 API Status: $apiStatus');

              if (apiStatus.contains('مكتمل') ||
                  apiStatus.toLowerCase() == 'completed') {
                status = 'completed';
              } else if (apiStatus.contains('ملغي') ||
                  apiStatus.toLowerCase() == 'cancelled') {
                status = 'cancelled';
              } else if (apiStatus.contains('مؤكد') ||
                  apiStatus.toLowerCase() == 'confirmed' ||
                  apiStatus == 'مؤكد') {
                status = 'pending';
              }

              final result = {
                'doctor': doctorName,
                'order': 0,
                'date': appointmentDate,
                'status': status,
                'time': item['appointmentTime']?.toString() ?? '',
                'amount': item['amount'] ?? 0,
                'notes': item['patientNotes']?.toString() ?? '',
                '_id': item['_id']?.toString() ?? '',
              };

              print('📋 Processed appointment: $result');
              return result;
            }).toList();

            print('📋 Total appointments loaded: ${appointments.length}');
          }
        }
      }
    } catch (e) {
      print('Error loading appointments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// البحث في المواعيد
  List<Map<String, dynamic>> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return appointments;
    return appointments
        .where((e) => (e['doctor'] as String).toLowerCase().contains(q))
        .toList(growable: false);
  }

  void updateQuery(String v) => query.value = v;
}
