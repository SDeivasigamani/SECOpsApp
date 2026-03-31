import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'search_trip_repo.dart';
import 'trip_results_model.dart';
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
  
  final TextEditingController resultsSearchController = TextEditingController();
  String _resultsSearchText = "";
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TripResultsModel? tripData;

  @override
  void onInit() {
    super.onInit();
    resultsSearchController.addListener(() {
      _resultsSearchText = resultsSearchController.text.toLowerCase();
      update();
    });
  }

  List<Matches> get filteredTrips {
    final trips = tripData?.matches ?? [];
    if (_resultsSearchText.isEmpty) return trips;
    return trips.where((trip) {
      return (trip.id?.toLowerCase().contains(_resultsSearchText) ?? false) ||
             (trip.truckId?.toLowerCase().contains(_resultsSearchText) ?? false) ||
             (trip.note?.toLowerCase().contains(_resultsSearchText) ?? false) ||
             (trip.trackingNumbers?.any((tn) => tn.toLowerCase().contains(_resultsSearchText)) ?? false);
    }).toList();
  }

  void updateFromDate(DateTime date) {
    fromDate = date;
    update();
  }

  void updateToDate(DateTime date) {
    toDate = date;
    update();
  }

  Future<void> searchTrip(String trackingNumber, BuildContext context) async {
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
        // Get.snackbar("Success", "Trip found", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      } else {
        // For testing mock data, navigate anyway
        // print("Trip search failed or empty, navigating to mock results");
        // tripData = null; // Ensure it's null so mock data triggers
        // update();
        // Get.to(() => const SearchTripResultsScreen());
        

        // Original error handling
        String errorMessage = "Container not found: ${response?.statusText}";
        if (response?.body != null) {
          try {
            if (response?.body is List && response?.body.isNotEmpty) {
              errorMessage = response?.body[0]['message'] ?? errorMessage;
            } else if (response?.body is Map) {
              errorMessage = response?.body['message'] ?? errorMessage;
            }
          } catch (e) {
            print("Error parsing searchResponse body: $e");
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Search trip error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred during search"),
          backgroundColor: Colors.red,
        ),
      );
    }

    _isLoading = false;
    update();
  }

  @override
  void onClose() {
    resultsSearchController.dispose();
    super.onClose();
  }
}
