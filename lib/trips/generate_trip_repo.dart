import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../utils/client_api.dart';

class GenerateTripRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  GenerateTripRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response?> searchBoxes(List<String> trackingNumbers, String fromDate, String toDate) async {
    final Map<String, dynamic> body = {
      "createdOn": {
        "from": fromDate,
        "to": toDate
      },
      "trackingNumbers": trackingNumbers
    };
    
    print("GenerateTripRepo searchBoxes body: $body");

    return await apiClient.postData(AppConstants.searchUrl, body);
  }

  Future<Response?> generateTrip({
    required List<String> trackingNumbers,
    required String fromDate,
    required String toDate,
    required String estimatedDeliveryTime,
    required String truckId,
    String? note,
    String? entity,
  }) async {
    final Map<String, dynamic> body = {
      "createdOn": {
        "from": fromDate,
        "to": toDate
      },
      "entity": entity ?? sharedPreferences.getString(AppConstants.selectedOperation) ?? "DXB",
      "estimatedDeliveryTime": estimatedDeliveryTime,
      "note": note ?? "",
      "trackingNumbers": trackingNumbers,
      "truckId": truckId
    };
    
    print("GenerateTripRepo generateTrip body: $body");

    return await apiClient.postData('/api/v2/generate-trip', body);
  }
}
