import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:opsapp/sortation/repository/sortation_repo.dart';
import 'package:opsapp/utils/client_api.dart';
import 'package:opsapp/sortation/model/container_detail_model.dart';
import 'package:opsapp/sortation/add_package_screen.dart';
import 'package:opsapp/widgets/custom_snackbar.dart';

class ParcelScannerPage extends StatefulWidget {
  const ParcelScannerPage({Key? key}) : super(key: key);

  @override
  State<ParcelScannerPage> createState() => _ParcelScannerPageState();
}

class _ParcelScannerPageState extends State<ParcelScannerPage> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _read = false;
  bool _isBottomSheetOpen = false;
  late SortationRepo _sortationRepo;

  @override
  void initState() {
    super.initState();
    _sortationRepo = SortationRepo(apiClient: Get.find<ApiClient>());
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_read) return;
    final code = capture.barcodes.isNotEmpty ? (capture.barcodes.first.rawValue ?? '') : '';
    if (code.isNotEmpty) {
      _read = true;
      // Search container instead of popping
      _searchContainer(code);
      // Reset _read after a delay to allow scanning again
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _read = false;
          });
        }
      });
    }
  }

  Future<void> _searchContainer(String number) async {
    try {
      DateTime fromDate = DateTime(2020, 1, 16, 7, 25, 0);
      DateTime toDate = DateTime.now();

      Response response = await _sortationRepo.getOpenContainer(
          number, "BAG", fromDate, toDate);

      if (response.statusCode == 200) {
        ContainerDetailModel containerDetail =
            ContainerDetailModel.fromJson(response.body);
        _showContainerDetailBottomSheet(containerDetail);
      } else {
        Get.snackbar("Error", "Container not found: ${response.statusText}", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "An error occurred: $e", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    }
  }

  void _showContainerDetailBottomSheet(ContainerDetailModel container) {
    if (_isBottomSheetOpen) return;

    setState(() {
      _isBottomSheetOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with box number and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Box #: ${container.id ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Shipper and Receiver row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Shipper:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        container.shipper?.name ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Shipper Name",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Receiver:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        container.receiver?.name ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Consignee Name",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sortation Rule
            Row(
              children: [
                const Text(
                  "Sortation Rule: ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  container.sortationRuleCode ?? "Not assigned",
                  style: TextStyle(
                    fontSize: 14,
                    color: container.sortationRuleCode != null
                        ? Colors.black
                        : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weight and Dimensions row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Initial Weight:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        container.weight != null
                            ? "${container.weight!.value ?? 0} ${container.weight!.unit ?? 'kg'}"
                            : "N/A",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Initial Dim:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        container.dimensions != null
                            ? "${container.dimensions!.length ?? 0} X ${container.dimensions!.width ?? 0} X ${container.dimensions!.height ?? 0} ${container.dimensions!.unit ?? 'cm'}"
                            : "N/A",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

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
                  Navigator.pop(context);
                  // Navigate to Add Package screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddPackageScreen(
                        containerTrackingNumber: container.id ?? '',
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Confirm and Scan Packages",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _isBottomSheetOpen = false;
        });
      }
    });
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
          ScannerBottomSheet(
            onPaste: (text) {
              // Don't pop, just trigger search if valid
              if (text.isNotEmpty && text.length > 5) {
                _searchContainer(text);
              }
            },
            onReset: () {
              // Just reset, don't pop
            },
            onSearchPressed: (value) {
              _searchContainer(value); // Search instead of popping
            },
          ),

          // Optional helper controls (torch/flip) top-right
          // Positioned(
          //   right: 16,
          //   top: MediaQuery.of(context).padding.top + 12,
          //   child: Column(
          //     children: [
          //       IconButton(
          //         onPressed: () => _cameraController.toggleTorch(),
          //         icon: const Icon(Icons.lightbulb, color: Colors.white70),
          //       ),
          //       IconButton(
          //         onPressed: () => _cameraController.switchCamera(),
          //         icon: const Icon(Icons.cameraswitch, color: Colors.white70),
          //       ),
          //     ],
          //   ),
          // ),
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
  final void Function(String) onPaste;
  final VoidCallback onReset;
  final void Function(String) onSearchPressed;

  const ScannerBottomSheet({
    Key? key,
    required this.onPaste,
    required this.onReset,
    required this.onSearchPressed,
  }) : super(key: key);

  @override
  State<ScannerBottomSheet> createState() => _ScannerBottomSheetState();
}

class _ScannerBottomSheetState extends State<ScannerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  DateTime _toDate = DateTime(
    DateTime.now().add(const Duration(days: 1)).year,
    DateTime.now().add(const Duration(days: 1)).month,
    DateTime.now().add(const Duration(days: 1)).day,
  );
  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
      .subtract(const Duration(days: 30));
  String _selectedFilter = "Past 1 month";
  bool _isCustomDate = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';
    if (text.isNotEmpty) {
      // update controller and notify parent
      _searchController.text = text;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
      widget.onPaste(text);
      setState(() {}); // update UI (e.g. enable search button)
    }
  }

  void _showDateFilterMenu(BuildContext context, Offset offset) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(40, 40), // position near the button
        Offset.zero & overlay.size,
      ),
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[850]
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: const [
        PopupMenuItem(
          value: "Past 1 month",
          child: Text("Past 1 month"),
        ),
        PopupMenuItem(
          value: "Past 2 months",
          child: Text("Past 2 months"),
        ),
        PopupMenuItem(
          value: "Past 1 year",
          child: Text("Past 1 year"),
        ),
        PopupMenuItem(
          value: "Custom Dates",
          child: Text("Custom Dates"),
        ),
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
        _selectedFilter = result;   // dynamically handle all new filters
      });
    }
  }

  Future<void> _pickDate(bool isFrom, BuildContext context) async {
    DateTime initial = isFrom ? _fromDate : _toDate;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _onResetPressed() {
    _searchController.clear();
    setState(() {}); // refresh UI
  }

  void _onSearchPressed() {
    final value = _searchController.text.trim();
    
    // Validate search text length
    if (value.length <= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Search text must be more than 5 characters"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    widget.onSearchPressed(value);
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Enter Box or Reference numbers",
                  // prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    // borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),

            const SizedBox(height: 12),

            // Paste & Reset row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _pasteFromClipboard(context),
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
                  onPressed: _onResetPressed,
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
            ),

            // Date Filters (custom range)
            if (_isCustomDate)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text("From"),
                      OutlinedButton(
                        onPressed: () => _pickDate(true, context),
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
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("To"),
                      OutlinedButton(
                        onPressed: () => _pickDate(false, context),
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
                onPressed: _searchController.text.trim().isEmpty ? null : _onSearchPressed,
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

