
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../login/model/app_version_model.dart';
import '../../login/model/get_publickey_model.dart';
import '../repository/splash_repo.dart';


class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;
  SplashController({required this.splashRepo});

  bool _firstTimeConnectionCheck = true;
  bool _hasConnection = true;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  VersionCheckApiModel? appVersionModel;

  // ConfigModel _configModel = ConfigModel();
  // ConfigModel get configModel => _configModel;
  DateTime get currentTime => DateTime.now();
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
  bool get hasConnection => _hasConnection;
  GetPublicKey? getPublicKeyToJson;

 
  // void _saveConfigData(dynamic responseBody) {
  //   final box = GetStorage("config_data");
  //   box.write("config_data", responseBody);
  // }

  // ConfigModel? _retriveConfigDataFromLocal() {
  //   final box = GetStorage("config_data");
  //   return box.read("config_data") != null
  //       ? ConfigModel.fromJson(box.read("config_data"))
  //       : null;
  // }

  Future<bool?> getAppVersion() async {

    final response = await splashRepo.getAppVersion();
    if (response != null && response.statusCode == 200) {
      appVersionModel = VersionCheckApiModel.fromJson(response.body);
      update();
      return true;
    }

    return false;
  }

  Future<bool?> getPublicKey() async {

    final response = await splashRepo.getPublicKey();
    if (response != null && response.statusCode == 200) {
      getPublicKeyToJson = GetPublicKey.fromJson(response.body);
      update();
      return true;
    }

    return false;
  }


  Future<bool> initSharedData() {
    return splashRepo.initSharedData();
  }

  Future<bool> saveSplashSeenValue(bool value) async {
    return await splashRepo.setSplashSeen(value);
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  bool isSplashSeen() => splashRepo.isSplashSeen();
}
