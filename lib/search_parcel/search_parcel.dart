import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:opsapp/search_parcel/model/parcel_detail_model.dart';
import '../login/auth_controller.dart';
import 'barcode_scan_screen.dart';

class SearchParcelScreen extends StatefulWidget {
  @override
  _SearchParcelScreenState createState() => _SearchParcelScreenState();
}

class _SearchParcelScreenState extends State<SearchParcelScreen> {
  final TextEditingController _controller = TextEditingController();

  DateTime _toDate = DateTime(
    DateTime.now().add(const Duration(days: 1)).year,
    DateTime.now().add(const Duration(days: 1)).month,
    DateTime.now().add(const Duration(days: 1)).day,
  );

  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(const Duration(days: 14));
  String _selectedFilter = "Past 1 month";
  bool _isCustomDate = false;


  void _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _controller.text = data.text!;
      });
    }
  }

  void _showDateFilterMenu(BuildContext context, Offset offset) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        const PopupMenuItem(value: "Past 1 month", child: Text("Past 1 month")),
        const PopupMenuItem(value: "Custom Dates", child: Text("Custom Dates")),
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
        _selectedFilter = "Past 1 month";
        _toDate = DateTime(
          DateTime.now().add(const Duration(days: 1)).year,
          DateTime.now().add(const Duration(days: 1)).month,
          DateTime.now().add(const Duration(days: 1)).day,
        );
        _fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(const Duration(days: 14));
      });
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
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

  void _resetSearch() {
    setState(() {
      _controller.clear();
      Get.find<AuthController>().parcelDetails = null;
    });
  }

  void _searchParcel() {
    String parcelNumber = _controller.text.trim();
    if (parcelNumber.isNotEmpty) {
      // Use the date filter variables instead of hardcoded dates
      Get.find<AuthController>().searchParcelDetail(parcelNumber, _toDate, _fromDate);
    }
  }

  Future<void> _scanBarcode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onDetect: (barcode) {
            setState(() {
              _controller.text = barcode;
              _searchParcel();
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
        title: Text("Search Parcel", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: Colors.black),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: GetBuilder<AuthController>(builder: (controller) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: "Enter Parcel Number",
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
                        String parcelNumber = _controller.text.trim();
                        if (parcelNumber.isNotEmpty) {
                          // Use the date filter variables
                          Get.find<AuthController>().searchParcelDetail(parcelNumber, _toDate, _fromDate);
                        }
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
                
                // Date Filter
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
                
                // Date Filters (Custom)
                if (_isCustomDate)
                  Row(
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
                          )
                        ],
                      ),
                    ],
                  ),
                
                const SizedBox(height: 10),
                if (controller.parcelDetails != null)
                  _parcelDetailCard(controller.parcelDetails),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _parcelDetailCard(ParcelDetailModel? parcelDetails) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text.rich(
              TextSpan(
                text: "Parcel Number: ",
                style: TextStyle(color: Colors.black54),
                children: [
                  TextSpan(
                    text: parcelDetails?.items?[0].trackingNumber,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn("Container Number", parcelDetails?.items![0].containerTrackingNumber ?? ""),
                _infoColumn("Status", parcelDetails?.items![0].status ?? "", bold: true),
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn("Weight", ((parcelDetails?.items?[0].weight?.value.toString() ?? "") + " " + (parcelDetails?.items?[0].weight?.unit.toString() ?? "")), bold: true),
                _infoColumn("Chargeable Weight", ((parcelDetails?.items?[0].chargeWeight?.value.toString() ?? "") + " " + (parcelDetails?.items?[0].chargeWeight?.unit.toString() ?? "")),
                    bold: true),
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _infoColumn("Dimensions (L x W x H)", ((parcelDetails?.items?[0].dimensions?.length.toString() ?? "") + " x " + (parcelDetails?.items?[0].dimensions?.width.toString() ?? "") + " x " + (parcelDetails?.items?[0].dimensions?.height.toString() ?? "")),
                bold: true),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child:
                _infoColumn("Receiver Details", ((parcelDetails?.items?[0].receiver?.name.toString() ?? "") +"\n"+(parcelDetails?.items?[0].receiver?.street.toString() ?? "")+"\n"+(parcelDetails?.items?[0].receiver?.city.toString() ?? "")+"\n"+(parcelDetails?.items?[0].receiver?.country.toString() ?? "")+" - "+(parcelDetails?.items?[0].receiver?.postCode.toString() ?? "")+"\n"+(parcelDetails?.items?[0].receiver?.phones.toString() ?? "")+"\n"+(parcelDetails?.items?[0].receiver?.emails.toString() ?? "")), bold: true),
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String title, String value, {bool bold = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// class BarcodeScannerScreen extends StatelessWidget {
//   final Function(String) onDetect;
//
//   BarcodeScannerScreen({required this.onDetect});
//   bool _isScanned = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Scan Barcode")),
//       body: MobileScanner(
//         onDetect: (barcodeCapture) {
//           if (_isScanned) return;
//
//           final List<Barcode> barcodes = barcodeCapture.barcodes;
//           if (barcodes.isNotEmpty) {
//             final String? rawValue = barcodes.first.rawValue;
//             if (rawValue != null) {
//               _isScanned = true;
//               onDetect(rawValue);
//               Navigator.pop(context);
//             }
//           }
//         },
//       ),
//     );
//   }
// }