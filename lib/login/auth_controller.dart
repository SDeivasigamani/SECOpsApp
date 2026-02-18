import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:opsapp/search_parcel/model/parcel_detail_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:opsapp/login/model/app_version_model.dart';
import 'package:opsapp/login/model/user_model.dart';

import '../main.dart';
import '../parcel_inbound/model/reasons_list_model.dart';
import '../utils/app_constants.dart';
import '../utils/route_helper.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/loading_indicator.dart';
import 'HybridEncryptor.dart';
import 'package:xml/xml.dart' as xml;
import 'package:convert/convert.dart';
import '../utils/api_checker.dart';
import 'auth_repo.dart';
import 'model/get_publickey_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;

  AuthController({required this.authRepo});

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool? _acceptTerms = false;
  bool isTapNotification = false;

  bool get isLoading => _isLoading;

  bool? get acceptTerms => _acceptTerms;

  ///textEditingController for signIn screen
  var signInEmailController = TextEditingController();
  var signInPasswordController = TextEditingController();

  TextEditingController searchController = TextEditingController();

  List<String> groupIdsList = [];
  String currentChatId = '';

  UserModel? userModel;
  String primaryStatus = '';
  String? userId = '';
  String userName = '';

  String patientName = '';
  String patientAge = '';

  GetPublicKey? getPublicKeyToJson;
  ParcelDetailModel? parcelDetails;
  List<ReasonsListModel>? allReasonsList;
  List<ReasonsListModel>? filteredReasons;
  String? selectedReason;


  String condition = "OK";
  var okCount = 0.obs;
  var holdCount = 0.obs;
  String? selectedEntity = '';
  List<String> userEntities = [];
  bool _entitiesLoaded = false; // Flag to track if entities have been loaded with names

  @override
  void onInit() {
    super.onInit();
    signInEmailController.text = '';
    signInPasswordController.text = '';

    // Load entities from SharedPreferences on init
    final entitiesList = getUserEntities();
    if (entitiesList.isNotEmpty && selectedEntity!.isEmpty) {
      selectedEntity = entitiesList[0];
    }

    // Load userName from SharedPreferences
    userName = authRepo.getUserName();
    
    // Check if entities already have names (contain " - ")
    if (entitiesList.isNotEmpty && entitiesList[0].contains(" - ")) {
      _entitiesLoaded = true;
    }

    // Load entity configurations
    entityConfigurations = authRepo.getEntityConfigurations();
  }

  Map<String, Map<String, String>> entityConfigurations = {};

  Future<void> updateUserEntities() async {
    // Check if we need updates: 
    // 1. If entities not loaded at all
    // 2. If we have entities but haven't fetched their configs yet (checking random opsapp or if map is empty)
    if (_entitiesLoaded && entityConfigurations.isNotEmpty) {
      return;
    }

    _isLoading = true;
    update();

    bool hasUpdates = false;
    bool hasConfigUpdates = false;

    for (int i = 0; i < userEntities.length; i++) {
      final String fullEntityString = userEntities[i];
      // Extract code if it already has name (e.g., "DXB - Dubai" -> "DXB")
      final String code = fullEntityString.contains(" - ") 
          ? fullEntityString.split(" - ")[0] 
          : fullEntityString;
      
      // Even if name is loaded, we might not have configs, so we might need to fetch again if config is missing.
      // However, to avoid over-fetching, we'll assume if name is present, we might have skipped fetching.
      // But getting configs is important now.
      
      // Check if we already have config for this code
      if (entityConfigurations.containsKey(code) && fullEntityString.contains(" - ")) {
        continue;
      }

      final response = await authRepo.getEntityName(code);

      if (response != null && response.statusCode == 200) {

        print(response.body);

        final entityName = response.body["name"] ?? "";
        
        // Parse entityDefaults
        if (response.body["entityDefaults"] != null) {
          final defaults = response.body["entityDefaults"];
          entityConfigurations[code] = {
            "weightUnit": defaults["weightUnit"]?.toString() ?? "kg",
            "dimensionUnit": defaults["dimensionUnit"]?.toString() ?? "cm",
          };
        } else {
           // Default fallback
           entityConfigurations[code] = {
            "weightUnit": "kg",
            "dimensionUnit": "cm",
          };
        }
        hasConfigUpdates = true;

        String newValue = "$code - $entityName";

        // If the currently selected entity matches the one we are updating (by code), update the selection too
        if (selectedEntity != null && (selectedEntity == code || selectedEntity!.startsWith("$code - "))) {
          selectedEntity = newValue;
        }

        if (userEntities[i] != newValue) {
           userEntities[i] = newValue;
           hasUpdates = true;
        }
        
        // Update UI after each entity to show progress
        update();
      } else {
        print("Failed to fetch entity for $code");
         // Default fallback on failure
         if (!entityConfigurations.containsKey(code)) {
            entityConfigurations[code] = {
              "weightUnit": "kg",
              "dimensionUnit": "cm",
            };
            hasConfigUpdates = true;
         }
      }
    }
    
    // Save updated entities to local storage if any changes were made
    if (hasUpdates) {
      await authRepo.saveUserEntities(userEntities);
    }
    
    // Save entity configurations
    if (hasConfigUpdates) {
      await authRepo.saveEntityConfigurations(entityConfigurations);
    }

    if (userEntities.isNotEmpty && (selectedEntity == null || selectedEntity!.isEmpty)) {
      selectedEntity = userEntities[0];
    }
    
    _entitiesLoaded = true; // Mark as loaded
    _isLoading = false;
    update();
  }

  _hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  Future<void> login(context) async {
    if (signInEmailController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter username.", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }
    if (signInPasswordController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter password.", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }
    _hideKeyboard();
    _isLoading = true;
    update();

    try {
      // Call encryption API to get encrypted credentials
      Response? encryptResponse = await authRepo.encryptCredentials(
        username: signInEmailController.text.trim(),
        password: signInPasswordController.text.trim(),
      );

      if (encryptResponse == null || encryptResponse.statusCode != 200) {
        Get.snackbar("Error", "You have entered an invalid username or password.", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
        _isLoading = false;
        update();
        return;
      }

      // Extract encrypted values from response
      String encryptedUsername = encryptResponse.body['username'] ?? '';
      String encryptedPassword = encryptResponse.body['password'] ?? '';

      if (encryptedUsername.isEmpty || encryptedPassword.isEmpty) {
        Get.snackbar("Error", "Encryption failed. Please try again.", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
        _isLoading = false;
        update();
        return;
      }

      print("Encrypted Username: $encryptedUsername");
      print("Encrypted Password: $encryptedPassword");

      // Call login API with encrypted credentials
      Response? response = await authRepo.login(
        username: encryptedUsername,
        password: encryptedPassword,
      );

      if (response != null && response.statusCode == 200) {
        String accessToken = response.body['token'];
        await authRepo.saveUserToken(accessToken);

        // Parse the payload from JWT
        Map<String, dynamic> payload = Jwt.parseJwt(accessToken);

        // Extract raw string fields
        String entitiesStr = payload['entities'] ?? '[]';
        // Convert stringified JSON arrays to Dart Lists
        List<String> entities = List<String>.from(json.decode(entitiesStr));
        await authRepo.saveUserEntities(entities);
        userEntities = entities;

        if (userEntities.isNotEmpty) {
          selectedEntity = userEntities[0];
        }

        // Fetch entity names
        await updateUserEntities();

        // Save username locally
        userName = signInEmailController.text.trim();
        await authRepo.saveUserName(userName);

        signInEmailController.clear();
        signInPasswordController.clear();

        update();

        Get.offAllNamed(RouteHelper.getUsersHome());
      } else {
        Get.snackbar("Error", response?.bodyString ?? "Login failed", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      print("Login error: $e");
      Get.snackbar("Error", "An error occurred during login: $e", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    }

    _isLoading = false;
    update();
  }

//   Future<void> login(context) async {
//     if (signInEmailController.text.trim().isEmpty) {
//       Get.snackbar("Please enter username.", isError: true);
//       return;
//     }
//     if (signInPasswordController.text.trim().isEmpty) {
//       Get.snackbar("Please enter password.", isError: true);
//       return;
//     }
//     _hideKeyboard();
//     _isLoading = true;
//     update();
//
//     /*// Replace with your actual RSA public key modulus and exponent
//       final modulus = BigInt.parse("xPDKlS97ph+5eN0iXC9fW0xW+LBbBhb1fMFHc6JOMFc2tnsiyJ4yu4qTjgiqHlHJ9nShqDPQ9wBRe3phhL/XJNDdKhDmUG+QJT7VQ4v4Ee6ORQpgZgxLA9TnWva8wsM3cGEQLXBi+xML3xintVpnSDIQZQ7momZ6M9Llm3os0/0=");
//       final exponent = BigInt.parse("AQAB"); // Standard public exponent
//
//       final publicKey = RSAPublicKey(modulus, exponent);
//
//       final encrypted = HybridEncryptor.encryptHybrid(
//         plainText: signInEmailController.text.trim(),
//         rsaPublicKey: publicKey,
//       );
//
//       print("Encrypted Base64 Result:\n$encrypted");*/
//
//     /*BigInt getData(xml.XmlDocument xmlDocument, String element){
//         var dataB64 = xmlDocument.findAllElements(element).single.innerText;
//         var dataBytes = Uint8List.fromList(base64.decode(dataB64));
//         return BigInt.parse(hex.encode(dataBytes), radix: 16);
//       }
//
//       //final modulus = BigInt.parse("xPDKlS97ph+5eN0iXC9fW0xW+LBbBhb1fMFHc6JOMFc2tnsiyJ4yu4qTjgiqHlHJ9nShqDPQ9wBRe3phhL/XJNDdKhDmUG+QJT7VQ4v4Ee6ORQpgZgxLA9TnWva8wsM3cGEQLXBi+xML3xintVpnSDIQZQ7momZ6M9Llm3os0/0=");
//       //final exponent = BigInt.parse("AQAB"); // Standard public exponent
//       var privateKeyXML = '<RSAKeyValue><Modulus>unF5aDa6HCfLMMI/MZLT5hDk304CU+ypFMFiBjowQdUMQKYHZ+fklB7GpLxCatxYJ/hZ7rjfHH3Klq20/Y1EbYDRopyTSfkrTzPzwsX4Ur/l25CtdQldhHCTMgwf/Ev/buBNobfzdZE+Dhdv5lQwKtjI43lDKvAi5kEet2TFwfJcJrBiRJeEcLfVgWTXGRQn7gngWKykUu5rS83eAU1xH9FLojQfyia89/EykiOO7/3UWwd+MATZ9HLjSx2/Lf3g2jr81eifEmYDlri/OZp4OhZu+0Bo1LXloCTe+vmIQ2YCX7EatUOuyQMt2Vwx4uV+d/A3DP6PtMGBKpF8St4iGw==</Modulus><Exponent>AQAB</Exponent><P>3e+jND6OS6ofGYUN6G4RapHzuRAV8ux1C9eXMOdZFbcBehn/ydhzR48LIPTW9HiRE00um27lXfW5/POCaEUvfOp1UxTWeHZ4xICo40PBo383ZKW1MbES1oiMbjkEqSFGRnTItnLU07bKbzLA7I0UWHWCEAnv0g7HRxk973FAsm8=</P><Q>1w8+olZ2POBYeYgw1a0DkeJWKMQi/4pAgyYwustZo0dHlRXQT0OI9XQ0j1PZWoQS28tFcmoEAg6f5MUDpdM9swS0SOCPI1Lc/f/Slus3u1O3UCezk37pneSPezskDhvV2cClJEYH8m/zwDAUlEi4KLIt/H/jgtyDd6pbxxc78RU=</Q><DP>iE6VAxJknM4oeakBiL6JTdXEReY+RMu7e4F2518/lJmoe5CaTCL3cnzFTgFyQAYIvD0MIgSzNMkl6Ni6QEY1y1fIpTVIIAZLWAzZLXPA6yTIJbWsmo9xzXdiIJQ+a433NnClkYDne/xpSnB2kxJ263mIX0drFq1i8STsqDH7lVs=</DP><DQ>VqUJsxXqpTQt8Sjxo+UE3y21UM9U2me0/iHQ2DE9eA8rw+D6ADVRZLLgyi4aD+HOR0dqP2J/IuUJfn3xrkmhPhLTH9l5Ud38s0jya2NxHMPpwx17uB0Vuktvk1KMgDKuwgBfiHG+meqI5hF4+RUjPSIsbOKJoxt8zCWSvG+b8tE=</DQ><InverseQ>s9Fu1JsTak+C84codMY+vuApuaxZVs5xADysbzTVPfxb9Q97Ve3KcwSPPNDb05pV5DC9Q334PEVcnpi/CPqKHhZ2rXT2Ls6jV8OcxzM5A30MpyHZ40Aes1I4zIsMIGb77BvIcCxLZPRU7z6DMsAG+JmbkAUJBZ+R7gtmjmY5LXQ=</InverseQ><D>SlJj0ExIomKmmBhG8q8SM1s2sWG6gdQMjs6MEeluRT/1c2v79cq2Dum5y/+UBl8x8TUKPKSLpCLs+GXkiVKgHXrFlqoN+OYQArG2EUWzuODwczdYPhhupBXwR3oX4g41k/BsYfQfZBVzBFEJdWrIDLyAUFWNlfdGIj2BTiAoySfyqmamvmW8bsvc8coiGlZ28UC85/Xqx9wOzjeGoRkCH7PcTMlc9F7SxSthwX/k1VBXmNOHa+HzGOgO/W3k1LDqJbq2wKjZTW3iVEg2VodjxgBLMm0MueSGoI6IuaZSPMyFEM3gGvC2+cDBI2SL/amhiTUa/VDlTVw/IKbSuar9uQ==</D></RSAKeyValue>''';
//       //var privateKeyXML = getPublicKeyXML();
//       var xmlDocument = xml.XmlDocument.parse(privateKeyXML);
//       var modulus = getData(xmlDocument, 'Modulus');
//       var exponent = getData(xmlDocument, 'Exponent');
//
//
//
//
//       RSAPublicKey parsePublicKey(BigInt modulus, BigInt exponent) {
//         return RSAPublicKey(modulus, exponent);
//       }
//
//       final publicKey = parsePublicKey(modulus, exponent);
//       final encryptedUsername = HybridEncryptor.encryptHybrid(
//         plainText: signInEmailController.text.trim(),
//         rsaPublicKey: publicKey,
//       );
//       final encryptedPassword = HybridEncryptor.encryptHybrid(
//         plainText: signInPasswordController.text.trim(),
//         rsaPublicKey: publicKey,
//       );
//
//       print("Encrypted Username Base64 Result:\n$encryptedUsername");
//       print("Encrypted Password Base64 Result:\n$encryptedPassword");
//
// */
//     /*Response? response = await authRepo.login(
//           username: signInEmailController.text.trim(),
//           password: signInPasswordController.value.text);*/
//     Response? response = await authRepo.login(
//         username:
//         'DQtMdE/pxe7iadLP7NqfIjPgutnDVVm7Lk4bGAzBhylnJDSp1A0OCAtctlsgV0ab/UNPhf0xhQVgGkJN7qQOgJbXAHxGkTZ8OvjdqBtbwf9TbSvedxjsNUl7/f8ZpF0wbyMFESB4vc0PPg8O3s16jtoIECz2EkmBbHUP7zDpbx5OurwjD1BpexMfPqvTUam6Kj9SXedDef8y8S/RFVVDrA==',
//         password:
//         'vlXM7/rklOCaDyZoq1ilFLvndOdkxxveNpfoSVI3r+WAPTpOGm6PZ9YgTWgxNDAjVD9CqaqTV4EesWeB8ZQf52hI6Q7TSLaVWGKz4CMsYd0RTgmN6MFIT7+NhBolYZOhrGjvLYt6XkLrpT0+EpC836H1zl4G8Ety5fD75zoGuImwGM8QHfGvxmE63mtc7G2qThtclW0kj7XZpT/GOJ/P+g==');
//     /* Response? response = await authRepo.login(
//           username: "$encryptedUsername",
//           password: "$encryptedPassword");*/
//     if (response != null && response.statusCode == 200) {
//       String accessToken = response.body['token'];
//       await authRepo.saveUserToken(accessToken);
//
//       // Parse the payload from JWT
//       Map<String, dynamic> payload = Jwt.parseJwt(accessToken);
//
//       // Extract raw string fields
//       String entitiesStr = payload['entities'] ?? '[]';
//       // Convert stringified JSON arrays to Dart Lists
//       List<String> entities = List<String>.from(json.decode(entitiesStr));
//       await authRepo.saveUserEntities(entities);
//       userEntities = entities;
//
//       if (userEntities.isNotEmpty) {
//         selectedEntity = userEntities[0];
//       }
//
//       // Fetch entity names
//       await updateUserEntities();
//
//       signInEmailController.clear();
//       signInPasswordController.clear();
//
//       update();
//
//       Get.offAllNamed(RouteHelper.getUsersHome());
//       /*if(userModel?.data?.defaultrole?.name == 'token') {
//           await saveUserDetail(userModel!);
//
//           String userID = response.body['data']['_id'];
//           authRepo.saveUserId(userID);
//           authRepo.saveUserName(signInEmailController.text.trim());
//
//           signInPasswordController.clear();
//           signInEmailController.clear();
//
//           Get.offAllNamed(RouteHelper.getUsersRoute());
//         } else {
//           Get.snackbar("You don't have access.", isError: true);
//         }*/
//     } else {
//       Get.snackbar(response?.bodyString ?? "Error", isError: true);
//     }
//     _isLoading = false;
//     update();
//   }

  // Future<void> login(context) async {
  //   if (signInEmailController.text.trim().isEmpty) {
  //     Get.snackbar("Please enter username.", isError: true);
  //     return;
  //   }
  //   if (signInPasswordController.text.trim().isEmpty) {
  //     Get.snackbar("Please enter password.", isError: true);
  //     return;
  //   }
  //   _hideKeyboard();
  //   _isLoading = true;
  //   update();
  //
  //   try {
  //     // Get RSA public key from API
  //     Response? publicKeyResponse = await authRepo.getPublicKey();
  //
  //     if (publicKeyResponse == null || publicKeyResponse.statusCode != 200) {
  //       Get.snackbar("Failed to get encryption key. Please try again.", isError: true);
  //       _isLoading = false;
  //       update();
  //       return;
  //     }
  //
  //     // Parse public key XML
  //     String publicKeyXML = publicKeyResponse.body['publicKey'] ?? '';
  //
  //     if (publicKeyXML.isEmpty) {
  //       Get.snackbar("Invalid encryption key. Please try again.", isError: true);
  //       _isLoading = false;
  //       update();
  //       return;
  //     }
  //
  //     // Extract modulus and exponent from XML
  //     var xmlDocument = xml.XmlDocument.parse(publicKeyXML);
  //     var modulus = getData(xmlDocument, 'Modulus');
  //     var exponent = getData(xmlDocument, 'Exponent');
  //
  //     // Create RSA public key
  //     final publicKey = RSAPublicKey(modulus, exponent);
  //
  //     // Encrypt username and password using hybrid encryption (AES + RSA)
  //     final encryptedUsername = HybridEncryptor.encryptHybrid(
  //       plainText: signInEmailController.text.trim(),
  //       rsaPublicKey: publicKey,
  //     );
  //
  //     final encryptedPassword = HybridEncryptor.encryptHybrid(
  //       plainText: signInPasswordController.text.trim(),
  //       rsaPublicKey: publicKey,
  //     );
  //
  //     if (encryptedUsername == null || encryptedPassword == null) {
  //       Get.snackbar("Encryption failed. Please try again.", isError: true);
  //       _isLoading = false;
  //       update();
  //       return;
  //     }
  //
  //     print("Encrypted Username: $encryptedUsername");
  //     print("Encrypted Password: $encryptedPassword");
  //
  //     // Call login API with encrypted credentials
  //     Response? response = await authRepo.login(
  //       username: encryptedUsername,
  //       password: encryptedPassword,
  //     );
  //
  //     if (response != null && response.statusCode == 200) {
  //       String accessToken = response.body['token'];
  //       await authRepo.saveUserToken(accessToken);
  //
  //       // Parse the payload from JWT
  //       Map<String, dynamic> payload = Jwt.parseJwt(accessToken);
  //
  //       // Extract raw string fields
  //       String entitiesStr = payload['entities'] ?? '[]';
  //       // Convert stringified JSON arrays to Dart Lists
  //       List<String> entities = List<String>.from(json.decode(entitiesStr));
  //       await authRepo.saveUserEntities(entities);
  //       userEntities = entities;
  //
  //       if (userEntities.isNotEmpty) {
  //         selectedEntity = userEntities[0];
  //       }
  //
  //       // Fetch entity names
  //       await updateUserEntities();
  //
  //       signInEmailController.clear();
  //       signInPasswordController.clear();
  //
  //       update();
  //
  //       Get.offAllNamed(RouteHelper.getUsersHome());
  //     } else {
  //       Get.snackbar(response?.bodyString ?? "Login failed", isError: true);
  //     }
  //   } catch (e) {
  //     print("Login error: $e");
  //     Get.snackbar("An error occurred during login: $e", isError: true);
  //   }
  //
  //   _isLoading = false;
  //   update();
  // }

  // BigInt getData(xml.XmlDocument xmlDocument, String element){
  //   var dataB64 = xmlDocument.findAllElements(element).single.innerText;
  //   var dataBytes = Uint8List.fromList(base64.decode(dataB64));
  //   return BigInt.parse(hex.encode(dataBytes), radix: 16);
  // }


  String _verificationCode = '';
  String _otp = '';

  String get otp => _otp;

  String get verificationCode => _verificationCode;

  void updateVerificationCode(String query) {
    _verificationCode = query;
    if (_verificationCode.isNotEmpty) {
      _otp = _verificationCode;
    }
    update();
  }

  bool _isActiveRememberMe = false;

  bool get isActiveRememberMe => _isActiveRememberMe;

  void toggleTerms() {
    _acceptTerms = !_acceptTerms!;
    update();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {

    if(authRepo.isLoggedIn()) {
      authRepo.updateApiHeader();
    }

    return authRepo.isLoggedIn();
  }

  bool clearSharedData() {
    return authRepo.clearSharedData();
  }

  String getUserId() {
    return authRepo.getUserId();
  }

  List<String> getUserEntities() {
    // Simply return the cached entities, don't call update
    if (userEntities.isEmpty) {
      userEntities = authRepo.getUserEntities();
    }
    return userEntities;
  }
  
  // Method to clear user data on logout
  void clearUserData() {
    userEntities = [];
    selectedEntity = '';
    userName = '';
    _entitiesLoaded = false;
    update();
  }

  Future<void> saveUserDetail(UserModel userModel) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert UserModel to JSON string
    final String userJson = json.encode(userModel.toJson());

    // Save JSON string to SharedPreferences
    await prefs.setString('user', userJson);
    print("User saved to SharedPreferences");
  }

  Future<bool?> getPublicKeyXML() async {
    final response = await authRepo.getPublicKey();
    if (response != null && response.statusCode == 200) {
      getPublicKeyToJson = GetPublicKey.fromJson(response.body);
      update();
      return true;
    }

    return false;
  }

  /*Future<bool?> getAccessToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userName = sharedPreferences.getString(AppConstants.userName);

    if (userName == null) {
      return false;
    }

    final response = await authRepo.getAccessToken(userName);
    if (response != null && response.statusCode == 200) {

      try{
        String device_token = response.body[0]['device_token'];
        String user_status = response.body[0]['user_status'];

        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        String deviceId = '';
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        }
        else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? '';
        }

        if(user_status != "active" || device_token != deviceId) {
          Get.snackbar("Session timeout. Please login again.", isError: true);
          Get.find<AuthController>().clearSharedData();
          Get.offAllNamed(RouteHelper.getSignInRoute('splash'));
        }
        return true;
      } catch (e) {
        return false;
      }

    } else {
      // Get.snackbar(response?.body['error'].toString(), isError: true);
    }
    return false;
  }*/

  Future<UserModel?> getUserDetail() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch the JSON string
    final String? userJson = prefs.getString('user');

    if (userJson != null) {
      // Convert JSON string to UserModel
      final Map<String, dynamic> userMap = json.decode(userJson);
      return UserModel.fromJson(userMap);
    }

    print("No user found in SharedPreferences");
    return null;
  }

  Future<bool?> saveSelectedOperation(String chatId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(
        AppConstants.selectedOperation, chatId);
  }

  Future<String> getSelectedOperation() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(AppConstants.selectedOperation) ?? "";
  }

  Future<void> searchParcelDetail(
      String parcelNumber, DateTime toDate, DateTime fromDate) async {
    _hideKeyboard();
    parcelDetails = null;
    _isLoading = true;
    update();

    final response =
        await authRepo.getParcelDetail(parcelNumber, toDate, fromDate);

    if (response != null && response.statusCode == 200) {
      parcelDetails = ParcelDetailModel.fromJson(response.body);
    } else if (response != null && response.statusCode == 401) {
      clearSharedData();
      Get.snackbar("Error", "Your session is timed out. Please login again.",
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      Get.offAllNamed(RouteHelper.getSignInRoute('splash'));
    } else {
      try {
        var firstItem = response?.body[0];
        String message = firstItem["message"];
        Get.snackbar("Error", message, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      } catch (error) {
        Get.snackbar("Error", "Failed to parse response.", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }
    }

    _isLoading = false;
    update();
  }

  Future<void> validateParcel(String parcelNumber, DateTime toDate,
      DateTime fromDate, String reasonCode) async {
    _hideKeyboard();
    parcelDetails = null;
    _isLoading = true;
    update();

    final response = await authRepo.validateParcel(
        parcelNumber, toDate, fromDate, reasonCode);

    if (response != null && response.statusCode == 200) {
      print(response.body);

      // final data = jsonDecode(response.body);

      // 👇 Access the message
      String message = response.body['message'];
      Get.snackbar("Success", message, backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);

      if (Get.find<AuthController>().condition == "OK") {
        okCount.value++;
        update();
      } else {
        holdCount.value++;
        update();
      }
    } else if (response != null && response.statusCode == 401) {
      clearSharedData();
      Get.snackbar("Error", "Your session is timed out. Please login again.",
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      Get.offAllNamed(RouteHelper.getSignInRoute('splash'));
    } else {
      try {
        var firstItem = response?.body[0];
        String message = firstItem["message"];
        Get.snackbar("Error", message, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      } catch (error) {
        Get.snackbar("Error", "Failed to parse response.", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }
    }

    _isLoading = false;
    update();
  }

  Future<void> getReasonList() async {
    allReasonsList = [];
    _isLoading = true;
    update();

    final response =
    await authRepo.getReasonsList();

    if (response != null && response.statusCode == 200) {

      print(response.body);

      final List<dynamic> jsonList = response.body;

      for (var i = 0; i < jsonList.length; i++) {
        final item = jsonList[i];
        try {
          // ensure item is a map
          if (item is Map<String, dynamic>) {
            allReasonsList?.add(ReasonsListModel.fromJson(item));
          } else if (item is Map) {
            // sometimes it's a Map<dynamic, dynamic>
            allReasonsList?.add(ReasonsListModel.fromJson(Map<String, dynamic>.from(item)));
          } else {
            throw FormatException('Item is not a JSON object (map): ${item.runtimeType}');
          }
        } catch (e, st) {
          print('Error parsing item index $i:\n$item\nError: $e\nStack: $st');
          // optionally continue (skip bad item) or rethrow to stop
          // continue;
        }
      }

        filteredReasons = allReasonsList;

      print("✅ Loaded ${allReasonsList!.length} reasons");
    } else {
      print(response);
    }

    _isLoading = false;
    update();
  }

}
