import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:opsapp/sortation/model/container_detail_model.dart';
import 'package:opsapp/sortation/repository/sortation_repo.dart';
import 'package:opsapp/utils/client_api.dart';
import 'package:opsapp/sortation/box_details_preview_screen.dart';

class PackageListScreen extends StatefulWidget {
  final String containerNumber;

  const PackageListScreen({Key? key, required this.containerNumber}) : super(key: key);

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late SortationRepo _sortationRepo;
  bool _isLoading = false;
  ContainerDetailModel? _containerDetail;
  List<dynamic> _filteredParcels = [];

  @override
  void initState() {
    super.initState();
    _sortationRepo = SortationRepo(apiClient: Get.find<ApiClient>());
    _fetchContainerDetails();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchContainerDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
      DateTime toDate = DateTime.now().add(const Duration(days: 1));

      Response response = await _sortationRepo.getOpenContainer(
        widget.containerNumber,
        "BAG",
        fromDate,
        toDate,
      );

      if (response.statusCode == 200) {
        setState(() {
          _containerDetail = ContainerDetailModel.fromJson(response.body);
          _filteredParcels = _containerDetail?.parcels ?? [];
        });
      } else {
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
    } catch (e) {
      print(e);
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterParcels(String query) {
    if (_containerDetail == null) return;

    setState(() {
      if (query.isEmpty) {
        _filteredParcels = _containerDetail!.parcels ?? [];
      } else {
        _filteredParcels = (_containerDetail!.parcels ?? []).where((parcel) {
          // Assuming parcel is a Map or has a tracking number field
          String parcelNumber = parcel.toString().toLowerCase();
          return parcelNumber.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _resetSearch() {
    setState(() {
      _searchController.clear();
      _filteredParcels = _containerDetail?.parcels ?? [];
    });
  }

  String _calculateTotalWeight() {
    double totalWeight = 0.0;
    for (var parcel in _filteredParcels) {
      if (parcel is Map<String, dynamic>) {
        if (parcel['weight'] != null && parcel['weight']['value'] != null) {
          totalWeight += (parcel['weight']['value'] as num).toDouble();
        }
      }
    }
    // Round to 2 decimal places and remove unnecessary trailing zeros
    return "${totalWeight.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")}kg";
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
        title: Text(
          "Box #${widget.containerNumber}",
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search here",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: _filterParcels,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Reset Search button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
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
                  ),

                  const SizedBox(height: 16),

                  // Package count and weight row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total no of Package(s):",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_filteredParcels.length}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Total Weight:",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _calculateTotalWeight(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Table headers
                  const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Package #",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Destination Country",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  // Packages list
                  Expanded(
                    child: _filteredParcels.isEmpty
                        ? const Center(
                            child: Text(
                              "No packages found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredParcels.length,
                            itemBuilder: (context, index) {
                              final parcel = _filteredParcels[index];
                              
                              // Extract tracking number and destination
                              String trackingNumber = "N/A";
                              String destination = "N/A";
                              
                              if (parcel is Map<String, dynamic>) {
                                trackingNumber = parcel['id']?.toString() ?? 
                                                parcel['trackingNumber']?.toString() ?? 
                                                parcel['number']?.toString() ?? 
                                                "N/A";
                                
                                // Try to get destination from receiver or consignee
                                if (parcel['receiver'] != null) {
                                  destination = "${parcel['receiver']['city'] ?? ''}, ${parcel['receiver']['country'] ?? ''}";
                                } else if (parcel['consignee'] != null) {
                                  destination = "${parcel['consignee']['city'] ?? ''}, ${parcel['consignee']['country'] ?? ''}";
                                }
                                
                                // Clean up destination if empty
                                if (destination == ", " || destination.trim().isEmpty) {
                                  destination = "STD | a Receiver City, AE";
                                }
                              } else {
                                trackingNumber = parcel.toString();
                                destination = "STD | a Receiver City, AE";
                              }

                              return Dismissible(
                                key: Key(trackingNumber + index.toString()),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  // Show confirmation dialog
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Package'),
                                      content: Text('Are you sure you want to delete package $trackingNumber?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) async {
                                  // Extract scheme from parcel data
                                  String scheme = "shipamall"; // default
                                  if (parcel is Map<String, dynamic> && parcel['scheme'] != null) {
                                    scheme = parcel['scheme'].toString();
                                  }

                                  // Show loading
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    // Call API to remove parcel
                                    Response response = await _sortationRepo.removeParcels(
                                      trackingNumber: trackingNumber,
                                      scheme: scheme,
                                      containerNumber: widget.containerNumber,
                                    );

                                    if (response.statusCode == 200) {
                                      // Remove the package from the list
                                      setState(() {
                                        _filteredParcels.removeAt(index);
                                        // Also remove from the original container detail
                                        if (_containerDetail?.parcels != null) {
                                          _containerDetail!.parcels!.remove(parcel);
                                        }
                                        _isLoading = false;
                                      });

                                      // Show success snackbar using Get.snackbar
                                      Get.snackbar("Success", 'Package $trackingNumber deleted successfully', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
                                    } else {
                                      // API call failed
                                      setState(() {
                                        _isLoading = false;
                                      });

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
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    
                                    print("Error deleting package: $e");
                                    Get.snackbar(
                                      "Error",
                                      "An error occurred while deleting: $e",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP,
                                    );
                                  }
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          trackingNumber,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          destination,
                                          style: const TextStyle(fontSize: 12),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        if (_containerDetail != null) {
                          // Show box details preview as bottom sheet
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => BoxDetailsPreviewScreen(
                              containerDetail: _containerDetail!,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Confirm",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
