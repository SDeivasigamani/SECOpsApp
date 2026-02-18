import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:opsapp/splash/controller/splash_controller.dart';
import 'package:opsapp/utils/app_constants.dart';
import 'package:opsapp/utils/connectivity_service.dart';
import 'package:opsapp/utils/initial_binding.dart';
import 'package:opsapp/utils/route_helper.dart';
import 'package:opsapp/utils/theme/dark_theme.dart';
import 'package:opsapp/utils/theme/light_theme.dart';
import 'package:opsapp/utils/theme/theme_controller.dart';



Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  ConnectivityService().initialize();

  await initControllers();
  await GetStorage.init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
  // runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

ThemeController? themeController;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


class _MyAppState extends State<MyApp> {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder:  (themeController1){
      themeController=themeController1;
      return GetBuilder<SplashController>(builder: (splashController) {
        return GetMaterialApp(
          title: AppConstants.appName,
          theme: themeController1.darkTheme ? dark : light,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
          ),
          initialBinding: InitialBinding(),
          initialRoute: RouteHelper.getSplashRoute(),
          getPages: RouteHelper.routes,
          defaultTransition: Transition.topLevel,
          transitionDuration: const Duration(milliseconds: 500),
        );
      });
    });

  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class LoadingOverlay {
  static final LoadingOverlay _instance = LoadingOverlay._internal();

  factory LoadingOverlay() {
    return _instance;
  }

  LoadingOverlay._internal();

  OverlayEntry? _overlayEntry;

  void show() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: CircularProgressIndicator(color: HexColor('#6B3D98')),
        ),
      ),
    );

    navigatorKey.currentState?.overlay?.insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

