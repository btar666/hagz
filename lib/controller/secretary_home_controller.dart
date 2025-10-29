import 'package:get/get.dart';

class SecretaryHomeController extends GetxController {
  // Observable variables
  final openNotifications = false.obs;
  final activeStatuses = <String>[].obs;

  // Toggle notifications
  void toggleNotifications() {
    openNotifications.value = !openNotifications.value;
  }

  // Set active statuses (for filtering)
  void setActiveStatuses(List<String> statuses) {
    activeStatuses.value = statuses;
  }

  // Clear active statuses
  void clearActiveStatuses() {
    activeStatuses.clear();
  }
}
