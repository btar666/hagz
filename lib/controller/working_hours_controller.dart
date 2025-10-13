import 'package:get/get.dart';
import '../service_layer/services/working_hours_service.dart';
import 'session_controller.dart';

class WorkingHoursController extends GetxController {
  final WorkingHoursService _service = WorkingHoursService();
  final SessionController _session = Get.find<SessionController>();

  // حالة التحميل
  RxBool isLoading = false.obs;

  // قائمة أوقات العمل (7 أيام)
  RxList<Map<String, dynamic>> workingHours = <Map<String, dynamic>>[].obs;

  // أسماء الأيام
  final List<String> dayNames = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  @override
  void onInit() {
    super.onInit();
    // تهيئة أوقات العمل الافتراضية
    _initializeDefaultWorkingHours();
    // جلب أوقات العمل من الـ API
    loadWorkingHours();
  }

  /// تهيئة أوقات العمل الافتراضية
  void _initializeDefaultWorkingHours() {
    workingHours.value = List.generate(7, (index) {
      return {
        'dayOfWeek': index,
        'dayName': dayNames[index],
        'startTime': '09:00',
        'endTime': '17:00',
        'isWorking': index != 5, // الجمعة عطلة افتراضياً
        'slotDuration': 30,
        '_id': null, // سيتم تعيينه من الـ API
      };
    });
  }

  /// جلب أوقات العمل من الـ API
  Future<void> loadWorkingHours() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      final res = await _service.getDoctorWorkingHours(userId);
      if (res['ok'] == true) {
        final data = res['data']?['data'];
        if (data != null && data is List) {
          // البيانات تأتي كـ List مباشرة
          final List<dynamic> hours = data;

          // تحديث أوقات العمل من البيانات المسترجعة
          for (var hour in hours) {
            final dayOfWeek = hour['dayOfWeek'];
            // التأكد من أن dayOfWeek رقم
            final dayIndex = dayOfWeek is int
                ? dayOfWeek
                : int.tryParse(dayOfWeek.toString());

            if (dayIndex != null && dayIndex >= 0 && dayIndex < 7) {
              workingHours[dayIndex] = {
                'dayOfWeek': dayIndex,
                'dayName': dayNames[dayIndex],
                'startTime': hour['startTime']?.toString() ?? '09:00',
                'endTime': hour['endTime']?.toString() ?? '17:00',
                'isWorking': hour['isWorking'] ?? false,
                'slotDuration': hour['slotDuration'] ?? 30,
                '_id': hour['_id']?.toString(),
              };
            }
          }
          workingHours.refresh();
        }
      }
    } catch (e) {
      print('Error loading working hours: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// حفظ أوقات العمل
  Future<Map<String, dynamic>> saveWorkingHours() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) {
      return {'ok': false, 'message': 'معرف المستخدم غير موجود'};
    }

    // تحويل البيانات للصيغة المطلوبة
    final List<Map<String, dynamic>> hoursToSend = workingHours.map((hour) {
      return {
        'dayOfWeek': hour['dayOfWeek'],
        'startTime': hour['startTime'],
        'endTime': hour['endTime'],
        'isWorking': hour['isWorking'],
        'slotDuration': hour['slotDuration'],
      };
    }).toList();

    final res = await _service.createWorkingHours(
      doctorId: userId,
      workingHours: hoursToSend,
    );

    if (res['ok'] == true) {
      // إعادة تحميل البيانات
      await loadWorkingHours();
    }

    return res;
  }

  /// تحديث يوم محدد
  Future<Map<String, dynamic>> updateDay(int dayIndex) async {
    if (dayIndex < 0 || dayIndex >= workingHours.length) {
      return {'ok': false, 'message': 'يوم غير صحيح'};
    }

    final day = workingHours[dayIndex];
    final workingHoursId = day['_id'];

    if (workingHoursId == null || workingHoursId.isEmpty) {
      return {'ok': false, 'message': 'يجب حفظ أوقات العمل أولاً'};
    }

    final res = await _service.updateWorkingHour(
      workingHoursId: workingHoursId,
      startTime: day['startTime'],
      endTime: day['endTime'],
      isWorking: day['isWorking'],
      slotDuration: day['slotDuration'],
    );

    if (res['ok'] == true) {
      await loadWorkingHours();
    }

    return res;
  }

  /// حذف جميع أوقات العمل
  Future<Map<String, dynamic>> deleteAllWorkingHours() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) {
      return {'ok': false, 'message': 'معرف المستخدم غير موجود'};
    }

    final res = await _service.deleteAllWorkingHours(userId);

    if (res['ok'] == true) {
      _initializeDefaultWorkingHours();
    }

    return res;
  }

  /// تحديث حالة العمل ليوم معين
  void toggleDayWorking(int dayIndex) {
    if (dayIndex >= 0 && dayIndex < workingHours.length) {
      workingHours[dayIndex]['isWorking'] =
          !workingHours[dayIndex]['isWorking'];
      workingHours.refresh();
    }
  }

  /// تحديث وقت البداية ليوم معين
  void updateStartTime(int dayIndex, String time) {
    if (dayIndex >= 0 && dayIndex < workingHours.length) {
      workingHours[dayIndex]['startTime'] = time;
      workingHours.refresh();
    }
  }

  /// تحديث وقت النهاية ليوم معين
  void updateEndTime(int dayIndex, String time) {
    if (dayIndex >= 0 && dayIndex < workingHours.length) {
      workingHours[dayIndex]['endTime'] = time;
      workingHours.refresh();
    }
  }

  /// تحديث مدة الفترة الزمنية ليوم معين
  void updateSlotDuration(int dayIndex, int duration) {
    if (dayIndex >= 0 && dayIndex < workingHours.length) {
      workingHours[dayIndex]['slotDuration'] = duration;
      workingHours.refresh();
    }
  }
}
