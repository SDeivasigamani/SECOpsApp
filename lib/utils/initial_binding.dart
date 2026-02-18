

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:opsapp/utils/theme/theme_controller.dart';

import '../login/auth_controller.dart';
import '../login/auth_repo.dart';
import '../splash/controller/splash_controller.dart';
import '../splash/repository/splash_repo.dart';
import 'client_api.dart';
import 'config.dart';
import '../destination_handling/destination_handling_controller.dart';
import '../destination_handling/destination_handling_repo.dart';
import '../trips/generate_trip_controller.dart';
import '../trips/generate_trip_repo.dart';

Future<bool> initControllers() async {

  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => ApiClient(appBaseUrl: Config.baseUrl, sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(splashRepo: SplashRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
  Get.lazyPut(() => AuthController(authRepo: AuthRepo(sharedPreferences:Get.find(),apiClient: Get.find())));
  Get.lazyPut(() => DestinationHandlingController(destinationHandlingRepo: DestinationHandlingRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
  Get.lazyPut(() => GenerateTripController(generateTripRepo: GenerateTripRepo(apiClient: Get.find(), sharedPreferences: Get.find())));

  return true;
}

class InitialBinding extends Bindings {
  @override
  void dependencies() async {
    //common controller
    Get.lazyPut(() => SplashController(
        splashRepo:
        SplashRepo(apiClient: Get.find(), sharedPreferences: Get.find())));

  }
}