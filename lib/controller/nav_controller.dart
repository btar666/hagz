import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/session_controller.dart';
import '../view/home/home_page.dart';
import '../view/specialties/specialties_page.dart';
import '../view/statistics/statistics_page.dart';
import '../view/settings/settings_page.dart';
import '../view/chat/chats_page.dart';
import '../view/secretary/secretary_home_page.dart';
import '../view/secretary/secretary_all_appointments_page.dart';
import '../view/delegate/delegate_home_page.dart';
import '../view/delegate/delegate_all_visits_page.dart';
import '../view/delegate/delegate_statistics_page.dart';
import '../controller/home_controller.dart';
import '../controller/hospitals_controller.dart';

class NavItem {
  final String label;
  final String iconAsset;
  final Widget Function() builder;
  NavItem({required this.label, required this.iconAsset, required this.builder});
}

class NavController extends GetxController {
  final SessionController _session = Get.find<SessionController>();

  var selectedIndex = 0.obs;

  // Cache for pages per role; reinitialized when items length changes
  List<Widget?> _pagesCache = <Widget?>[];

  String get role => _session.role.value;

  List<NavItem> get items {
    // Define items per role
    if (role == 'doctor') {
      return [
        NavItem(
          label: 'الرئيسية',
          iconAsset: 'assets/icons/home/Home Icon.png',
          builder: () => const HomePage(),
        ),
        NavItem(
          label: 'الاختصاصات',
          iconAsset: 'assets/icons/home/Category Icon.png',
          builder: () => const SpecialtiesPage(),
        ),
        NavItem(
          label: 'الاحصائيات',
          iconAsset: 'assets/icons/home/statistics_page_icon.png',
          builder: () => const StatisticsPage(),
        ),
        NavItem(
          label: 'الإعدادات',
          iconAsset: 'assets/icons/home/Setting Icon.png',
          builder: () => const SettingsPage(),
        ),
      ];
    }

    if (role == 'secretary') {
      return [
        NavItem(
          label: 'الرئيسية',
          iconAsset: 'assets/icons/home/Home Icon.png',
          builder: () => const SecretaryHomePage(),
        ),
        NavItem(
          label: 'جميع المواعيد',
          iconAsset: 'assets/icons/home/alldates.png',
          builder: () => const SecretaryAllAppointmentsPage(),
        ),
        NavItem(
          label: 'المحادثات',
          iconAsset: 'assets/icons/home/Message_Icon_2.png',
          builder: () => const ChatsPage(),
        ),
        NavItem(
          label: 'الإعدادات',
          iconAsset: 'assets/icons/home/Setting Icon.png',
          builder: () => const SettingsPage(),
        ),
      ];
    }

    if (role == 'delegate') {
      return [
        NavItem(
          label: 'الرئيسية',
          iconAsset: 'assets/icons/home/Home Icon.png',
          builder: () => const DelegateHomePage(),
        ),
        NavItem(
          label: 'جميع الزيارات',
          iconAsset: 'assets/icons/home/person_icon.png',
          builder: () => const DelegateAllVisitsPage(),
        ),
        NavItem(
          label: 'الاحصائيات',
          iconAsset: 'assets/icons/home/statistics_page_icon.png',
          builder: () => const DelegateStatisticsPage(),
        ),
        NavItem(
          label: 'الإعدادات',
          iconAsset: 'assets/icons/home/Setting Icon.png',
          builder: () => const SettingsPage(),
        ),
      ];
    }

    // Default (patient/user)
    return [
      NavItem(
        label: 'الرئيسية',
        iconAsset: 'assets/icons/home/Home Icon.png',
        builder: () => const HomePage(),
      ),
      NavItem(
        label: 'الاختصاصات',
        iconAsset: 'assets/icons/home/Category Icon.png',
        builder: () => const SpecialtiesPage(),
      ),
      NavItem(
        label: 'الإعدادات',
        iconAsset: 'assets/icons/home/Setting Icon.png',
        builder: () => const SettingsPage(),
      ),
    ];
  }

  void _ensureCache() {
    final int len = items.length;
    if (_pagesCache.length != len) {
      _pagesCache = List<Widget?>.filled(len, null, growable: false);
      // Clamp selected index within bounds
      if (selectedIndex.value > len - 1) selectedIndex.value = len - 1;
    }
  }

  Widget getPage(int index) {
    _ensureCache();
    _pagesCache[index] ??= items[index].builder();
    return _pagesCache[index]!;
  }

  void changeIndex(int index) {
    _ensureCache();
    selectedIndex.value = index;

    // Optional: refresh home data when returning to Home tab
    if (index == 0) {
      _refreshHomeData();
    }

    // Free other tabs like mojod mechanism
    for (int i = 0; i < _pagesCache.length; i++) {
      if (i != index) {
        _pagesCache[i] = null;
      }
    }
  }

  void _refreshHomeData() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        // Lightweight refresh
        if (home.doctors.isEmpty && !home.isLoadingDoctors.value) {
          home.fetchDoctors(reset: true);
        }
        if (home.topRatedDoctors.isEmpty && !home.isLoadingTopRated.value) {
          home.fetchTopRatedDoctors();
        }
      }
      if (Get.isRegistered<HospitalsController>()) {
        final hospitals = Get.find<HospitalsController>();
        if (hospitals.hospitals.isEmpty && !hospitals.isLoading.value) {
          hospitals.fetchHospitals();
        }
      }
    } catch (_) {}
  }
}
