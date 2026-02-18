import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'destination_handling_controller.dart';
import 'package:opsapp/utils/route_helper.dart';

class SelectReasonScreen extends StatefulWidget {
  final String actionType; // e.g., "Scan Out", "Hold", etc.
  
  const SelectReasonScreen({super.key, required this.actionType});

  @override
  State<SelectReasonScreen> createState() => _SelectReasonScreenState();
}

class _SelectReasonScreenState extends State<SelectReasonScreen> {
  final TextEditingController _searchController = TextEditingController();
  final controller = Get.find<DestinationHandlingController>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterReasons);
    _loadReasons();
  }

  Future<void> _loadReasons() async {
    await controller.loadDestinationReasons();
  }

  void _filterReasons() {
    final query = _searchController.text.toLowerCase();

    controller.filteredReasons = controller.allReasonsList
        ?.where((reason) =>
            reason.title != null &&
            reason.title!.toLowerCase().contains(query))
        .toList();
    controller.update();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Select Reason',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: GetBuilder<DestinationHandlingController>(
        builder: (controller) {
          final isLoading = controller.allReasonsList == null;
          final filteredReasons = controller.filteredReasons ?? [];

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search here",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // Reason Grid
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.green))
                    : filteredReasons.isEmpty
                        ? const Center(child: Text("No reasons found"))
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 2.2,
                              ),
                              itemCount: filteredReasons.length,
                              itemBuilder: (context, index) {
                                final reason = filteredReasons[index];
                                final isSelected = controller.selectedReason == reason.title;
                                
                                return GestureDetector(
                                  onTap: () {
                                    controller.selectedReason = reason.title;
                                    controller.update();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.green : Colors.white,
                                      border: Border.all(
                                        color: isSelected ? Colors.green : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        reason.title ?? "",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),

              // Confirm Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.selectedReason == null
                        ? null
                        : () async {
                            // Get the reason code from the selected reason
                            final selectedReasonModel = controller.filteredReasons?.firstWhere(
                              (r) => r.title == controller.selectedReason,
                              orElse: () => controller.allReasonsList!.first,
                            );
                            
                            if (selectedReasonModel?.code != null) {
                              await controller.updateSelectedPackages(selectedReasonModel!.code!);
                              // Navigate to Home screen after successful update
                              Get.offAllNamed(RouteHelper.getUsersHome());
                            } else {
                              Get.snackbar(
                                'Error',
                                'Reason code not found',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: controller.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Confirm',
                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
