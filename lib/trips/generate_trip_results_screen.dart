import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'generate_trip_controller.dart';

class GenerateTripResultsScreen extends StatefulWidget {
  const GenerateTripResultsScreen({super.key});

  @override
  State<GenerateTripResultsScreen> createState() => _GenerateTripResultsScreenState();
}

class _GenerateTripResultsScreenState extends State<GenerateTripResultsScreen> {
  final TextEditingController _filterController = TextEditingController();
  String _filterText = "";

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GenerateTripController>(builder: (controller) {
      final filteredResults = controller.searchResults.where((item) {
        if (_filterText.isEmpty) return true;
        final query = _filterText.toLowerCase();
        return (item.trackingNumber?.toLowerCase().contains(query) ?? false) ||
               (item.containerTrackingNumber?.toLowerCase().contains(query) ?? false) ||
               (item.status?.toLowerCase().contains(query) ?? false);
      }).toList();

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
            'Results',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            // Search Bar & Reset
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _filterController,
                      decoration: const InputDecoration(
                        hintText: "Search here",
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _filterText = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _filterController.clear();
                      setState(() {
                        _filterText = "";
                      });
                    },
                    child: const Text(
                      "Reset Search",
                      style: TextStyle(
                        color: Colors.green,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Header Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Checkbox(
                    value: controller.isAllSelected,
                    onChanged: (val) => controller.toggleAllSelection(val),
                    activeColor: Colors.blueGrey,
                  ),
                  const Expanded(
                    child: Text(
                      "Package #",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Text(
                    "Box #",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: filteredResults.isEmpty 
                ? const Center(child: Text("No results found"))
                : ListView.separated(
                    itemCount: filteredResults.length,
                    separatorBuilder: (ctx, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = filteredResults[index];
                      final mainIndex = controller.searchResults.indexOf(item);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: controller.isItemSelected(item.trackingNumber),
                              onChanged: (val) => controller.toggleSelection(mainIndex, val),
                              activeColor: Colors.blueGrey,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.trackingNumber ?? "-",
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.containerTrackingNumber ?? "-",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(item.status),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.status ?? "Unknown",
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),

            // Generate Trip Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () {
                          controller.generateTrip();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Generate Trip",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Color _getStatusColor(String? status) {
    if (status == 'Received') return const Color(0xFF2196F3);
    if (status == 'Cleared') return const Color(0xFF4DD0E1);
    return Colors.grey;
  }
}
