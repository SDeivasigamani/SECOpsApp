import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:opsapp/trips/generate_trip_repo.dart';
import '../utils/api_checker.dart';
import '../destination_handling/destination_handling_model.dart';
import 'generate_trip_results_screen.dart';
import 'generate_trip_confirm_screen.dart';
import 'package:opsapp/utils/route_helper.dart';


class GenerateTripController extends GetxController {
  final GenerateTripRepo generateTripRepo;

  GenerateTripController({required this.generateTripRepo});

  final TextEditingController searchController = TextEditingController();

  DateTime toDate = DateTime(
    DateTime.now().add(const Duration(days: 1)).year,
    DateTime.now().add(const Duration(days: 1)).month,
    DateTime.now().add(const Duration(days: 1)).day,
  );
  DateTime fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(const Duration(days: 180));
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedFilter = "Past 1 month";
  String get selectedFilter => _selectedFilter;
  
  bool _isCustomDate = false;
  bool get isCustomDate => _isCustomDate;

  List<Items> searchResults = [];
  Map<String, bool> _selectedItems = {}; // Track selection by trackingNumber
  
  bool get isAllSelected => searchResults.isNotEmpty && searchResults.every((item) => _selectedItems[item.trackingNumber] == true);

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void updateDateRange(DateTime from, DateTime to) {
    fromDate = from;
    toDate = to;
    update();
  }
  
  void updateFilter(String filter, bool isCustom) {
    _selectedFilter = filter;
    _isCustomDate = isCustom;
    update();
  }

  void toggleAllSelection(bool? val) {
    for (var item in searchResults) {
      _selectedItems[item.trackingNumber ?? ''] = val ?? false;
    }
    update();
  }

  void toggleSelection(int index, bool? val) {
    if (index >= 0 && index < searchResults.length) {
      _selectedItems[searchResults[index].trackingNumber ?? ''] = val ?? false;
      update();
    }
  }
  
  bool isItemSelected(String? trackingNumber) {
    return _selectedItems[trackingNumber ?? ''] ?? false;
  }

  Future<void> search(String searchText, BuildContext context) async {
    if (searchText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter search text"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isLoading = true;
    update();

    try {
      List<String> trackingNumbers = searchText
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      String toDateStr = toDate.toUtc().toIso8601String();
      String fromDateStr = fromDate.toUtc().toIso8601String();


      final response = await generateTripRepo.searchBoxes(trackingNumbers, fromDateStr, toDateStr);

      if (response != null && response.statusCode == 200) {
        print("Search successful: ${response.body}");
        
        try {
          if (response.body is Map) {
            final resultModel = DestinationHandlingResultModel.fromJson(response.body);
            searchResults = resultModel.items ?? [];
            _selectedItems.clear();
            for (var item in searchResults) {
              _selectedItems[item.trackingNumber ?? ''] = false;
            }
          } else if (response.body is List) {
            searchResults = (response.body as List).map((e) => Items.fromJson(e)).toList();
            _selectedItems.clear();
            for (var item in searchResults) {
              _selectedItems[item.trackingNumber ?? ''] = false;
            }
          }
        } catch (e) {
          print("Error parsing search results: $e");
          searchResults = [];
        }

        Get.to(() => const GenerateTripResultsScreen());
        //Get.snackbar("Success", "Search successful", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      } else {
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
      print("Search error: $e");
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

  Future<void> generateTrip(BuildContext context) async {
    List<String> selectedBoxNumbers = searchResults
        .where((item) => _selectedItems[item.trackingNumber] == true)
        .map((item) => item.containerTrackingNumber ?? item.trackingNumber ?? '')
        .where((tn) => tn.isNotEmpty)
        .toList();

    if (selectedBoxNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one box"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to confirmation screen
    Get.to(() => const GenerateTripConfirmScreen());
  }

  Future<void> confirmGenerateTrip({
    required DateTime estimatedDeliveryTime,
    required String truckId,
    String? note,
    String? entity,
    required BuildContext context,
  }) async {
    List<String> selectedBoxNumbers = searchResults
        .where((item) => _selectedItems[item.trackingNumber] == true)
        .map((item) => item.trackingNumber ?? '')
        .where((tn) => tn.isNotEmpty)
        .toList();

    if (selectedBoxNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one box"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isLoading = true;
    update();

    try {
      String toDateStr = toDate.toUtc().toIso8601String();
      String fromDateStr = fromDate.toUtc().toIso8601String();
      String estimatedDeliveryTimeStr = estimatedDeliveryTime.toUtc().toIso8601String();

      final response = await generateTripRepo.generateTrip(
        trackingNumbers: selectedBoxNumbers,
        fromDate: fromDateStr,
        toDate: toDateStr,
        estimatedDeliveryTime: estimatedDeliveryTimeStr,
        truckId: truckId,
        note: note,
        entity: entity
      );

      if (response != null && response.statusCode == 200) {
        print("Trip generated successfully: ${response.body}");
        update();
        
        String tripId = "";
        try {
          if (response.body is Map) {
            // Priority: trip_number (from user example), then tripId
            tripId = (response.body['trip_number'] ?? response.body['tripId'] ?? "").toString();
          } else if (response.body is List && response.body.isNotEmpty) {
            // Fallback for list-based responses
            tripId = response.body[0]['message']?.toString().split(":").last.trim() ?? "";
          }
        } catch (e) {
          print("Error extracting tripId: $e");
        }

        // If tripId is empty, try to extract from response.bodyString if it contains "{trip_number: ...}"
        if (tripId.isEmpty && response.bodyString != null && response.bodyString!.contains("trip_number")) {
           try {
             // Simple regex to find trip_number value
             final match = RegExp(r"trip_number:\s*([^},]+)").firstMatch(response.bodyString!);
             if (match != null) {
               tripId = match.group(1)?.trim() ?? "";
             }
           } catch (_) {}
        }

        // If still empty, use a placeholder
        if (tripId.isEmpty) tripId = "TRP Generated";

        // Navigate to success screen instead of popping back
        Get.offNamed(RouteHelper.getGenerateTripSuccessScreen(), arguments: tripId);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Trip generated successfully: $tripId"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMessage = ApiChecker.getErrorMsg(response?.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Generate trip error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred while generating trip"),
          backgroundColor: Colors.red,
        ),
      );
    }

    _isLoading = false;
    update();
  }
}
