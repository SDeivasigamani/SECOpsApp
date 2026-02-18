import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:path/path.dart';
import 'package:opsapp/utils/route_helper.dart';
import 'package:opsapp/widgets/custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:opsapp/utils/config.dart';
import 'package:opsapp/login/auth_controller.dart';

import '../common_model/errors_model.dart';
import 'app_constants.dart';

class ApiClient extends GetxService {
  final String? appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 30;

  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);

    ///pick zone id to update header
    initialHeader();

    // postUpdateHeader(token);
  }

  void initialHeader() {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'AndroidVersionCode': '14',
      'AndroidVersionName': '3.2'
    };
  }

  void postUpdateHeader(String? token) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
      'AndroidVersionCode': '14',
      'AndroidVersionName': '3.2'
    };
  }


  Future<Response> getData(String uri, {Map<String, dynamic>? query, Map<String, String>? headers}) async {

    print(appBaseUrl! + uri);
    print(headers ?? _mainHeaders);

    try {
      http.Response response = await http.get(
        Uri.parse(appBaseUrl! + uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
     // printLog("-----getData response: ${response.body}");
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    print(appBaseUrl! + uri);
    print(headers ?? _mainHeaders);
    print(jsonEncode(body));

    http.Response response = await http.post(
      Uri.parse(appBaseUrl! + uri),
      body: jsonEncode(body),
      headers: headers ?? _mainHeaders,
    ).timeout(Duration(seconds: timeoutInSeconds));
    try {
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartDataConversation(
    String? uri,
    File file,
    String receiverId,
  ) async {
    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(appBaseUrl! + uri!));
    request.headers.addAll(_mainHeaders);

    request.fields['receiver_id'] = receiverId;
    var stream = http.ByteStream(file.openRead())..cast();
    var length = await file.length();
    var multipartFile = http.MultipartFile('file', stream, length,
        filename: basename(file.path));
    request.files.add(multipartFile);
    final data = await request.send();

    http.Response response = await http.Response.fromStream(data);
    return handleResponse(response, uri);
  }

  //Map<String, String> body, List<MultipartBody>? multipartBody,

  Future<Response> postMultipartData(
      String? uri,
      Map<String, String> body,
      List<XFile>? selectedFiles,
      {Map<String, String>? headers}) async {
    try {
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(appBaseUrl! + uri!));
      request.headers.addAll(headers ?? _mainHeaders);

      // if(otherFile != null) {
      //   Uint8List list = await otherFile.readAsBytes();
      //   var part = http.MultipartFile('submitted_file', otherFile.readAsBytes().asStream(), list.length, filename: basename(otherFile.path));
      //   request.files.add(part);
      // }
      //
      // if(multipartBody != null){
      //   for (MultipartBody multipart in multipartBody) {
      //     File file = File(multipart.file.path);
      //     request.files.add(http.MultipartFile(
      //       multipart.key!,
      //       file.readAsBytes().asStream(),
      //       file.lengthSync(),
      //       filename: file.path.split('/').last,
      //     ));
      //   }
      // }

      for (XFile file in selectedFiles!) {

        Uint8List list = await file.readAsBytes();
        var part = http.MultipartFile('image[]', file.readAsBytes().asStream(), list.length, filename: basename(file.path));
        request.files.add(part);
      }

      request.fields.addAll(body);
      http.Response response =
          await http.Response.fromStream(await request.send());
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String? uri, dynamic body,
      {Map<String, String>? headers}) async {
    try {
      http.Response response = await http.put(
        Uri.parse(appBaseUrl! + uri!),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String? uri,
      {Map<String, String>? headers}) async {
    try {
      http.Response response = await http.delete(
        Uri.parse(appBaseUrl! + uri!),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(http.Response response, String? uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      //
    }
    
    // Handle 403 Unauthorized error
    if (response.statusCode == 403 || response.statusCode == 401) {
      _handle403Error();
      return Response(
        statusCode: 403,
        statusText: 'Unauthorized - Please login again',
      );
    }
    
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      if (response0.body.toString().startsWith('{response_code:')) {
        ErrorsModel errorResponse = ErrorsModel.fromJson(response0.body);
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: errorResponse.responseCode);
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: response0.body['message']);
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    }
    if (foundation.kDebugMode) {
      // debugPrint('====> API Response: [${response0.statusCode}] $uri\n${response0.body}');
    }
    return response0;
  }
  
  void _handle403Error() {
    // Clear token from shared preferences
    sharedPreferences.remove(AppConstants.token);
    sharedPreferences.remove(AppConstants.entities);
    sharedPreferences.remove(AppConstants.userId);
    sharedPreferences.remove(AppConstants.userName);
    
    // Clear token from memory
    token = null;
    initialHeader();
    
    // Clear AuthController user data
    try {
      Get.find<AuthController>().clearUserData();
    } catch (e) {
      print('AuthController not found: $e');
    }
    
    // Show error message
    Get.snackbar("Error", 'Session expired. Please login again.', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    
    // Navigate to login screen
    Get.offAllNamed('/login');
  }
}

class MultipartBody {
  String? key;
  XFile file;

  MultipartBody(this.key, this.file);
}
