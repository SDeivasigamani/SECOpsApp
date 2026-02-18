import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../utils/client_api.dart';

class DestinationHandlingRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  DestinationHandlingRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response?> search(List<String> trackingNumbers, String fromDate, String toDate) async {
    final Map<String, dynamic> body = {
      "createdOn": {
        "from": fromDate,
        "to": toDate
      },
      "trackingNumbers": trackingNumbers
    };
    
    print("DestinationHandlingRepo search body: $body");

    return await apiClient.postData(AppConstants.searchUrl, body);
  }

  Future<Response?> getDestinationTraces() async {
    return await apiClient.getData(AppConstants.destinationTracesUrl);
  }

  Future<Response?> updatePackages({
    required List<String> trackingNumbers,
    required String reasonCode,
    required String fromDate,
    required String toDate,
    String? entity,
  }) async {
    final Map<String, dynamic> body = {
      "trackingNumbers": trackingNumbers,
      "arrSelectedBoxes": null,
      "arrparcels": null,
      "reasonCode": reasonCode,
      "createdOn": {
        "from": fromDate,
        "to": toDate
      },
      "entity": entity ?? sharedPreferences.getString(AppConstants.selectedOperation) ?? "DXB"
    };
    
    print("DestinationHandlingRepo updatePackages body: $body");

    return await apiClient.postData(AppConstants.parcelUpdateUrl, body);
  }
}
