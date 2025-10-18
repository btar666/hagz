import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controller/main_controller.dart';
import 'bindings/home_binding.dart';
import 'utils/app_colors.dart';
import 'controller/session_controller.dart';
import 'view/onboarding/onboarding_page.dart';
import 'view/main_page.dart';
import 'service_layer/services/get_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // init persistent storage
  await GetStorageService().init();

  runApp(const MedicalApp());
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'حجز - التطبيق الطبي',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            fontFamily: 'Expo Arabic',
          ),
          home: _resolveStartPage(),
          locale: const Locale('ar'),
          fallbackLocale: const Locale('ar'),
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onInit: () {
            // Initialize controllers
            Get.put(MainController());
            Get.put(SessionController());
            // Global bindings for first home entry
            HomeBinding().dependencies();
          },
        );
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
