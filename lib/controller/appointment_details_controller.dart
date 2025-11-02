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
      print('📊 Loading rating for appointment: $appointmentId');
      final res = await _ratingsService.getByAppointment(appointmentId);
      print('📊 Rating response: $res');
      if (res['ok'] == true) {
        final data = res['data'];
        print('📊 Rating data: $data');
        if (data is Map<String, dynamic>) {
          final obj = data['data'] is Map<String, dynamic>
              ? data['data']
              : data;
          print('📊 Rating object: $obj');
          ratingId.value = obj['_id']?.toString() ?? obj['id']?.toString();
          final num? r = obj['rating'] as num?;
          ratingValue.value = r?.toInt();
          ratingComment.value = obj['comment']?.toString();
          print(
            '📊 Loaded rating - ID: ${ratingId.value}, Value: ${ratingValue.value}, Comment: ${ratingComment.value}',
          );
        } else if (data is List && data.isNotEmpty) {
          // Handle case where API returns list
          final obj = data[0] as Map<String, dynamic>;
          ratingId.value = obj['_id']?.toString() ?? obj['id']?.toString();
          final num? r = obj['rating'] as num?;
          ratingValue.value = r?.toInt();
          ratingComment.value = obj['comment']?.toString();
          print(
            '📊 Loaded rating from list - ID: ${ratingId.value}, Value: ${ratingValue.value}',
          );
        }
      } else {
        print('📊 No rating found or error: ${res['message']}');
      }
    } catch (e) {
      print('📊 Error loading rating: $e');
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
        final responseData = res['data'];
        if (responseData is Map<String, dynamic>) {
          final obj = responseData['data'] is Map<String, dynamic>
              ? responseData['data']
              : responseData;
          ratingId.value =
              obj['_id']?.toString() ?? obj['id']?.toString() ?? ratingId.value;
        } else {
          ratingId.value =
              responseData?['_id']?.toString() ??
              responseData?['id']?.toString() ??
              ratingId.value;
        }
        ratingValue.value = rating;
        ratingComment.value = comment;
        print('✅ Rating saved - ID: ${ratingId.value}, Value: $rating');
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
