import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opsapp/sortation/parcel_scanner_screen.dart';
import 'package:opsapp/sortation/add_package_screen.dart';
import 'package:opsapp/search_parcel/barcode_scan_screen.dart';

import '../widgets/custom_snackbar.dart';
import 'create_box_screen.dart';
import 'update_box_screen.dart';

import 'package:get/get.dart';
import 'package:opsapp/sortation/model/container_model.dart';
import 'package:opsapp/sortation/model/container_detail_model.dart' as detail;
import 'package:opsapp/sortation/repository/sortation_repo.dart';
import 'package:opsapp/utils/client_api.dart';

class SortationScreen extends StatefulWidget {
  const SortationScreen({super.key});

  @override
  State<SortationScreen> createState() => _SortationScreenState();
}

class _SortationScreenState extends State<SortationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _filter = "Open";
  bool _isLoading = false;
  bool _isMoreLoading = false;
  List<Matches> _containers = [];
  late SortationRepo _sortationRepo;
  int _pageIndex = 1;
  final int _pageSize = 10;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState();
    _sortationRepo = SortationRepo(apiClient: Get.find<ApiClient>());
    _fetchContainers();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      _fetchContainers();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasNextPage && !_isLoading && !_isMoreLoading) {
        _fetchContainers(isLoadMore: true);
      }
    }
  }

  Future<void> _fetchContainers({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (mounted) {
        setState(() {
          _isMoreLoading = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _pageIndex = 1;
          _containers = [];
          _hasNextPage = true;
        });
      }
    }

    try {
      int pageToFetch = isLoadMore ? _pageIndex + 1 : _pageIndex;
      // Map filter to status: "Open" -> "draft", "Closed" -> "closed"
      String status = _filter == "Open" ? "draft" : "closed";
      Response response =
          await _sortationRepo.getContainers(pageToFetch, _pageSize, status);
      if (response.statusCode == 200) {
        ContainerModel model = ContainerModel.fromJson(response.body);
        List<Matches> newContainers = model.matches ?? [];

        if (newContainers.length < _pageSize) {
          _hasNextPage = false;
        }

        if (mounted) {
          setState(() {
            if (isLoadMore) {
              _containers.addAll(newContainers);
              _pageIndex++;
            } else {
              _containers = newContainers;
            }
          });
        }
      } else {
        Get.snackbar(
            "Error", "Failed to fetch containers: ${response.statusText}", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "An error occurred: $e", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isMoreLoading = false;
        });
      }
    }
  }

  Future<void> _searchContainer(String number) async {
    try {
      DateTime fromDate = DateTime(2020, 1, 16, 7, 25, 0);
      DateTime toDate = DateTime.now();

      Response response = await _sortationRepo.getOpenContainer(
          number, "BAG", fromDate, toDate);

      if (response.statusCode == 200) {
        detail.ContainerDetailModel containerDetail =
            detail.ContainerDetailModel.fromJson(response.body);
        
        // Map ContainerDetailModel to Matches
        Matches match = Matches(
          number: containerDetail.id,
          entity: containerDetail.entity,
          type: containerDetail.type,
          sortationRuleCode: containerDetail.sortationRuleCode,
          status: containerDetail.closedOn != null ? "Closed" : "Draft", // Map status
          weight: containerDetail.weight != null ? Weight(
            value: containerDetail.weight?.value?.toDouble(),
            unit: containerDetail.weight?.unit
          ) : null,
          dimensions: containerDetail.dimensions != null ? Dimensions(
            length: containerDetail.dimensions?.length?.toDouble(),
            width: containerDetail.dimensions?.width?.toDouble(),
            height: containerDetail.dimensions?.height?.toDouble(),
            unit: containerDetail.dimensions?.unit
          ) : null,
          shipper: containerDetail.shipper != null ? Shipper(
            name: containerDetail.shipper?.name,
            phones: containerDetail.shipper?.phones,
            emails: containerDetail.shipper?.emails,
            // Map other fields if necessary
          ) : null,
          consignee: containerDetail.receiver != null ? Shipper( // Map Receiver to Shipper
            name: containerDetail.receiver?.name,
            phones: containerDetail.receiver?.phones,
            emails: containerDetail.receiver?.emails,
             address: containerDetail.receiver?.country != null ? Address(
               country: containerDetail.receiver?.country,
               city: containerDetail.receiver?.city,
               state: containerDetail.receiver?.state,
               street: containerDetail.receiver?.street,
               postCode: containerDetail.receiver?.postCode,
             ) : null,
          ) : null,
          services: containerDetail.services?.cast<String>(),
        );

        if (mounted) {
          setState(() {
            _containers = [match];
            _hasNextPage = false; // Disable pagination for search result
          });
        }
      } else {
        Get.snackbar("Error", "Container not found: ${response.statusText}", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "An error occurred: $e", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    }
  }



  void _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _searchController.text = data.text!;
      });
    }
  }

  Future<void> _scanBarcode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onDetect: (barcode) {
            setState(() {
              _searchController.text = barcode;
            });
            _searchContainer(barcode);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sortation"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search box
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Enter Box Number",
                      labelStyle: const TextStyle(
                        color: Colors.green, // Label text color
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, size: 32, color: Colors.black),
                  onPressed: () {
                    String boxNumber = _searchController.text.trim();

                    // Validate box number length
                    // if (boxNumber.length < 5) {
                    //   Get.snackbar(
                    //       "Box number must be more than 5 characters",
                    //       isError: true);
                    //   return;
                    // }

                    if (boxNumber.isNotEmpty) {
                      _searchContainer(boxNumber);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Filter dropdown + Reset Search
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _fetchContainers(); // Reset search and fetch initial
                  },
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
                // Filter dropdown
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: "Open", child: Text("Open")),
                    DropdownMenuItem(value: "Closed", child: Text("Closed")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filter = value!;
                    });
                    // Refresh containers with new filter
                    _fetchContainers();
                  },
                ),
              ],
            ),
            const Row(
              children: [
                Expanded(flex: 4, child: Text("Box ref number#", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text("Entity", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Destination", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )),
              ],
            ),
            const Divider(),

            // List of boxes
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _containers.isEmpty
                      ? const Center(child: Text("No containers found"))
                      : RefreshIndicator(
                          onRefresh: () async {
                            await _fetchContainers();
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                _containers.length + (_isMoreLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _containers.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }

                              final container = _containers[index];

                              // Search filter - Note: Client-side filtering with pagination is tricky.
                              // Ideally search should be server-side. For now keeping as is but it might hide items.
                              if (_searchController.text.isNotEmpty &&
                                  !(container.number?.toLowerCase().contains(
                                          _searchController.text
                                              .toLowerCase()) ??
                                      false)) {
                                return const SizedBox.shrink();
                              }

                              String destination = "-";
                              if (container.consignee?.address != null) {
                                destination =
                                    "${container.consignee!.address!.city ?? ''}, ${container.consignee!.address!.country ?? ''}";
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: InkWell(
                                  onTap: () async {
                                    // Navigate to Update Box screen
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => UpdateBoxScreen(
                                          container: container,
                                        ),
                                      ),
                                    );
                                    // Refresh the list after returning from update
                                    _fetchContainers();
                                  },
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(container.number ?? "-"),
                                              SizedBox(height: 24,)
                                            ],
                                          )),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(container.entity ?? "-"),
                                              SizedBox(height: 24,)
                                            ],
                                          )),
                                      // Expanded(flex: 3, child: Text(destination)),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(destination),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  if (container.services?.contains("COD") ?? false)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: const Text(
                                                        "COD",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      container.status ==
                                                              "Draft"
                                                          ? "Open"
                                                          : "Closed",
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () async {
                      await Navigator.of(context).push<String>(
                        MaterialPageRoute(
                            builder: (_) => const CreateBoxScreen()),
                      );
                      // Refresh the list after returning from create box
                      _fetchContainers();
                    },
                    child: const Text("Create Box"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () async {
                      final result = await Navigator.of(context).push<String>(
                        MaterialPageRoute(
                            builder: (_) => const ParcelScannerPage()),
                      );
                      if (result != null && result.isNotEmpty) {
                        setState(() {
                          _searchController.text = result;
                        });
                        _searchContainer(result);
                      }
                    },
                    child: const Text("Add Parcels"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
