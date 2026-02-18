import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';
import '../../utils/client_api.dart';

class SplashRepo {
  ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SplashRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response?> getAppVersion() {

    return apiClient.getData(AppConstants.appVersionUrl);
  }

  Future<Response?> getPublicKey() {
    return apiClient.getData(AppConstants.getPublicKeyUrl);
  }

  Future<bool> initSharedData() async {

    // if (!sharedPreferences.containsKey(AppConstants.notification)) {
    //   sharedPreferences.setBool(AppConstants.notification, true);
    // }
    return Future.value(true);
  }

  Future<bool> setSplashSeen(bool isSplashSeen) async {
    return await sharedPreferences.setBool(
        AppConstants.isOnBoardScreen, isSplashSeen);
  }

  bool isSplashSeen() {
    return sharedPreferences.getBool(AppConstants.isOnBoardScreen) != null
        ? sharedPreferences.getBool(AppConstants.isOnBoardScreen)!
        : false;
  }

}
