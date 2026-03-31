import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:opsapp/parcel_inbound/select_reason.dart';

import '../login/auth_controller.dart';
import '../search_parcel/barcode_scan_screen.dart';
import '../search_parcel/model/parcel_detail_model.dart';
import '../search_parcel/pdf_view_screen.dart';


class ParcelInboundScreen extends StatefulWidget {
  const ParcelInboundScreen({super.key});

  @override
  State<ParcelInboundScreen> createState() => _ParcelInboundScreenState();
}

class _ParcelInboundScreenState extends State<ParcelInboundScreen> {
  final TextEditingController _scanController = TextEditingController();
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AuthController>().okCount.value = 0;
      Get.find<AuthController>().holdCount.value = 0;
    });
  }


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

  Future<bool> _showHoldAlertDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0)),
                ),
                child: const Text(
                  "Hold Alert !",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "The parcel is on-hold: On-hold,\nPlease receive the parcel separately.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 8.0, top: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ) ?? false;
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

      bool? isHold = await Get.find<AuthController>().checkHoldStatus(parcelNumber, _toDate, _fromDate, context);
      if (isHold == null) {
        return;
      }

      if (isHold) {
        bool continueProceed = await _showHoldAlertDialog();
        if (!continueProceed) return;
      }

      if(Get.find<AuthController>().condition == "OK") {
        // First fetch details to ensure parcelDetails is populated (for PDF check)
        await Get.find<AuthController>().searchParcelDetail(parcelNumber, _toDate, _fromDate, context);
        
        // After successful validation, check for PDF
        _checkAndShowPDF();
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
      Get.find<AuthController>().okCount.value = 0;
      Get.find<AuthController>().holdCount.value = 0;
    });
  }

  void _checkAndShowPDF() {
    var detail = Get.find<AuthController>().parcelDetails;
    if (detail != null && detail.items != null && detail.items!.isNotEmpty) {
      var item = detail.items![0];
      if (item.attachments != null && item.attachments!.isNotEmpty) {
        String? selectedEntity = Get.find<AuthController>().selectedEntity;
        if (selectedEntity != null && selectedEntity.startsWith("NKL")) {
          var attachment = item.attachments![0];
          if (attachment.downloadUrl != null) {
            Get.to(() => PDFViewScreen(
                  url: attachment.downloadUrl!,
                  fileName: attachment.originalFileName ?? "document.pdf",
                ));
          }
        }
      }
    }
  }

  Future<void> _handleSearchResponse(String barcode) async {
    _scanController.text = barcode;
    _validateParcels();
  }

  Future<void> _scanBarcode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onDetect: (barcode) {
            _handleSearchResponse(barcode);
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
      body: GetBuilder<AuthController>(builder: (controller) {
        return SingleChildScrollView(
          child: Padding(
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

                Builder(builder: (context) {
                  bool showCard = controller.parcelDetails != null;
                  if (showCard && controller.parcelDetails!.items != null && controller.parcelDetails!.items!.isNotEmpty) {
                    var item = controller.parcelDetails!.items![0];
                    String? selectedEntity = controller.selectedEntity;
                    if (item.attachments != null &&
                        item.attachments!.isNotEmpty &&
                        selectedEntity != null &&
                        selectedEntity.startsWith("NKL")) {
                      showCard = false;
                    }
                  }

                  // if (showCard) {
                  //   return Column(
                  //     children: [
                  //       _parcelDetailCard(controller.parcelDetails),
                  //       const SizedBox(height: 10),
                  //     ],
                  //   );
                  // }
                  return const SizedBox.shrink();
                }),

                const Text("Product Condition:"),

                // Radio Buttons
                Row(
                  children: [
                    Radio(
                      value: "OK",
                      groupValue: Get.find<AuthController>().condition,
                      onChanged: (value) => setState(() {
                        Get.find<AuthController>().condition = value.toString();
                        Get.find<AuthController>().okCount.value = 0;
                        Get.find<AuthController>().holdCount.value = 0;
                        Get.find<AuthController>().update();
                      }),
                    ),
                    const Text("OK"),
                    const SizedBox(
                      width: 50,
                    ),
                    Radio(
                      value: "HOLD",
                      groupValue: Get.find<AuthController>().condition,
                      onChanged: (value) => setState(() {
                        Get.find<AuthController>().condition = value.toString();
                        Get.find<AuthController>().okCount.value = 0;
                        Get.find<AuthController>().holdCount.value = 0;
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
                    const SizedBox(
                      width: 8,
                    ),
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

                const SizedBox(height: 20),

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
                        onPressed: _isValidating ? null : _validateParcels,
                        child: _isValidating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text("Validate"),
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
      }),
    );
  }

  Widget _parcelDetailCard(ParcelDetailModel? parcelDetails) {
    var item = parcelDetails?.items?[0];
    var receiver = item?.receiver;

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
                    text: item?.trackingNumber,
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
                _infoColumn("Container Number", item?.containerTrackingNumber ?? ""),
                _infoColumn("Status", item?.status ?? "", bold: true),
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn("Weight",
                    ((item?.weight?.value?.toString() ?? "") + " " + (item?.weight?.unit?.toString() ?? "")),
                    bold: true),
                _infoColumn("Chargeable Weight",
                    ((item?.chargeWeight?.value?.toString() ?? "") + " " + (item?.chargeWeight?.unit?.toString() ?? "")),
                    bold: true),
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _infoColumn(
                "Dimensions (L x W x H)",
                ((item?.dimensions?.length?.toString() ?? "") +
                    " x " +
                    (item?.dimensions?.width?.toString() ?? "") +
                    " x " +
                    (item?.dimensions?.height?.toString() ?? "")),
                bold: true),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _infoColumn(
              "Receiver Details",
              ((receiver?.name ?? "") +
                  "\n" +
                  (receiver?.street?.join(", ") ?? "") +
                  "\n" +
                  (receiver?.city ?? "") +
                  "\n" +
                  (receiver?.country ?? "") +
                  " - " +
                  (receiver?.postCode ?? "") +
                  "\n" +
                  (receiver?.phones?.join(", ") ?? "") +
                  "\n" +
                  (receiver?.emails?.join(", ") ?? "")),
              bold: true,
            ),
          ),
          if (item?.attachments != null && item!.attachments!.isNotEmpty) ...[
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Attachments", style: TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 8),
                  ...item.attachments!.map((attachment) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () {
                          if (attachment.downloadUrl != null) {
                            Get.to(() => PDFViewScreen(
                                  url: attachment.downloadUrl!,
                                  fileName: attachment.originalFileName ?? "document.pdf",
                                ));
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                attachment.originalFileName ?? "View document",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
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
