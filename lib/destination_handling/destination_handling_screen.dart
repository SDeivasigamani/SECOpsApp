import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'destination_handling_controller.dart';
import 'destination_handling_search_screen.dart';

class DestinationHandlingScreen extends StatefulWidget {
  const DestinationHandlingScreen({Key? key}) : super(key: key);

  @override
  State<DestinationHandlingScreen> createState() => _DestinationHandlingScreenState();
}

class _DestinationHandlingScreenState extends State<DestinationHandlingScreen> {
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
      return; // Debounce same code
    }

    _lastScannedCode = code;
    _lastScanTime = now;

    final controller = Get.find<DestinationHandlingController>();
    String currentText = controller.searchController.text;
    
    // Check if already exists to avoid duplicates (optional, but good UX)
    List<String> existing = currentText.split(RegExp(r'[,\n]')).map((e) => e.trim()).toList();
    if (!existing.contains(code)) {
      if (currentText.isEmpty) {
        controller.searchController.text = code;
      } else {
        controller.searchController.text = "$currentText\n$code";
      }
      controller.update();
      
      // Show a toast or snackbar to indicate scan success
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
          // ScannerView handles camera preview and detection
          ScannerView(
            controller: _cameraController,
            onDetect: _onDetect,
          ),

          // Small top close button
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 16,
            child: CloseButtonCircle(onPressed: () => Navigator.of(context).pop()),
          ),

          // Overlay in center
          const ScannerOverlay(),

          // Bottom sheet actions
          const ScannerBottomSheet(),
        ],
      ),
    );
  }
}

// ---------------------- ScannerView ----------------------
class ScannerView extends StatelessWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;

  const ScannerView({Key? key, required this.controller, required this.onDetect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: controller,
      onDetect: onDetect,
    );
  }
}

// ---------------------- ScannerOverlay ----------------------
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.8;
    final height = MediaQuery.of(context).size.width * 0.48;

    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // translucent rectangle to emulate the design
            Container(
              color: Colors.white.withOpacity(0.12),
            ),

            // horizontal red scan line slightly above center
            Align(
              alignment: const Alignment(0, -0.12),
              child: Container(height: 2, color: Colors.redAccent),
            ),

            // small guide dot on the right
            Positioned(
              right: 40,
              top: height / 2 - 6,
              child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- ScannerBottomSheet ----------------------
class ScannerBottomSheet extends StatefulWidget {
  const ScannerBottomSheet({Key? key}) : super(key: key);

  @override
  State<ScannerBottomSheet> createState() => _ScannerBottomSheetState();
}

class _ScannerBottomSheetState extends State<ScannerBottomSheet> {
  // Removed local controller, using Get.find<DestinationHandlingController>()

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    final controller = Get.find<DestinationHandlingController>();
    
    return GetBuilder<DestinationHandlingController>(builder: (_) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF222222) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: controller.searchController,
                  maxLines: null, // Allow multiple lines
                  decoration: InputDecoration(
                    hintText: "Enter Box or Reference numbers",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => controller.update(),
                ),
              ),

              const SizedBox(height: 12),

              // Paste & Reset row
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

              const SizedBox(height: 12),

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

              // Search button
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  onPressed: controller.searchController.text.trim().isEmpty 
                      ? null 
                      : () {
                          // Navigate to search screen
                          Get.to(() => const DestinationHandlingSearchScreen());
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Search', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showDateFilterMenu(BuildContext context, Offset offset, DestinationHandlingController controller) async {
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

  Future<void> _pickDate(bool isFrom, BuildContext context, DestinationHandlingController controller) async {
    DateTime initial = isFrom ? controller.fromDate : controller.toDate;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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

// ---------------------- CloseButtonCircle ----------------------
class CloseButtonCircle extends StatelessWidget {
  final VoidCallback onPressed;
  const CloseButtonCircle({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white70,
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.black87),
        onPressed: onPressed,
      ),
    );
  }
}

