import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'destination_handling_controller.dart';
import 'destination_handling_model.dart';
import 'select_reason_screen.dart';

class DestinationHandlingResultsScreen extends StatefulWidget {
  const DestinationHandlingResultsScreen({super.key});

  @override
  State<DestinationHandlingResultsScreen> createState() => _DestinationHandlingResultsScreenState();
}

class _DestinationHandlingResultsScreenState extends State<DestinationHandlingResultsScreen> {
  final TextEditingController _filterController = TextEditingController();
  String _filterText = "";

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DestinationHandlingController>(builder: (controller) {
      // Filter results based on local search text
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Checkbox(
                    value: controller.isAllSelected,
                    onChanged: (val) => controller.toggleAllSelection(val),
                    activeColor: Colors.blueGrey,
                  ),
                  const Text("Package #", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Text("Box #", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const Divider(),

            // List
            Expanded(
              child: filteredResults.isEmpty 
                ? const Center(child: Text("No results found"))
                : ListView.separated(
                    itemCount: filteredResults.length,
                    separatorBuilder: (ctx, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = filteredResults[index];
                      // Find the actual index in the main list to update selection correctly
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

            // Proceed Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showGeneralUpdatesDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Proceed',
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

  void _showGeneralUpdatesDialog(BuildContext context) {
    final controller = Get.find<DestinationHandlingController>();
    
    // Check if any selected item is a BOX
    bool hasBoxSelected = controller.searchResults.any((item) => 
      controller.isItemSelected(item.trackingNumber) && item.type == 2 // type 2 is BOX
    );

    // Build list of available actions
    List<Map<String, dynamic>> actions = [];
    
    // Only show these actions if no BOX is selected
    if (!hasBoxSelected) {
      actions.addAll([
        {
          'icon': Icons.output,
          'label': 'Scan Out',
          'actionType': 'Scan Out',
        },
        {
          'icon': Icons.input,
          'label': 'Scan In',
          'actionType': 'Scan In',
        },
        {
          'icon': Icons.remove_circle_outline,
          'label': 'Remove Package',
          'actionType': 'Remove Package',
        },
        {
          'icon': Icons.add_circle_outline,
          'label': 'Add Package',
          'actionType': 'Add Package',
        },
      ]);
    }
    
    // Always show Hold and Remove Hold
    actions.addAll([
      {
        'icon': Icons.pan_tool_outlined,
        'label': 'Hold',
        'actionType': 'Hold',
      },
      {
        'icon': Icons.remove_circle,
        'label': 'Remove Hold',
        'actionType': 'Remove Hold',
      },
    ]);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        int? selectedActionIndex;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Title / Confirmation Button
                  GestureDetector(
                    onTap: () {
                      if (selectedActionIndex != null) {
                        Navigator.pop(context);
                        final action = actions[selectedActionIndex!];
                        Get.to(() => SelectReasonScreen(actionType: action['actionType']));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedActionIndex != null ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'General Updates',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Action Buttons Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: actions.length,
                    itemBuilder: (context, index) {
                      final action = actions[index];
                      final isSelected = selectedActionIndex == index;
                      
                      return _buildActionButton(
                        icon: action['icon'],
                        label: action['label'],
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedActionIndex = index;
                          });
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: 20, 
              color: isSelected ? Colors.green : Colors.grey.shade700
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.green : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == 'Received') return const Color(0xFF2196F3); // Blue
    if (status == 'Cleared') return const Color(0xFF4DD0E1); // Cyan
    return Colors.grey;
  }
}

