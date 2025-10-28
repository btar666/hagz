import 'package:get/get.dart';
import '../service_layer/services/ratings_service.dart';
import '../service_layer/services/appointments_service.dart';

class AppointmentDetailsController extends GetxController {
  // Ratings state
  var isLoadingRating = false.obs;
  var triedLoadRating = false.obs;
  var ratingId = RxnString();
  var ratingValue = RxnInt(); // 1..5
  var ratingComment = RxnString();

  // Current appointment state
  var isLoadingCurrentAppointment = false.obs;
  var currentAppointmentNumber = RxnInt();

  final RatingsService _ratingsService = RatingsService();
  final AppointmentsService _appointmentsService = AppointmentsService();

  Future<void> loadAppointmentRating(String appointmentId) async {
    if (appointmentId.isEmpty || triedLoadRating.value) return;
    triedLoadRating.value = true;
    isLoadingRating.value = true;
    try {
      final res = await _ratingsService.getByAppointment(appointmentId);
      if (res['ok'] == true) {
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          final obj = data['data'] is Map<String, dynamic>
              ? data['data']
              : data;
          ratingId.value = obj['_id']?.toString();
          final num? r = obj['rating'] as num?;
          ratingValue.value = r?.toInt();
          ratingComment.value = obj['comment']?.toString();
        }
      }
    } catch (_) {
    } finally {
      isLoadingRating.value = false;
    }
  }

  Future<void> loadCurrentAppointmentNumber(String doctorId) async {
    if (doctorId.isEmpty) return;
    isLoadingCurrentAppointment.value = true;
    try {
      final res = await _appointmentsService.getCurrentAppointmentNumber(
        doctorId: doctorId,
      );

      print('[CURRENT APPOINTMENT] Full response: $res');

      if (res['ok'] == true) {
        // البيانات تأتي في res['data']['data']
        final dynamic responseData = res['data'];
        if (responseData is Map<String, dynamic>) {
          final dynamic innerData = responseData['data'];

          print('[CURRENT APPOINTMENT] Inner data: $innerData');

          if (innerData is Map<String, dynamic>) {
            final num? currentNum =
                innerData['currentAppointmentNumber'] as num?;

            print('[CURRENT APPOINTMENT] Current number: $currentNum');

            // إضافة 1 للرقم الحالي
            currentAppointmentNumber.value = (currentNum?.toInt() ?? 0) + 1;

            print(
              '[CURRENT APPOINTMENT] Updated value (current + 1): ${currentAppointmentNumber.value}',
            );
          }
        }
      }
    } catch (e) {
      print('[CURRENT APPOINTMENT] Failed to load: $e');
    } finally {
      isLoadingCurrentAppointment.value = false;
    }
  }

  Future<bool> saveRating({
    required String appointmentId,
    required int rating,
    String? comment,
  }) async {
    try {
      Map<String, dynamic> res;
      if (ratingId.value == null) {
        res = await _ratingsService.createRating(
          appointmentId: appointmentId,
          rating: rating,
          comment: comment,
        );
      } else {
        res = await _ratingsService.updateRating(
          id: ratingId.value!,
          rating: rating,
          comment: comment,
        );
      }
      if (res['ok'] == true) {
        // تحديث القيم المحلية
        ratingId.value =
            res['data']?['data']?['_id']?.toString() ?? ratingId.value;
        ratingValue.value = rating;
        ratingComment.value = comment;
        Get.snackbar('تم', 'تم حفظ التقييم');
        return true;
      } else {
        Get.snackbar(
          'خطأ',
          res['data']?['message']?.toString() ?? 'تعذر حفظ التقييم',
        );
        return false;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'تعذر حفظ التقييم');
      return false;
    }
  }

  Future<bool> deleteRating() async {
    if (ratingId.value == null) return true;
    try {
      final res = await _ratingsService.deleteRating(ratingId.value!);
      if (res['ok'] == true) {
        Get.snackbar('تم', 'تم حذف التقييم');
        ratingId.value = null;
        ratingValue.value = null;
        ratingComment.value = null;
        return true;
      }
      Get.snackbar(
        'خطأ',
        res['data']?['message']?.toString() ?? 'تعذر حذف التقييم',
      );
      return false;
    } catch (e) {
      Get.snackbar('خطأ', 'تعذر حذف التقييم');
      return false;
    }
  }
}
