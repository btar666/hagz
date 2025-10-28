import 'api_request.dart';
import '../../utils/constants.dart';

class AppointmentsService {
  final ApiRequest _api = ApiRequest();

  /// جلب الفترات المتاحة لطبيب في تاريخ معين
  Future<Map<String, dynamic>> getAvailableSlots({
    required String doctorId,
    required String date,
  }) async {
    final url =
        '${ApiConstants.doctorsWorkingHours}/$doctorId/available-slots/$date';
    print('📅 GET AVAILABLE SLOTS URL: $url');
    final result = await _api.get(url);
    print('📅 GET AVAILABLE SLOTS RESPONSE: $result');
    return result;
  }

  /// حجز موعد جديد - مع المعلومات الإضافية المطلوبة
  Future<Map<String, dynamic>> createAppointment({
    required String doctorId,
    required String patientId,
    required String patientName,
    required int patientAge,
    required String patientPhone,
    required String appointmentDate,
    required String appointmentTime,
    String? patientNotes,
    required double amount,
  }) async {
    final body = {
      'doctor': doctorId,
      'patient': patientId,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientPhone': patientPhone,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      if (patientNotes != null && patientNotes.isNotEmpty)
        'patientNotes': patientNotes,
      'amount': amount,
    };
    print('➕ CREATE APPOINTMENT URL: ${ApiConstants.appointments}');
    print('➕ CREATE APPOINTMENT BODY: $body');
    final result = await _api.post(ApiConstants.appointments, body);
    print('➕ CREATE APPOINTMENT RESPONSE: $result');
    return result;
  }

  /// جلب مواعيد طبيب في تاريخ معين
  Future<Map<String, dynamic>> getDoctorAppointmentsByDate({
    required String doctorId,
    required String date,
  }) async {
    final url =
        '${ApiConstants.doctorsWorkingHours}/$doctorId/appointments/date/$date';
    print('📋 GET DOCTOR APPOINTMENTS BY DATE URL: $url');
    final result = await _api.get(url);
    print('📋 GET DOCTOR APPOINTMENTS BY DATE RESPONSE: $result');
    return result;
  }

  /// جلب مواعيد المريض
  Future<Map<String, dynamic>> getPatientAppointments({
    required String patientId,
    int? page,
    int? limit,
    String? status,
  }) async {
    var url = '${ApiConstants.patients}/$patientId/appointments';

    final queryParams = <String>[];
    if (page != null) queryParams.add('page=$page');
    if (limit != null) queryParams.add('limit=$limit');
    if (status != null && status.isNotEmpty) queryParams.add('status=$status');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    print('📋 GET PATIENT APPOINTMENTS URL: $url');
    final result = await _api.get(url);
    print('📋 GET PATIENT APPOINTMENTS RESPONSE: $result');
    return result;
  }

  /// جلب مواعيد الطبيب
  Future<Map<String, dynamic>> getDoctorAppointments({
    required String doctorId,
    int? page,
    int? limit,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    var url = '${ApiConstants.doctorsWorkingHours}/$doctorId/appointments';

    final queryParams = <String>[];
    if (page != null) queryParams.add('page=$page');
    if (limit != null) queryParams.add('limit=$limit');
    if (status != null && status.isNotEmpty) queryParams.add('status=$status');
    if (startDate != null && startDate.isNotEmpty) {
      queryParams.add('startDate=$startDate');
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams.add('endDate=$endDate');
    }

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    print('📋 GET DOCTOR APPOINTMENTS URL: $url');
    final result = await _api.get(url);
    print('📋 GET DOCTOR APPOINTMENTS RESPONSE: $result');
    return result;
  }

  /// تحديث حالة الموعد
  Future<Map<String, dynamic>> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    String? notes,
    String? cancelledBy,
    String? cancellationReason,
  }) async {
    final url = '${ApiConstants.appointments}/$appointmentId/status';
    final body = {
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (cancelledBy != null && cancelledBy.isNotEmpty)
        'cancelledBy': cancelledBy,
      if (cancellationReason != null && cancellationReason.isNotEmpty)
        'cancellationReason': cancellationReason,
    };
    print('✏️ UPDATE APPOINTMENT STATUS URL: $url');
    print('✏️ UPDATE APPOINTMENT STATUS BODY: $body');
    final result = await _api.put(url, body);
    print('✏️ UPDATE APPOINTMENT STATUS RESPONSE: $result');
    return result;
  }

  /// إلغاء موعد
  Future<Map<String, dynamic>> cancelAppointment({
    required String appointmentId,
    required String cancelledBy,
    String? cancellationReason,
  }) async {
    final url = '${ApiConstants.appointments}/$appointmentId/cancel';
    final body = {
      'cancelledBy': cancelledBy,
      if (cancellationReason != null && cancellationReason.isNotEmpty)
        'cancellationReason': cancellationReason,
    };
    print('❌ CANCEL APPOINTMENT URL: $url');
    print('❌ CANCEL APPOINTMENT BODY: $body');
    final result = await _api.put(url, body);
    print('❌ CANCEL APPOINTMENT RESPONSE: $result');
    return result;
  }

  /// تأكيد موعد
  Future<Map<String, dynamic>> confirmAppointment({
    required String appointmentId,
    String? notes,
  }) async {
    final url = '${ApiConstants.appointments}/$appointmentId/confirm';
    final body = {if (notes != null && notes.isNotEmpty) 'notes': notes};
    print('✅ CONFIRM APPOINTMENT URL: $url');
    print('✅ CONFIRM APPOINTMENT BODY: $body');
    final result = await _api.put(url, body);
    print('✅ CONFIRM APPOINTMENT RESPONSE: $result');
    return result;
  }

  /// إكمال موعد
  Future<Map<String, dynamic>> completeAppointment({
    required String appointmentId,
    String? notes,
  }) async {
    final url = '${ApiConstants.appointments}/$appointmentId/complete';
    final body = {if (notes != null && notes.isNotEmpty) 'notes': notes};
    print('✔️ COMPLETE APPOINTMENT URL: $url');
    print('✔️ COMPLETE APPOINTMENT BODY: $body');
    final result = await _api.put(url, body);
    print('✔️ COMPLETE APPOINTMENT RESPONSE: $result');
    return result;
  }

  /// جلب إحصائيات المواعيد للطبيب
  Future<Map<String, dynamic>> getDoctorAppointmentStats({
    required String doctorId,
    String? startDate,
    String? endDate,
  }) async {
    var url = '${ApiConstants.doctorsWorkingHours}/$doctorId/appointment-stats';

    final queryParams = <String>[];
    if (startDate != null && startDate.isNotEmpty) {
      queryParams.add('startDate=$startDate');
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams.add('endDate=$endDate');
    }

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    print('📊 GET APPOINTMENT STATS URL: $url');
    final result = await _api.get(url);
    print('📊 GET APPOINTMENT STATS RESPONSE: $result');
    return result;
  }

  /// جلب المواعيد القادمة للطبيب
  Future<Map<String, dynamic>> getDoctorUpcomingAppointments({
    required String doctorId,
    int? limit,
  }) async {
    var url =
        '${ApiConstants.doctorsWorkingHours}/$doctorId/upcoming-appointments';
    if (limit != null) {
      url += '?limit=$limit';
    }
    print('🔜 GET UPCOMING APPOINTMENTS URL: $url');
    final result = await _api.get(url);
    print('🔜 GET UPCOMING APPOINTMENTS RESPONSE: $result');
    return result;
  }

  /// جلب المواعيد الفائتة للطبيب
  Future<Map<String, dynamic>> getDoctorMissedAppointments({
    required String doctorId,
    required String startDate,
    required String endDate,
  }) async {
    final url =
        '${ApiConstants.doctorsWorkingHours}/$doctorId/missed-appointments'
        '?startDate=$startDate&endDate=$endDate';
    print('⏭️ GET MISSED APPOINTMENTS URL: $url');
    final result = await _api.get(url);
    print('⏭️ GET MISSED APPOINTMENTS RESPONSE: $result');
    return result;
  }

  /// حذف موعد
  Future<Map<String, dynamic>> deleteAppointment(String appointmentId) async {
    final url = '${ApiConstants.appointments}/$appointmentId';
    print('🗑️ DELETE APPOINTMENT URL: $url');
    final result = await _api.delete(url);
    print('🗑️ DELETE APPOINTMENT RESPONSE: $result');
    return result;
  }

  /// جلب رقم الموعد الحالي للطبيب
  Future<Map<String, dynamic>> getCurrentAppointmentNumber({
    required String doctorId,
  }) async {
    final url =
        '${ApiConstants.doctorsWorkingHours}/$doctorId/current-appointment-number';
    print('🔢 GET CURRENT APPOINTMENT NUMBER URL: $url');
    final result = await _api.get(url);
    print('🔢 GET CURRENT APPOINTMENT NUMBER RESPONSE: $result');
    return result;
  }
}
