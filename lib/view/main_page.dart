import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/main_controller.dart';
import '../widget/bottom_navigation.dart';
import 'home/home_page.dart';
import 'specialties/specialties_page.dart';
import 'settings/settings_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();
    
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          HomePage(),
          SpecialtiesPage(),
          SettingsPage(),
        ],
      )),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
}
