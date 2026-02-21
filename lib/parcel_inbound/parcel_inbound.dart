import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:opsapp/parcel_inbound/select_reason.dart';

import '../login/auth_controller.dart';
import '../search_parcel/barcode_scan_screen.dart';

class ParcelInboundScreen extends StatefulWidget {
  const ParcelInboundScreen({super.key});

  @override
  State<ParcelInboundScreen> createState() => _ParcelInboundScreenState();
}

class _ParcelInboundScreenState extends State<ParcelInboundScreen> {
  final TextEditingController _scanController = TextEditingController();
  bool _isValidating = false;


  DateTime _toDate = DateTime(
    DateTime.now().add(const Duration(days: 1)).year,
    DateTime.now().add(const Duration(days: 1)).month,
    DateTime.now().add(const Duration(days: 1)).day,
  );
  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(Duration(days: 14));
  String _selectedFilter = "Past 1 month";
  bool _isCustomDate = false;
  DateTimeRange? _customRange;

  void _showDateFilterMenu(BuildContext context, Offset offset) async {
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(40, 40), // position near the button
        Offset.zero & overlay.size,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        const PopupMenuItem(
          value: "Past 1 month",
          child: Text("Past 1 month"),
        ),
        const PopupMenuItem(
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
        _customRange = null;
      });
    } else {
      setState(() {
        _isCustomDate = false;
        _selectedFilter = "Past 1 month";
        _customRange = null;

        _toDate = DateTime(
          DateTime.now().add(const Duration(days: 1)).year,
          DateTime.now().add(const Duration(days: 1)).month,
          DateTime.now().add(const Duration(days: 1)).day,
        );
        _fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(Duration(days: 14));
      });
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
    }
  }

  Future<void> _validateParcels() async {
    if (_isValidating) return;

    setState(() {
      _isValidating = true;
    });

    try {
      String parcelNumber = _scanController.text.trim();

      // Validate parcel number length
      if (parcelNumber.length < 5) {
        Get.snackbar("Error", "Tracking Numbers must be between 5 and 50 characters long.", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
        return;
      }

      if(Get.find<AuthController>().condition == "OK") {
        await Get.find<AuthController>().validateParcel(parcelNumber, _toDate, _fromDate, "02.04.002.1.002.999");

      } else {
        await Get.find<AuthController>().getReasonList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectReasonScreen(
              parcelNumber: parcelNumber,
              fromDate: _fromDate,
              toDate: _toDate,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  _submitParcels(BuildContext context) {
    Navigator.pop(context);
  }

  void _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _scanController.text = data.text!;
      });
    }
  }

  void _resetSearch() {
    setState(() {
      _scanController.clear();
    });
  }

  Future<void> _scanBarcode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onDetect: (barcode) {
            setState(() {
              _scanController.text = barcode;
              // TODO: Call your API or perform search
              Get.find<AuthController>().searchParcelDetail(barcode, _toDate, _fromDate);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Parcel Inbound", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: Colors.black),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scan input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _scanController,
                    decoration: InputDecoration(
                      labelText: "Scan packages One by One",
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
                    String parcelNumber = _scanController.text.trim();
                    
                    // Validate parcel number length
                    if (parcelNumber.length < 5) {
                      Get.snackbar("Error", "Parcel number must be more than 5 characters", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);

                      return;
                    }
                    
                    Get.find<AuthController>().searchParcelDetail(parcelNumber, _toDate, _fromDate);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
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
            // Date Filters
            if(_isCustomDate) Row(
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
                        mainAxisSize: MainAxisSize.min, // keeps the button compact
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
                          const SizedBox(width: 8), // spacing between icon and text
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
                        mainAxisSize: MainAxisSize.min, // keeps the button compact
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
                          const SizedBox(width: 8), // spacing between icon and text
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

            const SizedBox(height: 10),
            const Text("Product Condition:"),

            // Radio Buttons
            Row(
              children: [
                Radio(
                  value: "OK",
                  groupValue: Get.find<AuthController>().condition,
                  onChanged: (value) => setState(() {
                    Get.find<AuthController>().condition = value.toString();
                    Get.find<AuthController>().update();
                  }),
                ),
                const Text("OK"),
                const SizedBox(width: 50,),
                Radio(
                  value: "HOLD",
                  groupValue: Get.find<AuthController>().condition,
                  onChanged: (value) => setState(() {
                    Get.find<AuthController>().condition = value.toString();
                    Get.find<AuthController>().update();
                  }),
                ),
                const Text("HOLD"),
              ],
            ),

            const SizedBox(height: 10),

            // Counters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Parcel Received \n OK",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4), // small space between text and count
                        Obx(() {
                          final controller = Get.find<AuthController>();
                          return Text(
                            controller.okCount.value.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8,),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Parcel Received \n HOLD",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4), // small space between text and count
                        Obx(() {
                          final controller = Get.find<AuthController>();
                          return Text(
                            controller.holdCount.value.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 100),

            // Bottom Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _validateParcels,
                    child: const Text("Validate"),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => _submitParcels(context),
                    child: const Text("Done"),
                  ),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}
