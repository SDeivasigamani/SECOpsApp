import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'destination_handling_controller.dart';

class DestinationHandlingSearchScreen extends StatelessWidget {
  const DestinationHandlingSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DestinationHandlingController>(builder: (controller) {
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
            'Destination Handling',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
              onPressed: () {
                // Navigate back to scanner
                Get.back();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter Box, Package or Reference numbers",
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                    TextField(
                      controller: controller.searchController,
                      maxLines: null, // Allow multiple lines
                      minLines: 2,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      onChanged: (val) => controller.update(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Paste & Reset
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      final text = data?.text ?? '';

                      if (text.isNotEmpty) {
                        String current = controller.searchController.text;
                        if (current.isNotEmpty) {
                           controller.searchController.text = "$current\n$text";
                        } else {
                           controller.searchController.text = text;
                        }
                        // Set selection to end
                        controller.searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.searchController.text.length),
                        );
                        controller.update();
                      }
                    },
                    child: const Text(
                      'Paste from clipboard',
                      style: TextStyle(
                        color: Colors.green,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.searchController.clear();
                      controller.update();
                    },
                    child: const Text(
                      'Reset Search',
                      style: TextStyle(
                        color: Colors.green,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Date Filter Label
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTapDown: (details) {
                    _showDateFilterMenu(context, details.globalPosition, controller);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Date Filter',
                        style: TextStyle(
                          color: Colors.green,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.green),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              // Date Pickers
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      context, 
                      "From", 
                      controller.fromDate, 
                      () => _pickDate(context, controller, true)
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      context, 
                      "To", 
                      controller.toDate, 
                      () => _pickDate(context, controller, false)
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Search Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.searchController.text.trim().isEmpty || controller.isLoading
                      ? null
                      : () {
                          if (controller.searchController.text.length <= 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Search text must be more than 5 characters"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          controller.search(controller.searchController.text);
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
                          'Search',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime date, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${date.day.toString().padLeft(2, '0')} ${date.month.toString().padLeft(2, '0')} ${date.year}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DestinationHandlingController controller, bool isFrom) async {
    DateTime initial = isFrom ? controller.fromDate : controller.toDate;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isFrom ? DateTime(2020) : controller.fromDate,
      lastDate: isFrom ? controller.toDate : DateTime(2035),
    );
    if (picked != null) {
      if (isFrom) {
        controller.updateDateRange(picked, controller.toDate);
      } else {
        controller.updateDateRange(controller.fromDate, picked);
      }
    }
  }

  void _showDateFilterMenu(BuildContext context, Offset offset, DestinationHandlingController controller) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(value: "Past 1 month", child: Text("Past 1 month")),
        PopupMenuItem(value: "Past 2 months", child: Text("Past 2 months")),
        PopupMenuItem(value: "Past 1 year", child: Text("Past 1 year")),
        PopupMenuItem(value: "Custom Dates", child: Text("Custom Dates")),
      ],
    );

    if (result == null) return;

    if (result == "Custom Dates") {
      controller.updateFilter("Custom Dates", true);
    } else {
      controller.updateFilter(result, false);
      
      DateTime now = DateTime.now();
      DateTime from;
      if (result == "Past 1 month") {
        from = now.subtract(const Duration(days: 30));
      } else if (result == "Past 2 months") {
        from = now.subtract(const Duration(days: 60));
      } else {
        from = now.subtract(const Duration(days: 365));
      }
      controller.updateDateRange(from, now);
    }
  }
}
