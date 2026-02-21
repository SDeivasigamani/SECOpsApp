import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'generate_trip_controller.dart';

class GenerateTripScreen extends StatefulWidget {
  const GenerateTripScreen({Key? key}) : super(key: key);

  @override
  State<GenerateTripScreen> createState() => _GenerateTripScreenState();
}

class _GenerateTripScreenState extends State<GenerateTripScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  String? _lastScannedCode;
  DateTime? _lastScanTime;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.isNotEmpty ? (capture.barcodes.first.rawValue ?? '') : '';
    if (code.isEmpty) return;

    final now = DateTime.now();
    if (_lastScannedCode == code && _lastScanTime != null && now.difference(_lastScanTime!) < const Duration(seconds: 2)) {
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = now;

    final controller = Get.find<GenerateTripController>();
    String currentText = controller.searchController.text;
    
    List<String> existing = currentText.split(RegExp(r'[,\n]')).map((e) => e.trim()).toList();
    if (!existing.contains(code)) {
      if (currentText.isEmpty) {
        controller.searchController.text = code;
      } else {
        controller.searchController.text = "$currentText\n$code";
      }
      controller.update();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Scanned: $code"), duration: const Duration(milliseconds: 500)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),

          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.black),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: GetBuilder<GenerateTripController>(
                builder: (controller) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller.searchController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Scan Boxes",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: const Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                controller.update();
                              }
                            },
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
                            onPressed: () {
                              controller.searchController.clear();
                              controller.update();
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
                        ],
                      ),
                      // Date Filter button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTapDown: (details) {
                              _showDateFilterMenu(context, details.globalPosition, controller);
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
                      ),

                      // Date Filters (custom range)
                      if (controller.isCustomDate)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const Text("From"),
                                OutlinedButton(
                                  onPressed: () => _pickDate(true, context, controller),
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
                                        "${controller.fromDate.day}-${controller.fromDate.month}-${controller.fromDate.year}",
                                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text("To"),
                                OutlinedButton(
                                  onPressed: () => _pickDate(false, context, controller),
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
                                        "${controller.toDate.day}-${controller.toDate.month}-${controller.toDate.year}",
                                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : () {
                                  controller.search(controller.searchController.text);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: controller.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text("Search", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDateFilterMenu(BuildContext context, Offset offset, GenerateTripController controller) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[850]
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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

  Future<void> _pickDate(bool isFrom, BuildContext context, GenerateTripController controller) async {
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
}
