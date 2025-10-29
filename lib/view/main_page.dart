import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/main_controller.dart';
import '../controller/session_controller.dart';
import '../widget/bottom_navigation.dart';
import 'home/home_page.dart';
import 'specialties/specialties_page.dart';
import 'statistics/statistics_page.dart';
import 'settings/settings_page.dart';
import 'chat/chats_page.dart';
import 'secretary/secretary_home_page.dart';
import 'secretary/secretary_all_appointments_page.dart';
import 'delegate/delegate_home_page.dart';
import 'delegate/delegate_all_visits_page.dart';
import 'delegate/delegate_statistics_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();
    final SessionController session = Get.find<SessionController>();

    return Obx(() {
      final String role = session.role.value;
      late final List<Widget> pages;
      if (role == 'doctor') {
        pages = const [
          HomePage(),
          SpecialtiesPage(),
          StatisticsPage(),
          SettingsPage(),
        ];
      } else if (role == 'secretary') {
        pages = const [
          SecretaryHomePage(),
          SecretaryAllAppointmentsPage(),
          ChatsPage(),
          SettingsPage(),
        ];
      } else if (role == 'delegate') {
        pages = const [
          DelegateHomePage(),
          DelegateAllVisitsPage(),
          DelegateStatisticsPage(),
          SettingsPage(),
        ];
      } else {
        pages = const [HomePage(), SpecialtiesPage(), SettingsPage()];
      }
      int index = controller.currentIndex.value;
      if (index > pages.length - 1) {
        index = pages.length - 1;
      }
      return Scaffold(
        body: Obx(
          () => Skeletonizer(
            enabled: controller.isNavLoading.value,
            child: IndexedStack(index: index, children: pages),
          ),
        ),
        bottomNavigationBar: const BottomNavigationWidget(),
      );
    });
  }
}
