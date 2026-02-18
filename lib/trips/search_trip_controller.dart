import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'search_trip_repo.dart';
import 'trip_results_model.dart';
import '../widgets/custom_snackbar.dart';
import 'search_trip_results_screen.dart';

class SearchTripController extends GetxController {
  final SearchTripRepo searchTripRepo;

  SearchTripController({required this.searchTripRepo});

  DateTime toDate = DateTime(
    DateTime.now().add(const Duration(days: 1)).year,
    DateTime.now().add(const Duration(days: 1)).month,
    DateTime.now().add(const Duration(days: 1)).day,
  );
  DateTime fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(const Duration(days: 30));
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TripResultsModel? tripData;

  void updateFromDate(DateTime date) {
    fromDate = date;
    update();
  }

  void updateToDate(DateTime date) {
    toDate = date;
    update();
  }

  Future<void> searchTrip(String trackingNumber) async {
    _isLoading = true;
    update();

    try {
      String toDateStr = toDate.toUtc().toIso8601String();
      String fromDateStr = fromDate.toUtc().toIso8601String();

      final response = await searchTripRepo.searchTrip(
        trackingNumber: trackingNumber,
        fromDate: fromDateStr,
        toDate: toDateStr,
      );

      if (response != null && response.statusCode == 200) {
        print("Trip search successful: ${response.body}");
        tripData = TripResultsModel.fromJson(response.body);
        update();
        
        // Navigate to results screen
        Get.to(() => const SearchTripResultsScreen());
        Get.snackbar("Success", "Trip found", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      } else {
        // For testing mock data, navigate anyway
        // print("Trip search failed or empty, navigating to mock results");
        // tripData = null; // Ensure it's null so mock data triggers
        // update();
        // Get.to(() => const SearchTripResultsScreen());
        

        // Original error handling
        String errorMessage = response?.bodyString ?? "Trip not found";
        try {
          if (response?.body is Map && response!.body.containsKey("message")) {
            errorMessage = response.body["message"];
          }
        } catch (e) {
          print("Error parsing error message: $e");
        }
        Get.snackbar("Error", errorMessage, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);

      }
    } catch (e) {
      print("Search trip error: $e");
      Get.snackbar("Error", "An error occurred during search", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    }

    _isLoading = false;
    update();
  }
}
