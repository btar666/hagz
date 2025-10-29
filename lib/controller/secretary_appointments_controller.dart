import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../service_layer/services/appointments_service.dart';
import 'session_controller.dart';

class SecretaryAppointmentsController extends GetxController {
  final AppointmentsService _service = AppointmentsService();
  final SessionController _session = Get.find<SessionController>();

  // البيانات من الـ API
  final appointments = <Map<String, dynamic>>[].obs;
  final query = ''.obs;
  final isLoading = false.obs;
  final currentAppointmentNumber = Rxn<int>();
  final isLoadingCurrentNumber = false.obs;

  // مرشح التاريخ للسكرتير
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
    loadCurrentAppointmentNumber();
  }

  /// جلب رقم الموعد الحالي من الـ API
  Future<void> loadCurrentAppointmentNumber() async {
    try {
      isLoadingCurrentNumber.value = true;

      final user = _session.currentUser.value;
      if (user?.associatedDoctor == null || user!.associatedDoctor.isEmpty) {
        print('⚠️ No associated doctor found for secretary');
        return;
      }

      print('🔵 Calling API for doctorId: ${user.associatedDoctor}');
      final res = await _service.getCurrentAppointmentNumber(
        doctorId: user.associatedDoctor,
      );

      print('🔵 API Response: $res');
      print('🔵 res[ok]: ${res['ok']}');
      print('🔵 res[data]: ${res['data']}');

      if (res['ok'] == true && res['data'] != null) {
        final outerData = res['data'];
        print('🔵 outerData structure: $outerData');

        // البيانات متداخلة - data داخل data
        final innerData = outerData['data'];
        print('🔵 innerData structure: $innerData');

        if (innerData != null) {
          var number = innerData['currentAppointmentNumber'];
          print(
            '🔵 currentAppointmentNumber from innerData: $number (type: ${number.runtimeType})',
          );

          // إذا كان الرقم string، حوله إلى int
          int? finalNumber;
          if (number is String) {
            finalNumber = int.tryParse(number);
          } else if (number is int) {
            finalNumber = number;
          } else if (number == 0) {
            finalNumber = 0;
          }

          // إضافة +1 للموعد الحالي ليصبح الموعد التالي
          if (finalNumber != null) {
            currentAppointmentNumber.value = finalNumber + 1;
          } else {
            currentAppointmentNumber.value = null;
          }

          print(
            '✅ Current appointment number loaded: ${currentAppointmentNumber.value}',
          );

          // طباعة معلومات إضافية
          if (innerData['nextPatient'] != null) {
            print('📋 Next patient: ${innerData['nextPatient']}');
          }
        } else {
          print('⚠️ innerData is null');
          currentAppointmentNumber.value = null;
        }
      } else {
        print('⚠️ No current appointment number available');
        print('⚠️ Response message: ${res['message']}');
        currentAppointmentNumber.value = null;
      }
    } catch (e) {
      print('❌ Error loading current appointment number: $e');
      currentAppointmentNumber.value = null;
    } finally {
      isLoadingCurrentNumber.value = false;
    }
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    loadAppointments();
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
    loadAppointmentsByDate(date);
  }

  /// جلب جميع مواعيد الطبيب المرتبط بالسكرتير
  Future<void> loadAppointments() async {
    final user = _session.currentUser.value;
    if (user?.associatedDoctor.isEmpty == true) {
      print('❌ Secretary has no associated doctor');
      return;
    }

    isLoading.value = true;
    try {
      final String? s = startDate.value != null
          ? DateFormat('yyyy-MM-dd').format(startDate.value!)
          : null;
      final String? e = endDate.value != null
          ? DateFormat('yyyy-MM-dd').format(endDate.value!)
          : null;

      final res = await _service.getDoctorAppointments(
        doctorId: user!.associatedDoctor,
        startDate: s,
        endDate: e,
      );

      if (res['ok'] == true) {
        final responseData = res['data'];
        if (responseData != null && responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            appointments.value = _processAppointments(data);
            print('✅ Loaded ${appointments.length} appointments for secretary');
            // تحديث رقم الموعد الحالي بعد تحميل المواعيد
            loadCurrentAppointmentNumber();
          }
        }
      } else {
        print('❌ Failed to load appointments: ${res['message']}');
        appointments.value = [];
      }
    } catch (e) {
      print('❌ Error loading appointments: $e');
      appointments.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب مواعيد الطبيب في تاريخ معين
  Future<void> loadAppointmentsByDate(DateTime date) async {
    final user = _session.currentUser.value;
    if (user?.associatedDoctor.isEmpty == true) {
      print('❌ Secretary has no associated doctor');
      return;
    }

    isLoading.value = true;
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final res = await _service.getDoctorAppointmentsByDate(
        doctorId: user!.associatedDoctor,
        date: dateStr,
      );

      if (res['ok'] == true) {
        final responseData = res['data'];
        if (responseData != null && responseData['data'] != null) {
          final data = responseData['data'];
          if (data is List) {
            appointments.value = _processAppointments(data);
            print(
              '✅ Loaded ${appointments.length} appointments for date: $dateStr',
            );
          }
        }
      } else {
        print('❌ Failed to load appointments by date: ${res['message']}');
        appointments.value = [];
      }
    } catch (e) {
      print('❌ Error loading appointments by date: $e');
      appointments.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// معالجة بيانات المواعيد
  List<Map<String, dynamic>> _processAppointments(List<dynamic> data) {
    return data.map((item) {
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
      String status = 'confirmed'; // القيمة الافتراضية مؤكد
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
        status = 'confirmed';
      } else if (apiStatus.contains('لم يحضر') ||
          apiStatus.toLowerCase() == 'no-show' ||
          apiStatus == 'لم يحضر') {
        status = 'no-show';
      }

      // معلومات المريض
      final patientName = item['patientName']?.toString() ?? 'مريض';
      final patientPhone = item['patientPhone']?.toString() ?? '';
      final patientAge = item['patientAge']?.toString() ?? '';
      final time = item['appointmentTime']?.toString() ?? '';
      final amount = item['amount']?.toString() ?? '0';
      // تسلسل الموعد (قد يأتي بأسماء مختلفة وبأنواع مختلفة)
      final dynamic seqRaw =
          item['appointmentSequence'] ??
          item['queueNumber'] ??
          item['sequenceNumber'] ??
          item['sequence'] ??
          item['order'] ??
          item['position'];
      int? appointmentSequence;
      if (seqRaw is int) {
        appointmentSequence = seqRaw;
      } else if (seqRaw is String) {
        appointmentSequence = int.tryParse(seqRaw);
      }

      return {
        'id': item['_id']?.toString() ?? '',
        'title': patientName,
        'date': appointmentDate,
        'status': status,
        'time': time,
        'amount': double.tryParse(amount) ?? 0.0,
        'patientName': patientName,
        'patientPhone': patientPhone,
        'patientAge': patientAge,
        'patientNotes': item['patientNotes']?.toString() ?? '',
        'appointmentId': item['_id']?.toString() ?? '',
        'appointmentSequence': appointmentSequence,
      };
    }).toList();
  }

  /// البحث في المواعيد
  List<Map<String, dynamic>> get filteredAppointments {
    if (query.value.isEmpty) return appointments;

    return appointments.where((appointment) {
      final title = appointment['title']?.toString().toLowerCase() ?? '';
      final phone = appointment['patientPhone']?.toString().toLowerCase() ?? '';
      final searchQuery = query.value.toLowerCase();

      return title.contains(searchQuery) || phone.contains(searchQuery);
    }).toList();
  }

  /// تحديث حالة الموعد
  Future<bool> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    String? notes,
  }) async {
    try {
      final res = await _service.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: status,
        notes: notes,
      );

      if (res['ok'] == true) {
        // تحديث القائمة المحلية
        final index = appointments.indexWhere(
          (apt) => apt['id'] == appointmentId,
        );
        if (index != -1) {
          appointments[index]['status'] = status;
          appointments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating appointment status: $e');
      return false;
    }
  }

  /// إلغاء موعد
  Future<bool> cancelAppointment({
    required String appointmentId,
    String? reason,
  }) async {
    try {
      final res = await _service.cancelAppointment(
        appointmentId: appointmentId,
        cancelledBy: 'secretary',
        cancellationReason: reason,
      );

      if (res['ok'] == true) {
        // تحديث القائمة المحلية
        final index = appointments.indexWhere(
          (apt) => apt['id'] == appointmentId,
        );
        if (index != -1) {
          appointments[index]['status'] = 'cancelled';
          appointments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error cancelling appointment: $e');
      return false;
    }
  }

  /// تأكيد موعد
  Future<bool> confirmAppointment({
    required String appointmentId,
    String? notes,
  }) async {
    try {
      final res = await _service.confirmAppointment(
        appointmentId: appointmentId,
        notes: notes,
      );

      if (res['ok'] == true) {
        // تحديث القائمة المحلية
        final index = appointments.indexWhere(
          (apt) => apt['id'] == appointmentId,
        );
        if (index != -1) {
          appointments[index]['status'] = 'pending';
          appointments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error confirming appointment: $e');
      return false;
    }
  }

  /// إكمال موعد
  Future<bool> completeAppointment({
    required String appointmentId,
    String? notes,
  }) async {
    try {
      final res = await _service.completeAppointment(
        appointmentId: appointmentId,
        notes: notes,
      );

      if (res['ok'] == true) {
        // تحديث القائمة المحلية
        final index = appointments.indexWhere(
          (apt) => apt['id'] == appointmentId,
        );
        if (index != -1) {
          appointments[index]['status'] = 'completed';
          appointments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error completing appointment: $e');
      return false;
    }
  }
}
