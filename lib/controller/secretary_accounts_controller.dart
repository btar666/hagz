import 'package:get/get.dart';

class SecretaryAccountsController extends GetxController {
  // Each secretary: { 'name': String, 'phone': String }
  final secretaries = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Seed with sample data
    secretaries.addAll([
      {'name': 'اسم السكرتير', 'phone': '0770 000 0000'},
      {'name': 'اسم السكرتير', 'phone': '0770 000 0000'},
      {'name': 'اسم السكرتير', 'phone': '0770 000 0000'},
      {'name': 'اسم السكرتير', 'phone': '0770 000 0000'},
    ]);
  }

  void addSecretary({required String phone, String name = 'اسم السكرتير'}) {
    secretaries.add({'name': name, 'phone': phone});
  }

  void removeSecretaryAt(int index) {
    if (index >= 0 && index < secretaries.length) {
      secretaries.removeAt(index);
    }
  }
}

