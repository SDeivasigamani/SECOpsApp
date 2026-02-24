import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:opsapp/sortation/select_address_screen.dart';
import 'package:opsapp/sortation/select_sortation_rule.dart';
import 'package:opsapp/sortation/repository/sortation_repo.dart';
import 'package:opsapp/utils/client_api.dart';
import 'package:opsapp/login/auth_controller.dart';
import 'package:opsapp/search_parcel/barcode_scan_screen.dart';
import 'package:opsapp/sortation/model/address_book_model.dart';


class CreateBoxScreen extends StatefulWidget {
  const CreateBoxScreen({super.key});

  @override
  State<CreateBoxScreen> createState() => _CreateBoxScreenState();
}

class _CreateBoxScreenState extends State<CreateBoxScreen> {
  final TextEditingController refController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  String? selectedEntity;
  Matches? selectedConsignee;
  Matches? selectedShipper;
  String? selectedSortationRule;
  
  late SortationRepo _sortationRepo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sortationRepo = SortationRepo(apiClient: Get.find<ApiClient>());
  }

  Future<void> _scanBarcode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onDetect: (barcode) {
            setState(() {
              refController.text = barcode;
            });
          },
        ),
      ),
    );
  }

  Map<String, String> _getUnits() {
    String? entity = selectedEntity; // This might be "DXB - Dubai" or just "DXB"
    if (entity == null || entity.isEmpty) {
       // Fallback to controller's selected entity if local is null
       final authController = Get.find<AuthController>();
       entity = authController.selectedEntity;
    }

    if (entity != null) {
      final code = entity.split(" - ")[0];
      final authController = Get.find<AuthController>();
      if (authController.entityConfigurations.containsKey(code)) {
        return authController.entityConfigurations[code]!;
      }
    }
    
    // Default fallback
    return {"weightUnit": "kg", "dimensionUnit": "cm", "defaultAccountNumber": "001"};
  }

  @override
  Widget build(BuildContext context) {
    final units = _getUnits();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Create Box", style: TextStyle(fontSize: 20)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Scan the label or input the ref number",
              style: TextStyle(color: Colors.blue, fontSize: 15),
            ),

            const SizedBox(height: 12),

            // Reference number + scan icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Reference Number TextField (full width)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Reference number",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 5),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        height: 55,  // <-- Same height as scan button
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: refController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // QR Scan button
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: GestureDetector(
                    onTap: _scanBarcode,
                    child: Container(
                      height: 55,         // << SAME HEIGHT as textfield
                      width: 55,          // square button
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.qr_code_scanner, size: 28),
                    ),
                  ),
                ),
              ],
            ),


            const SizedBox(height: 20),

            // Entity dropdown
            _buildDropdown(),

            const SizedBox(height: 20),

            // Weight
            const Text(
              "Weight",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(units['weightUnit'] ?? "kg", style: const TextStyle(fontSize: 14)),
              ],
            ),

            const SizedBox(height: 15),

            // Length Width Height row
            Row(
              children: [
                Expanded(child: _buildNumberField("Length", lengthController)),
                const SizedBox(width: 8),
                Expanded(child: _buildNumberField("Width", widthController)),
                const SizedBox(width: 8),
                Expanded(child: _buildNumberField("Height", heightController)),
                const SizedBox(width: 8),
                Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Text(units['dimensionUnit'] ?? "cm", style: const TextStyle(fontSize: 14))),
              ],
            ),

            const SizedBox(height: 20),

            // Destination (Consignee)
            _consigneeBox(),

            const SizedBox(height: 15),

            // Shipper select
            _shipperBox(),

            const SizedBox(height: 15),

            // Sortation Rule
            _sortationRuleBox(),

            const SizedBox(height: 30),

            _createButton(),
          ],
        ),
      ),
    );
  }

  // ---------- UI COMPONENTS ----------

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return _buildTextField(label, controller);
  }

  Widget _buildDropdown() {
    return GetBuilder<AuthController>(builder: (controller) {
      // Initialize selectedEntity to match the one selected in home screen
      if (selectedEntity == null || selectedEntity!.isEmpty) {
        if (controller.selectedEntity != null && controller.selectedEntity!.isNotEmpty) {
          // Use the entity selected in home screen
          selectedEntity = controller.selectedEntity;
        } else if (controller.userEntities.isNotEmpty) {
          // Fallback to first entity if no entity is selected in home screen
          selectedEntity = controller.userEntities[0];
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Entity",
              style: TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,   // << FULL WIDTH
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,   // << IMPORTANT
                value: selectedEntity,
                items: controller.userEntities.map((String entity) {
                  return DropdownMenuItem<String>(
                    value: entity,
                    child: Text(entity),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() => selectedEntity = v);
                },
              ),
            ),
          )
        ],
      );
    });
  }


  Widget _consigneeBox() {
    return _addressSelectBox(
      label: "Consignee",
      hint: "Select Consignee",
      selected: selectedConsignee,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SelectAddressScreen()),
        );
        if (result != null && result is Matches) {
          setState(() => selectedConsignee = result);
        }
      },
    );
  }

  Widget _shipperBox() {
    return _addressSelectBox(
      label: "Shipper",
      hint: "Select Shipper",
      selected: selectedShipper,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SelectAddressScreen()),
        );
        if (result != null && result is Matches) {
          setState(() => selectedShipper = result);
        }
      },
    );
  }

  Widget _addressSelectBox({
    required String label,
    required String hint,
    required Matches? selected,
    required VoidCallback onTap,
  }) {
    String displayText = hint;
    if (selected != null && selected.details != null) {
      final d = selected.details!;
      displayText = [
        d.name ?? "",
        d.address?.street?.join(", ") ?? "",
        "${d.address?.city ?? ""}, ${d.address?.state ?? ""}",
        "${d.address?.country ?? ""} - ${d.address?.postCode ?? ""}",
      ].where((s) => s.isNotEmpty && s != ", " && s != " - ").join("\n");
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              displayText,
              style: TextStyle(
                color: selected != null ? Colors.black : Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortationRuleBox() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SelectSortationRuleScreen(),
          ),
        );

        if (result != null) {
          setState(() {
            selectedSortationRule = result;   // <-- Update UI
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sortation Rule",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            height: 70,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              selectedSortationRule ?? "Select Sortation Rule",
              style: TextStyle(
                color: selectedSortationRule != null ? Colors.black : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _scanButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.qr_code_scanner, size: 28),
    );
  }

  Widget _createButton() {
    return Center(
      child: Container(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: _isLoading ? null : _createContainer,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Create",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
        ),
      ),
    );
  }

  Future<void> _createContainer() async {
    // Validate required fields
    if (refController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a reference number", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Extract entity code from selected entity (e.g., "DXB - Dubai" -> "DXB")
      String entityCode = selectedEntity?.split(' - ').first ?? 'DXB';
      
      final units = _getUnits();

      // Parse numeric values
      double weight = double.tryParse(weightController.text) ?? 1;
      double length = double.tryParse(lengthController.text) ?? 20;
      double width = double.tryParse(widthController.text) ?? 30;
      double height = double.tryParse(heightController.text) ?? 40;

      // Function to map Matches to Map<String, dynamic>
      Map<String, dynamic> mapAddress(Matches? match, String defaultName) {
        if (match == null || match.details == null) {
          return {
            "name": defaultName,
            "phones": ["0000000000"],
            "emails": ["info@shipacommerce.com"],
            "address": {
              "country": "AE",
              "city": "Dubai",
              "state": "Dubai",
              "street": ["-"],
              "post_code": "00000"
            },
            "location": {"longitude": 0.0, "latitude": 0.0}
          };
        }
        final d = match.details!;
        return {
          "name": d.name ?? defaultName,
          "phones": d.phones ?? ["0000000000"],
          "emails": d.emails ?? ["info@shipacommerce.com"],
          "address": {
            "country": d.address?.country ?? "AE",
            "city": d.address?.city ?? "Dubai",
            "state": d.address?.state ?? "Dubai",
            "street": d.address?.street ?? ["-"],
            "post_code": d.address?.postCode ?? "00000"
          },
          "location": {
            "longitude": d.location?.longitude?.toDouble() ?? 0.0,
            "latitude": d.location?.latitude?.toDouble() ?? 0.0
          }
        };
      }

      Map<String, dynamic> consigneeData = mapAddress(selectedConsignee, "Consignee by mobile app");
      Map<String, dynamic> shipperData = mapAddress(selectedShipper, "Shipper by mobile app");

      Response response = await _sortationRepo.createContainer(
        user: Get.find<AuthController>().userName,
        tenant: "other",
        channel: "ch",
        containerNumber: refController.text.trim(),
        entity: entityCode,
        flightNumber: null,
        type: "bag",
        description: "Container created from mobile app",
        shipDate: DateTime.now().toIso8601String(),
        consignee: consigneeData,
        shipper: shipperData,
        accountNumber: units['defaultAccountNumber'] ?? "001",
        accountEntity: entityCode,
        weightValue: weight,
        weightUnit: units['weightUnit'] ?? "kg",
        length: length,
        width: width,
        height: height,
        dimensionsUnit: units['dimensionUnit'] ?? "cm",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Container created successfully", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
        Navigator.pop(context, refController.text.trim());
      } else {
        String errorMessage = "Failed to add package: ${response.statusText}";
        if (response.body != null) {
          try {
            if (response.body is List && response.body.isNotEmpty) {
              errorMessage = response.body[0]['message'] ?? errorMessage;
            } else if (response.body is Map) {
              errorMessage = response.body['message'] ?? errorMessage;
            }
          } catch (e) {
            print("Error parsing addResponse body: $e");
          }
        }
        Get.snackbar("Error", errorMessage, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "An error occurred: $e", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
