import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {
  final Rx<Locale> locale;

  LocaleController(Locale initialLocale) : locale = initialLocale.obs {
    Get.locale = initialLocale;
  }

  void updateLocale(Locale newLocale) {
    locale.value = newLocale;
    Get.locale = newLocale;
  }
}
