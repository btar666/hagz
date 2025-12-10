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
import 'view/home/doctors/doctor_profile_page.dart';
import 'bindings/doctor_profile_binding.dart';
import 'service_layer/services/get_storage_service.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

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
    // Initialize LocaleController once
    Get.put(LocaleController(), permanent: true);

    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() {
          final localeController = Get.find<LocaleController>();
          final locale = localeController.selectedLanguage.value == 'en'
              ? const Locale('en')
              : const Locale('ar');
          // تحديث locale عند تغيير اللغة
          if (Get.locale != locale) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.updateLocale(locale);
            });
          }
          return GetMaterialApp(
            key: ValueKey('app_${localeController.selectedLanguage.value}'),
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
            locale: locale,
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

              // Initialize deep linking handler
              _initDeepLinking();
            },
            getPages: [
              // Add named routes for deep linking
              GetPage(
                name: '/doctor/:id',
                page: () {
                  final id = Get.parameters['id'] ?? '';
                  final name = Get.parameters['name'] ?? 'طبيب';
                  final specialty = Get.parameters['specialty'] ?? '';
                  return DoctorProfilePage(
                    doctorId: id,
                    doctorName: name,
                    specializationId: specialty,
                  );
                },
                binding: DoctorProfileBinding(),
              ),
            ],
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

/// Initialize deep linking handler
final AppLinks _appLinks = AppLinks();
StreamSubscription<Uri>? _linkSubscription;

void _initDeepLinking() async {
  // Handle initial link if app was opened via deep link
  try {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(link: initialUri.toString());
    }
  } catch (e) {
    print('Error getting initial link: $e');
  }

  // Listen for deep links while app is running
  _linkSubscription = _appLinks.uriLinkStream.listen(
    (Uri uri) {
      _handleDeepLink(link: uri.toString());
    },
    onError: (err) {
      print('Error listening to link stream: $err');
    },
  );
}

/// Handle deep link
void _handleDeepLink({String? link}) {
  if (link == null || link.isEmpty) {
    return;
  }

  print('🔗 Received deep link: $link');

  try {
    final uri = Uri.parse(link);
    print(
      '🔗 Parsed URI: scheme=${uri.scheme}, host=${uri.host}, path=${uri.path}',
    );

    // Handle both custom scheme and universal links
    // Support: hagz://doctor/123 and https://hagz.app/doctor/123
    if (uri.scheme == 'hagz' ||
        (uri.scheme == 'https' &&
            (uri.host == 'hagz.app' || uri.host.contains('hagz')))) {
      // For custom scheme like hagz://doctor/123, pathSegments will be ['doctor', '123']
      // For universal links like https://hagz.app/doctor/123, pathSegments will be ['doctor', '123']
      final pathSegments = uri.pathSegments;
      print('🔗 Path segments: $pathSegments');
      print('🔗 Full path: ${uri.path}');

      // Handle doctor profile link: hagz://doctor/123 or hagz://doctor/692448ea08542e21784b6f90
      if (pathSegments.isNotEmpty &&
          pathSegments[0] == 'doctor' &&
          pathSegments.length > 1) {
        final doctorId = pathSegments[1];
        final doctorName = uri.queryParameters['name'] ?? 'طبيب';
        final specialty = uri.queryParameters['specialty'] ?? '';

        print('🔗 Opening doctor profile: id=$doctorId, name=$doctorName');

        // Wait a bit for app to be ready, then navigate
        Future.delayed(const Duration(milliseconds: 500), () {
          try {
            if (Get.isRegistered<MainController>()) {
              Get.toNamed(
                '/doctor/$doctorId',
                parameters: {
                  'id': doctorId,
                  'name': doctorName,
                  'specialty': specialty,
                },
              );
            } else {
              // If controllers not ready, store link and handle after init
              Future.delayed(const Duration(seconds: 1), () {
                Get.toNamed(
                  '/doctor/$doctorId',
                  parameters: {
                    'id': doctorId,
                    'name': doctorName,
                    'specialty': specialty,
                  },
                );
              });
            }
          } catch (e) {
            print('❌ Error navigating to doctor profile: $e');
          }
        });
      } else {
        print('⚠️ Invalid deep link format. Expected: hagz://doctor/ID');
      }
    } else {
      print('⚠️ Unknown scheme or host: ${uri.scheme}://${uri.host}');
    }
  } catch (e) {
    print('❌ Error handling deep link: $e');
  }
}
