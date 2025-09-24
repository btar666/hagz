import 'package:get/get.dart';

class PastAppointmentsController extends GetxController {
  // Each item: { 'doctor': String, 'order': int, 'date': DateTime, 'status': 'completed'|'pending'|'cancelled' }
  final appointments = <Map<String, dynamic>>[].obs;
  final query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Seed sample
    final today = DateTime(2025, 6, 2);
    appointments.addAll([
      {'doctor': 'اسم الطبيب', 'order': 22, 'date': today, 'status': 'completed'},
      {'doctor': 'اسم الطبيب', 'order': 10, 'date': today, 'status': 'cancelled'},
      {'doctor': 'اسم الطبيب', 'order': 26, 'date': today, 'status': 'pending'},
      {'doctor': 'اسم الطبيب', 'order': 8, 'date': today, 'status': 'pending'},
      {'doctor': 'اسم الطبيب', 'order': 5, 'date': today, 'status': 'completed'},
      {'doctor': 'اسم الطبيب', 'order': 5, 'date': today, 'status': 'completed'},
    ]);
  }

  List<Map<String, dynamic>> get filtered {
    final q = query.value.trim();
    if (q.isEmpty) return appointments;
    return appointments
        .where((e) => (e['doctor'] as String).contains(q))
        .toList(growable: false);
  }

  void updateQuery(String v) => query.value = v;
}

