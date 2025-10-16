import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../service_layer/services/appointments_service.dart';
import 'session_controller.dart';

class PastAppointmentsController extends GetxController {
  final AppointmentsService _service = AppointmentsService();
  final SessionController _session = Get.find<SessionController>();

  // البيانات من الـ API
  final appointments = <Map<String, dynamic>>[].obs;
  final query = ''.obs;
  final isLoading = false.obs;

  // مرشح التاريخ للطبيب
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  bool get isDoctor => _session.role.value == 'doctor';

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    loadAppointments();
  }

  /// جلب المواعيد من الـ API (حسب الدور)
  Future<void> loadAppointments() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    final role = _session.role.value;
    isLoading.value = true;
    try {
      Map<String, dynamic> res;
      if (role == 'doctor') {
        // للطبيب: جلب مواعيد الطبيب (اختياري: حسب الفترة)
        final String? s = startDate.value != null
            ? DateFormat('yyyy-MM-dd').format(startDate.value!)
            : null;
        final String? e = endDate.value != null
            ? DateFormat('yyyy-MM-dd').format(endDate.value!)
            : null;
        res = await _service.getDoctorAppointments(
          doctorId: userId,
          startDate: s,
          endDate: e,
        );
      } else {
        // للمستخدم (المريض): جلب مواعيده
        res = await _service.getPatientAppointments(patientId: userId);
      }

      if (res['ok'] == true) {
        final responseData = res['data'];
        if (responseData != null && responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            appointments.value = data.map((item) {
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

              // تحويل الحالة إلى قيم داخلية موحدة
              String status = 'pending';
              final apiStatus = item['status']?.toString() ?? '';
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

              // عنوان السطر يعتمد على الدور
              String title = '';
              String? patientName;
              String? patientPhone;
              int? patientAge;

              if (role == 'doctor') {
                // الطبيب يرى اسم ورقم المريض مباشرة من الحقول الجديدة
                patientName = item['patientName']?.toString();
                patientPhone = item['patientPhone']?.toString();
                patientAge = item['patientAge'] as int?;
                title = patientName ?? 'مريض غير معروف';
              } else {
                // المستخدم/المريض يرى معلوماته الشخصية من الحقول الجديدة
                patientName = item['patientName']?.toString();
                patientPhone = item['patientPhone']?.toString();
                patientAge = item['patientAge'] as int?;
                title = patientName ?? 'مريض غير معروف';
              }

              // استخراج رقم تسلسل الموعد من الـ API
              int? appointmentSequence;
              final seq = item['appointmentSequence'];
              if (seq is int) {
                appointmentSequence = seq;
              } else if (seq is String) {
                final parsed = int.tryParse(seq);
                if (parsed != null) appointmentSequence = parsed;
              }

              final result = {
                'title': title,
                'date': appointmentDate,
                'time': item['appointmentTime']?.toString() ?? '',
                'status': status,
                'amount': item['amount'] ?? 0,
                'notes': item['patientNotes']?.toString() ?? '',
                '_id': item['_id']?.toString() ?? '',
                // معلومات للملاحظة/التفاصيل
                'patientName': patientName,
                'patientPhone': patientPhone,
                'patientAge': patientAge,
                'appointmentSequence': appointmentSequence,
              };

              return result;
            }).toList();

            // إبقاء الماضي فقط حينما يلزم (إن رغبت): يمكن لاحقاً فلترتها حسب التاريخ/الحالة
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
        .where((e) => (e['title'] as String).toLowerCase().contains(q))
        .toList(growable: false);
  }

  void updateQuery(String v) => query.value = v;

  /// تغيير حالة الموعد (للطبيب)
  Future<bool> changeStatus(
    String appointmentId,
    String newStatus, {
    String? notes,
    String? cancelledBy,
    String? cancellationReason,
  }) async {
    try {
      final res = await _service.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: newStatus,
        notes: notes,
        cancelledBy: cancelledBy,
        cancellationReason: cancellationReason,
      );
      if (res['ok'] == true) {
        final idx = appointments.indexWhere((a) => a['_id'] == appointmentId);
        if (idx != -1) {
          appointments[idx]['status'] = newStatus;
          appointments.refresh();
        }
        return true;
      }
    } catch (e) {
      print('Error changing status: $e');
    }
    return false;
  }
}
