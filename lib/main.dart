import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hagz/firebase_options.dart';
import 'package:hagz/services/firebase_messaging_service.dart';
import 'package:hagz/services/local_notifications_service.dart';
import 'controller/main_controller.dart';
import 'controller/chat_controller.dart';
import 'controller/locale_controller.dart';
import 'bindings/home_binding.dart';
import 'utils/app_colors.dart';
import 'utils/translations.dart';
import 'controller/session_controller.dart';
import 'view/onboarding/onboarding_page.dart';
import 'view/main_page.dart';
import 'service_layer/services/get_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(
    localNotificationsService: localNotificationsService,
  );

  FirebaseMessaging.instance.subscribeToTopic('appall');
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await GetStorageService().init();

  // Load saved language or use Arabic as default
  final storage = GetStorageService();
  final savedLanguage = storage.read<String>('selected_language') ?? 'ar';
  final locale = savedLanguage == 'en'
      ? const Locale('en')
      : const Locale('ar');

  runApp(MedicalApp(initialLocale: locale));
}

class MedicalApp extends StatelessWidget {
  final Locale initialLocale;

  const MedicalApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    // Initialize locale in GetX
    Get.locale = initialLocale;

    // Initialize LocaleController once
    final localeController = Get.put(
      LocaleController(initialLocale),
      permanent: true,
    );

    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() {
          // Force rebuild by reading locale value
          final currentLocale = localeController.locale.value;
          // Use builder to ensure app rebuilds
          return GetMaterialApp(
            key: ValueKey('app_locale_${currentLocale.languageCode}'),
            builder: (context, child) {
              // Access locale to ensure rebuild
              final _ = Get.locale;
              return child ?? const SizedBox.shrink();
            },
            title: 'حجز - التطبيق الطبي',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                background: AppColors.background,
                surface: AppColors.surface,
                error: AppColors.error,
              ),
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              shadowColor: AppColors.shadow,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              ),
              // Card styling handled locally for maximum compatibility
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.4),
                ),
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
                  TargetPlatform.windows: ZoomPageTransitionsBuilder(),
                  TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
                  TargetPlatform.linux: ZoomPageTransitionsBuilder(),
                },
              ),
              fontFamily: 'Expo Arabic',
            ),
            home: _resolveStartPage(),
            translations: MyTranslations(),
            locale: currentLocale,
            fallbackLocale: const Locale('ar'),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            defaultTransition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 220),
            onInit: () {
              // Set initial locale
              Get.locale = initialLocale;
              // Initialize controllers
              Get.put(MainController());
              Get.put(SessionController());
              Get.put(ChatController());
              // Global bindings for first home entry
              HomeBinding().dependencies();
            },
          );
        });
      },
    );
  }
}

Widget _resolveStartPage() {
  final storage = GetStorageService();
  final savedToken = storage.read<String>('auth_token');
  if ((savedToken ?? '').isNotEmpty) {
    return const MainPage();
  }
  return const OnboardingPage();
}
