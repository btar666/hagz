import 'package:get/get.dart';
import '../service_layer/services/appointments_service.dart';
import 'session_controller.dart';

class AppointmentsController extends GetxController {
  final AppointmentsService _service = AppointmentsService();
  final SessionController _session = Get.find<SessionController>();

  // حالة التحميل
  RxBool isLoading = false.obs;
  RxBool isLoadingSlots = false.obs;

  // الفترات المتاحة
  RxList<String> availableSlots = <String>[].obs;

  // قائمة المواعيد
  RxList<Map<String, dynamic>> appointments = <Map<String, dynamic>>[].obs;

  // قائمة المواعيد القادمة
  RxList<Map<String, dynamic>> upcomingAppointments =
      <Map<String, dynamic>>[].obs;

  // إحصائيات
  Rx<Map<String, dynamic>> stats = Rx<Map<String, dynamic>>({});

  /// جلب الفترات المتاحة لطبيب في تاريخ معين
  Future<List<String>> getAvailableSlots({
    required String doctorId,
    required String date,
  }) async {
    isLoadingSlots.value = true;
    try {
      final res = await _service.getAvailableSlots(
        doctorId: doctorId,
        date: date,
      );
      if (res['ok'] == true) {
        final data = res['data']?['data'];
        if (data != null && data is List) {
          // البيانات ترجع كـ list مباشرة من الـ API
          availableSlots.value = data.map((s) => s.toString()).toList();
          return availableSlots;
        }
      }
      return [];
    } catch (e) {
      print('Error getting available slots: $e');
      return [];
    } finally {
      isLoadingSlots.value = false;
    }
  }

  /// حجز موعد جديد
  Future<Map<String, dynamic>> bookAppointment({
    required String doctorId,
    required String appointmentDate,
    required String appointmentTime,
    String? patientNotes,
    required double amount,
  }) async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) {
      return {'ok': false, 'message': 'معرف المستخدم غير موجود'};
    }

    final res = await _service.createAppointment(
      doctorId: doctorId,
      patientId: userId,
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      patientNotes: patientNotes,
      amount: amount,
    );

    if (res['ok'] == true) {
      await loadMyAppointments();
    }

    return res;
  }

  /// جلب مواعيدي (كمريض)
  Future<void> loadMyAppointments({
    int? page,
    int? limit,
    String? status,
  }) async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      final res = await _service.getPatientAppointments(
        patientId: userId,
        page: page,
        limit: limit,
        status: status,
      );
      if (res['ok'] == true) {
        final data = res['data']?['data'];
        if (data != null && data is List) {
          appointments.value = data.map((item) {
            return {
              '_id': item['_id']?.toString() ?? '',
              'doctor': item['doctor'],
              'patient': item['patient'],
              'appointmentDate': item['appointmentDate']?.toString() ?? '',
              'appointmentTime': item['appointmentTime']?.toString() ?? '',
              'status': item['status']?.toString() ?? '',
              'patientNotes': item['patientNotes']?.toString(),
              'amount': item['amount'],
              'createdAt': item['createdAt']?.toString() ?? '',
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error loading my appointments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب مواعيد طبيب
  Future<void> loadDoctorAppointments({
    required String doctorId,
    int? page,
    int? limit,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    isLoading.value = true;
    try {
      final res = await _service.getDoctorAppointments(
        doctorId: doctorId,
        page: page,
        limit: limit,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      if (res['ok'] == true) {
        final data = res['data']?['data'];
        if (data != null && data is List) {
          appointments.value = data.map((item) {
            return {
              '_id': item['_id']?.toString() ?? '',
              'doctor': item['doctor'],
              'patient': item['patient'],
              'appointmentDate': item['appointmentDate']?.toString() ?? '',
              'appointmentTime': item['appointmentTime']?.toString() ?? '',
              'status': item['status']?.toString() ?? '',
              'patientNotes': item['patientNotes']?.toString(),
              'amount': item['amount'],
              'createdAt': item['createdAt']?.toString() ?? '',
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error loading doctor appointments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// إلغاء موعد
  Future<Map<String, dynamic>> cancelAppointment({
    required String appointmentId,
    String? reason,
  }) async {
    final userType = _session.currentUser.value?.userType ?? '';
    final cancelledBy = userType.toLowerCase() == 'doctor'
        ? 'doctor'
        : 'patient';

    final res = await _service.cancelAppointment(
      appointmentId: appointmentId,
      cancelledBy: cancelledBy,
      cancellationReason: reason,
    );

    if (res['ok'] == true) {
      appointments.removeWhere((a) => a['_id'] == appointmentId);
      upcomingAppointments.removeWhere((a) => a['_id'] == appointmentId);
    }

    return res;
  }

  /// تأكيد موعد (للطبيب)
  Future<Map<String, dynamic>> confirmAppointment({
    required String appointmentId,
    String? notes,
  }) async {
    final res = await _service.confirmAppointment(
      appointmentId: appointmentId,
      notes: notes,
    );

    if (res['ok'] == true) {
      await loadMyAppointments();
    }

    return res;
  }

  /// إكمال موعد (للطبيب)
  Future<Map<String, dynamic>> completeAppointment({
    required String appointmentId,
    String? notes,
  }) async {
    final res = await _service.completeAppointment(
      appointmentId: appointmentId,
      notes: notes,
    );

    if (res['ok'] == true) {
      await loadMyAppointments();
    }

    return res;
  }

  /// جلب المواعيد القادمة
  Future<void> loadUpcomingAppointments({
    required String doctorId,
    int limit = 10,
  }) async {
    try {
      final res = await _service.getDoctorUpcomingAppointments(
        doctorId: doctorId,
        limit: limit,
      );
      if (res['ok'] == true) {
        final data = res['data']?['data'];
        if (data != null && data is List) {
          upcomingAppointments.value = data.map((item) {
            return {
              '_id': item['_id']?.toString() ?? '',
              'doctor': item['doctor'],
              'patient': item['patient'],
              'appointmentDate': item['appointmentDate']?.toString() ?? '',
              'appointmentTime': item['appointmentTime']?.toString() ?? '',
              'status': item['status']?.toString() ?? '',
              'patientNotes': item['patientNotes']?.toString(),
              'amount': item['amount'],
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error loading upcoming appointments: $e');
    }
  }

  /// جلب إحصائيات المواعيد
  Future<void> loadAppointmentStats({
    required String doctorId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final res = await _service.getDoctorAppointmentStats(
        doctorId: doctorId,
        startDate: startDate,
        endDate: endDate,
      );
      if (res['ok'] == true) {
        final data = res['data']?['data'];
        if (data != null) {
          stats.value = Map<String, dynamic>.from(data);
        }
      }
    } catch (e) {
      print('Error loading appointment stats: $e');
    }
  }

  /// حذف موعد
  Future<Map<String, dynamic>> deleteAppointment(String appointmentId) async {
    final res = await _service.deleteAppointment(appointmentId);

    if (res['ok'] == true) {
      appointments.removeWhere((a) => a['_id'] == appointmentId);
      upcomingAppointments.removeWhere((a) => a['_id'] == appointmentId);
    }

    return res;
  }
}
