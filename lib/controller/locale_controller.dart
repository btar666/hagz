import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:hagz/service_layer/services/get_storage_service.dart';

class LocaleController extends GetxController {
  static LocaleController get to => Get.find();

  final RxString selectedLanguage = RxString('ar');

  LocaleController() {
    final storage = GetStorageService();
    final saved = storage.read<String>('selected_language') ?? 'ar';
    selectedLanguage.value = saved;
    _setLocale(saved);
  }

  void _setLocale(String languageCode) {
    final locale = languageCode == 'en'
        ? const Locale('en')
        : const Locale('ar');
    // Update GetX locale to trigger translations update
    Get.locale = locale;
    Get.updateLocale(locale);
  }

  void changeLanguage(String languageCode) {
    print('🔄 changeLanguage called with: $languageCode');
    print('📌 Current selectedLanguage: ${selectedLanguage.value}');

    if (selectedLanguage.value == languageCode) {
      print('⚠️ Same language, returning');
      return;
    }

    // Save to storage first
    final storage = GetStorageService();
    storage.write('selected_language', languageCode);
    print('💾 Saved to storage: $languageCode');

    // Update reactive variable
    selectedLanguage.value = languageCode;
    print('✅ Updated selectedLanguage to: ${selectedLanguage.value}');

    // Update GetX locale (this will trigger translations update)
    _setLocale(languageCode);

    // Notify all GetBuilder widgets to rebuild immediately
    // First update with specific ID for main.dart GetBuilder
    update(['locale_builder']);

    // Then update all other GetBuilder listeners
    update();

    // Force immediate rebuild using SchedulerBinding to ensure UI updates
    // This is especially important when switching to English
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Ensure locale is updated after frame (critical for English switch)
      _setLocale(languageCode);
      // Force rebuild again after frame
      update(['locale_builder']);
      update();

      // Double check after another frame to ensure update
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _setLocale(languageCode);
        update(['locale_builder']);
        update();
      });
    });

    print('🔔 GetBuilder notified with id: locale_builder');
  }
}
