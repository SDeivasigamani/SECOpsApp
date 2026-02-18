import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../utils/client_api.dart';

class SearchTripRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  SearchTripRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response?> searchTrip({
    required String trackingNumber,
    required String fromDate,
    required String toDate,
    int pageIndex = 0,
    int pageSize = 50,
  }) async {
    final Map<String, dynamic> body = {
      "createdOn": {
        "from": fromDate,
        "to": toDate
      },
      "trackingNumber": trackingNumber,
      "pageIndex": pageIndex,
      "pageSize": pageSize
    };
    
    print("SearchTripRepo searchTrip body: $body");

    return await apiClient.postData('/api/v2/trips/search', body);
  }
}
