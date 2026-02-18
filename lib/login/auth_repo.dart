import 'dart:io';
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';
import '../utils/client_api.dart';
import 'auth_controller.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response?> login(
      {required String username, required String password}) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = '';
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    }

    Map<String, String> body = {};
    body.addAll(<String, String>{"username": username, "password": password});

    print(body);
    return await apiClient.postData(AppConstants.loginUrl, body);
  }

  Future<Response?> getPublicKey() {
    return apiClient.getData(AppConstants.getPublicKeyUrl);
  }

  Future<Response?> encryptCredentials({required String username, required String password}) async {
    Map<String, String> body = {
      "username": username,
      "password": password
    };
    
    print("Encrypting credentials: $body");
    return await apiClient.postData(AppConstants.encryptUrl, body);
  }

  Future<Response?> getAccessToken(String userName) {
    print({"username": userName});
    return apiClient
        .postData(AppConstants.accessTokenUrl, {"username": userName});
  }

  Future<Response?> getParcelDetail(
      String parcelNumber, DateTime toDate, DateTime fromDate) {
    String toDateStr = toDate.toUtc().toIso8601String();
    String fromDateStr = fromDate.toUtc().toIso8601String();

    print({
      "createdOn": {"from": fromDateStr, "to": toDateStr},
      "trackingNumbers": [parcelNumber]
    });

    return apiClient.postData(AppConstants.searchParcelUrl, {
      "createdOn": {"from": fromDateStr, "to": toDateStr},
      "trackingNumbers": [parcelNumber]
    });
  }

  Future<Response?> validateParcel(String parcelNumber, DateTime toDate,
      DateTime fromDate, String reasonCode) {
    String toDateStr = toDate.toUtc().toIso8601String();
    String fromDateStr = fromDate.toUtc().toIso8601String();

    print({
      "trackingNumbers": [parcelNumber],
      "arrSelectedBoxes": null,
      "arrparcels": null,
      "reasonCode": reasonCode,
      "createdOn": {
        "from": fromDateStr,
        "to": toDateStr,
      },
      "entity": "DXB",
    });

    final Map<String, dynamic> requestBody = {
      "trackingNumbers": [parcelNumber],
      "arrSelectedBoxes": null,
      "arrparcels": null,
      "reasonCode": reasonCode,
      "createdOn": {
        "from": fromDateStr,
        "to": toDateStr,
      },
      "entity": "DXB",
    };

    return apiClient.postData(AppConstants.parcelUpdateUrl, requestBody);
  }

  Future<bool?> saveUserId(String token) async {
    return await sharedPreferences.setString(AppConstants.userId, token);
  }

  String getUserId() {
    return sharedPreferences.getString(AppConstants.userId) ?? "";
  }

  Future<bool?> saveUserName(String token) async {
    return await sharedPreferences.setString(AppConstants.userName, token);
  }

  String getUserName() {
    return sharedPreferences.getString(AppConstants.userName) ?? "";
  }

  Future<bool> saveUserEntities(List<String> entities) async {
    return await sharedPreferences.setStringList(
        AppConstants.entities, entities);
  }

  List<String> getUserEntities() {
    return sharedPreferences.getStringList(AppConstants.entities) ?? [];
  }

  Future<bool> saveEntityConfigurations(Map<String, Map<String, String>> configs) async {
    String jsonString = json.encode(configs);
    return await sharedPreferences.setString(AppConstants.entityConfigurations, jsonString);
  }

  Map<String, Map<String, String>> getEntityConfigurations() {
    String? jsonString = sharedPreferences.getString(AppConstants.entityConfigurations);
    if (jsonString != null) {
      try {
        Map<String, dynamic> decoded = json.decode(jsonString);
        // Convert Map<String, dynamic> to Map<String, Map<String, String>>
        Map<String, Map<String, String>> result = {};
        decoded.forEach((key, value) {
          if (value is Map) {
            result[key] = Map<String, String>.from(value);
          }
        });
        return result;
      } catch (e) {
        print("Error decoding entity configurations: $e");
      }
    }
    return {};
  }

  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.token);
  }

  ///user address and language code should not be deleted
  bool clearSharedData() {
    sharedPreferences.remove(AppConstants.token);
    sharedPreferences.clear();
    apiClient.token = null;
    return true;
  }

  Future<bool?> saveUserToken(String token) async {
    apiClient.token = token;
    apiClient.postUpdateHeader(token);
    return await sharedPreferences.setString(AppConstants.token, token);
  }

  String getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  Future<bool?> updateApiHeader() async {
    String token = sharedPreferences.getString(AppConstants.token) ?? "";
    apiClient.token = token;
    apiClient.postUpdateHeader(token);
    return await sharedPreferences.setString(AppConstants.token, token);
  }

  Future<Response?> getReasonsList() {
    return apiClient.getData(AppConstants.reasonsListUrl);
  }

  Future<Response?> getEntityName(String entityCode) {
    return apiClient.getData("${AppConstants.entitiesUrl}/$entityCode");
  }
}
