import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:opsapp/destination_handling/destination_handling_repo.dart';
import '../utils/api_checker.dart';
import '../widgets/custom_snackbar.dart';
import 'destination_handling_model.dart';
import 'destination_handling_results_screen.dart';
import '../parcel_inbound/model/reasons_list_model.dart';

class DestinationHandlingController extends GetxController {
  final DestinationHandlingRepo destinationHandlingRepo;

  DestinationHandlingController({required this.destinationHandlingRepo});

  final TextEditingController searchController = TextEditingController();

  DateTime toDate = DateTime(
    DateTime.now().add(const Duration(days: 1)).year,
    DateTime.now().add(const Duration(days: 1)).month,
    DateTime.now().add(const Duration(days: 1)).day,
  );
  DateTime fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(const Duration(days: 30));
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedFilter = "Past 1 month";
  String get selectedFilter => _selectedFilter;
  
  bool _isCustomDate = false;
  bool get isCustomDate => _isCustomDate;

  List<Items> searchResults = [];
  Map<String, bool> _selectedItems = {}; // Track selection by trackingNumber
  
  bool get isAllSelected => searchResults.isNotEmpty && searchResults.every((item) => _selectedItems[item.trackingNumber] == true);

  // Reasons management
  List<ReasonsListModel>? allReasonsList;
  List<ReasonsListModel>? filteredReasons;
  String? selectedReason;

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

  Future<void> search(String searchText) async {
    if (searchText.trim().isEmpty) {
      Get.snackbar("Error", "Please enter search text", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    _isLoading = true;
    update();

    try {
      // Split by comma or newline if multiple numbers are entered
      List<String> trackingNumbers = searchText.split(RegExp(r'[,\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      
      if (trackingNumbers.isEmpty) {
         Get.snackbar("Error", "Invalid search text", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
         _isLoading = false;
         update();
         return;
      }

      String toDateStr = toDate.toUtc().toIso8601String();
      String fromDateStr = fromDate.toUtc().toIso8601String();




    final response = await destinationHandlingRepo.search(trackingNumbers, fromDateStr, toDateStr);

      if (response != null && response.statusCode == 200) {
        print("Search successful: ${response.body}");
        
        // Parse results - the response should be a DestinationHandlingResultModel
        try {
          if (response.body is Map) {
            final resultModel = DestinationHandlingResultModel.fromJson(response.body);
            searchResults = resultModel.items ?? [];
            // Initialize selection state for all items
            _selectedItems.clear();
            for (var item in searchResults) {
              _selectedItems[item.trackingNumber ?? ''] = false;
            }
          } else if (response.body is List) {
            // If it's a list, assume it's a list of items
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

        Get.to(() => const DestinationHandlingResultsScreen());
        Get.snackbar("Success", "Search successful", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      } else {
        String errorMessage = ApiChecker.getErrorMsg(response?.body);
        Get.snackbar("Error", errorMessage, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      print("Search error: $e");
      Get.snackbar("Error", "An error occurred during search", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    }

    _isLoading = false;
    update();
  }

  Future<void> loadDestinationReasons() async {
    try {
      final response = await destinationHandlingRepo.getDestinationTraces();
      
      if (response != null && response.statusCode == 200) {
        allReasonsList = [];
        if (response.body is List) {
          for (var item in response.body) {
            try {
              allReasonsList?.add(ReasonsListModel.fromJson(item));
            } catch (e) {
              allReasonsList?.add(ReasonsListModel.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
        filteredReasons = allReasonsList;
        update();
      }
    } catch (e) {
      print("Error loading destination reasons: $e");
    }
  }

  Future<void> updateSelectedPackages(String reasonCode) async {
    // Get selected tracking numbers
    List<String> selectedTrackingNumbers = searchResults
        .where((item) => _selectedItems[item.trackingNumber] == true)
        .map((item) => item.trackingNumber ?? '')
        .where((tn) => tn.isNotEmpty)
        .toList();

    if (selectedTrackingNumbers.isEmpty) {
      Get.snackbar("Error", "Please select at least one package", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    _isLoading = true;
    update();

    try {
      String toDateStr = toDate.toUtc().toIso8601String();
      String fromDateStr = fromDate.toUtc().toIso8601String();

      final response = await destinationHandlingRepo.updatePackages(
        trackingNumbers: selectedTrackingNumbers,
        reasonCode: reasonCode,
        fromDate: fromDateStr,
        toDate: toDateStr,
      );

      if (response != null && response.statusCode == 200) {
        print("Update successful: ${response.body}");
        Get.snackbar("Success", "Packages updated successfully", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
        // Clear selection after successful update
        _selectedItems.clear();
        selectedReason = null;
        update();
      } else {
        String errorMessage = ApiChecker.getErrorMsg(response?.body);
        Get.snackbar("Error", errorMessage, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      print("Update error: $e");
      Get.snackbar("Error", "An error occurred during update", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    }

    _isLoading = false;
    update();
  }
}
