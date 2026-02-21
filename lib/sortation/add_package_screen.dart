import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:opsapp/sortation/repository/sortation_repo.dart';
import 'package:opsapp/utils/client_api.dart';
import 'package:opsapp/sortation/package_list_screen.dart';
import 'package:opsapp/sortation/model/container_detail_model.dart';
import '../widgets/custom_snackbar.dart';

class AddPackageScreen extends StatefulWidget {
  final String containerTrackingNumber;

  const AddPackageScreen({Key? key, required this.containerTrackingNumber}) : super(key: key);

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  final TextEditingController _packageController = TextEditingController();
  late SortationRepo _sortationRepo;
  int _totalScannedPackages = 0;
  bool _isLoading = false;

  DateTime _toDate = DateTime(
    DateTime.now().add(const Duration(days: 1)).year,
    DateTime.now().add(const Duration(days: 1)).month,
    DateTime.now().add(const Duration(days: 1)).day,
  );
  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(const Duration(days: 180));
  String _selectedFilter = "Past 1 month";
  bool _isCustomDate = false;

  @override
  void initState() {
    super.initState();
    _sortationRepo = SortationRepo(apiClient: Get.find<ApiClient>());
    _fetchContainerPackageCount(); // Fetch initial count
  }

  @override
  void dispose() {
    _packageController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';
    if (text.isNotEmpty) {
      setState(() {
        _packageController.text = text;
      });
    }
  }

  void _resetSearch() {
    setState(() {
      _packageController.clear();
    });
  }

  void _showDateFilterMenu(BuildContext context, Offset offset) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        const PopupMenuItem(value: "Past 1 month", child: Text("Past 1 month")),
        const PopupMenuItem(value: "Past 2 months", child: Text("Past 2 months")),
        const PopupMenuItem(value: "Past 1 year", child: Text("Past 1 year")),
        const PopupMenuItem(value: "Custom Dates", child: Text("Custom Dates")),
      ],
    );

    if (result == null) return;

    if (result == "Custom Dates") {
      setState(() {
        _isCustomDate = true;
        _selectedFilter = "Custom Dates";
      });
    } else {
      setState(() {
        _isCustomDate = false;
        _selectedFilter = result;

        _toDate = DateTime(
          DateTime.now().add(const Duration(days: 1)).year,
          DateTime.now().add(const Duration(days: 1)).month,
          DateTime.now().add(const Duration(days: 1)).day,
        );
        // Set fromDate based on selected filter
        if (result == "Past 1 month") {
          _fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(const Duration(days: 30));
        } else if (result == "Past 2 months") {
          _fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(const Duration(days: 60));
        } else if (result == "Past 1 year") {
          _fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(const Duration(days: 365));
        }
      });
      _fetchContainerPackageCount();
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: isFrom ? DateTime(2020) : _fromDate,
      lastDate: isFrom ? _toDate : DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
      _fetchContainerPackageCount();
    }
  }

  Future<void> _fetchContainerPackageCount() async {
    try {
      print("Fetching package count for container: ${widget.containerTrackingNumber}");
      Response response = await _sortationRepo.getOpenContainer(
        widget.containerTrackingNumber,
        "BAG",
        _fromDate,
        _toDate,
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        ContainerDetailModel containerDetail = ContainerDetailModel.fromJson(response.body);
        int packageCount = containerDetail.parcels?.length ?? 0;
        print("Package count from API: $packageCount");
        
        if (mounted) {
          setState(() {
            _totalScannedPackages = packageCount;
          });
          print("Updated total scanned packages to: $_totalScannedPackages");
        }
      } else {
        print("Failed to fetch container details: ${response.statusText}");
        if (mounted) {
          String errorMessage = "Failed to add package: ${response.statusText}";
          if (response.body != null) {
            try {
              if (response.body is List && response.body.isNotEmpty) {
                errorMessage = response.body[0]['message'] ?? errorMessage;
              } else if (response.body is Map) {
                errorMessage = response.body['message'] ?? errorMessage;
              }
            } catch (e) {
              print("Error parsing addResponse body: $e");
            }
          }
          Get.snackbar("Error", errorMessage, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
        }
      }
    } catch (e) {
      print("Error fetching container package count: $e");
      if (mounted) {
        Get.snackbar("Error", "Failed to refresh package count: $e", backgroundColor: Colors.red);
      }
    }
  }

  Future<void> _addPackage() async {
    String trackingNumber = _packageController.text.trim();
    
    // Validate tracking number is not empty
    if (trackingNumber.isEmpty) {
      Get.snackbar("Error", "Please enter a tracking number", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }
    
    // Validate tracking number length (between 11 and 50 characters)
    if (trackingNumber.length < 11) {
      Get.snackbar("Error", "Tracking number must be at least 11 characters long", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }
    
    if (trackingNumber.length > 50) {
      Get.snackbar("Error", "Tracking number must not exceed 50 characters", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Search for the package
      Response searchResponse = await _sortationRepo.searchPackages(
        [trackingNumber],
        _fromDate,
        _toDate,
      );

      if (searchResponse.statusCode == 200) {
        Response addResponse = await _sortationRepo.addToContainer(
          [trackingNumber],
          widget.containerTrackingNumber,
          _fromDate,
          _toDate,
        );

        if (addResponse.statusCode == 200) {
          // Add a small delay to ensure backend has processed the addition
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Refresh the package count from API
          await _fetchContainerPackageCount();
          
          if (mounted) {
            setState(() {
              _packageController.clear();
            });
          }
          Get.snackbar(
            "Success",
            "Package added successfully. Total packages: $_totalScannedPackages",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        } else {
          String errorMessage = "Failed to add package: ${addResponse.statusText}";
          if (addResponse.body != null) {
            try {
              if (addResponse.body is List && addResponse.body.isNotEmpty) {
                errorMessage = addResponse.body[0]['message'] ?? errorMessage;
              } else if (addResponse.body is Map) {
                errorMessage = addResponse.body['message'] ?? errorMessage;
              }
            } catch (e) {
              print("Error parsing addResponse body: $e");
            }
          }
          Get.snackbar("Error", errorMessage, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
        }
      } else {
        String errorMessage = "Package not found: ${searchResponse.statusText}";
        if (searchResponse.body != null) {
          try {
            if (searchResponse.body is List && searchResponse.body.isNotEmpty) {
              errorMessage = searchResponse.body[0]['message'] ?? errorMessage;
            } else if (searchResponse.body is Map) {
              errorMessage = searchResponse.body['message'] ?? errorMessage;
            }
          } catch (e) {
            print("Error parsing searchResponse body: $e");
          }
        }
        Get.snackbar("Error", errorMessage, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "An error occurred: $e", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Package",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _packageController,
                decoration: const InputDecoration(
                  hintText: "Enter Package or Reference numbers",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Paste and Reset row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _pasteFromClipboard,
                  child: const Text(
                    "Paste from clipboard",
                    style: TextStyle(
                      color: Colors.green,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.green,
                      height: 1.5,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _resetSearch,
                  child: const Text(
                    "Reset Search",
                    style: TextStyle(
                      color: Colors.green,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.green,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date Filter
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTapDown: (details) {
                  _showDateFilterMenu(context, details.globalPosition);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Date Filter",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.green,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_drop_down, color: Colors.green),
                  ],
                ),
              ),
            ),

            // Date Filters (Custom)
            if (_isCustomDate)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text("From"),
                        OutlinedButton(
                          onPressed: () => _pickDate(true),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueGrey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
                              const SizedBox(width: 8),
                              Text(
                                "${_fromDate.day}-${_fromDate.month}-${_fromDate.year}",
                                style: const TextStyle(color: Colors.black87, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        const Text("To"),
                        OutlinedButton(
                          onPressed: () => _pickDate(false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueGrey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
                              const SizedBox(width: 8),
                              Text(
                                "${_toDate.day}-${_toDate.month}-${_toDate.year}",
                                style: const TextStyle(color: Colors.black87, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Total Scanned Packages
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Scanned Package(s)",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$_totalScannedPackages",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _isLoading ? null : _addPackage,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Add",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      // Navigate to Package List screen
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PackageListScreen(
                            containerNumber: widget.containerTrackingNumber,
                          ),
                        ),
                      );
                      
                      // Refresh the package count when returning from PackageListScreen
                      _fetchContainerPackageCount();
                    },
                    child: const Text(
                      "End Scan",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
