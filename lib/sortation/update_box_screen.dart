import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:opsapp/sortation/model/container_model.dart';
import 'package:opsapp/sortation/add_package_screen.dart';
import 'package:opsapp/search_parcel/barcode_scan_screen.dart';
import 'package:opsapp/sortation/repository/sortation_repo.dart';
import 'package:opsapp/utils/client_api.dart';
import '../login/auth_controller.dart';
import '../widgets/custom_snackbar.dart';

class UpdateBoxScreen extends StatefulWidget {
  final Matches container;

  const UpdateBoxScreen({Key? key, required this.container}) : super(key: key);

  @override
  State<UpdateBoxScreen> createState() => _UpdateBoxScreenState();
}

class _UpdateBoxScreenState extends State<UpdateBoxScreen> {
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  
  late SortationRepo _sortationRepo;
  bool _isLoading = false;
  String? selectedEntity;

  @override
  void initState() {
    super.initState();
    _sortationRepo = SortationRepo(apiClient: Get.find<ApiClient>());
    _loadContainerData();
  }

  void _loadContainerData() {
    // Pre-populate fields with container data
    setState(() {
      _referenceController.text = widget.container.number ?? '';
      _weightController.text = widget.container.weight?.value?.toString() ?? '';
      _lengthController.text = widget.container.dimensions?.length?.toString() ?? '';
      _widthController.text = widget.container.dimensions?.width?.toString() ?? '';
      _heightController.text = widget.container.dimensions?.height?.toString() ?? '';
      // Don't set selectedEntity here - let the GetBuilder handle it
      // This ensures proper matching with userEntities list
    });
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onDetect: (barcode) {
            setState(() {
              _referenceController.text = barcode;
            });
          },
        ),
      ),
    );
  }

  Future<void> _saveBox() async {
    // Validate inputs
    if (_weightController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter weight", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }
    
    if (_lengthController.text.trim().isEmpty || 
        _widthController.text.trim().isEmpty || 
        _heightController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter all dimensions", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse values
      double weightValue = double.tryParse(_weightController.text.trim()) ?? 0;
      double length = double.tryParse(_lengthController.text.trim()) ?? 0;
      double width = double.tryParse(_widthController.text.trim()) ?? 0;
      double height = double.tryParse(_heightController.text.trim()) ?? 0;
      
      // Extract entity code from selectedEntity (format: "CODE - Name")
      String entityCode = selectedEntity?.split(' - ').first ?? widget.container.entity ?? '';

      Response response = await _sortationRepo.updateContainer(
        number: widget.container.number ?? '',
        type: "BAG",
        weightValue: weightValue,
        weightUnit: "kg",
        length: length,
        width: width,
        height: height,
        dimensionsUnit: "cm",
        closeContainer: false, // Set to true if you want to close the container
        sortationRuleCode: widget.container.sortationRuleCode?.toString(),
        entity: entityCode,
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Box updated successfully", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
        // Navigate back after successful update
        Navigator.pop(context);
      } else {
        Get.snackbar("Error", "Failed to update box: ${response.statusText}", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      print("Error updating box: $e");
      Get.snackbar("Error", "An error occurred: $e", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAddParcels() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddPackageScreen(
          containerTrackingNumber: widget.container.number ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Update Box",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header text
            const Text(
              "Scan the label or input the ref number",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Reference number field with barcode icon
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _referenceController.text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: (){
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.qr_code_scanner, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Entity dropdown
            const Text(
              "Entity",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            GetBuilder<AuthController>(builder: (controller) {
              // Match the container entity code with the formatted userEntities
              if (controller.userEntities.isNotEmpty) {
                // Find matching entity from userEntities that starts with container entity code
                final matchingEntity = controller.userEntities.firstWhere(
                  (entity) => entity.startsWith(widget.container.entity ?? ''),
                  orElse: () => controller.userEntities.isNotEmpty ? controller.userEntities[0] : '',
                );
                
                // Only update if we found a valid match and it's different
                if (matchingEntity.isNotEmpty && selectedEntity != matchingEntity) {
                  selectedEntity = matchingEntity;
                }
              }
              
              // Fallback to first entity if selectedEntity is still null or not in list
              if (selectedEntity == null || 
                  selectedEntity!.isEmpty || 
                  !controller.userEntities.contains(selectedEntity)) {
                if (controller.userEntities.isNotEmpty) {
                  selectedEntity = controller.userEntities[0];
                }
              }
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedEntity,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: controller.userEntities.map((String entity) {
                    return DropdownMenuItem<String>(
                      value: entity,
                      child: Text(entity),
                    );
                  }).toList(),
                  onChanged: null,
                ),
              );
            }),
            const SizedBox(height: 16),

            // Weight field
            const Text(
              "Weight",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text("kg", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),

            // Dimensions row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Length",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _lengthController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Width",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _widthController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Height",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text("cm", style: TextStyle(fontSize: 14))),
              ],
            ),

            const SizedBox(height: 16),

            // Destination
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Destination",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  height: 140,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.container.consignee?.name ?? 'N/A',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.container.consignee?.address != null
                            ? "${widget.container.consignee!.address!.city ?? ''}, ${widget.container.consignee!.address!.state ?? ''}\n${widget.container.consignee!.address!.country ?? ''}\n${widget.container.consignee!.address!.postCode ?? ''}"
                            : 'N/A',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sortation Rule
            Column(
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
                    widget.container.sortationRuleCode?.toString() ?? 'Not assigned',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Bottom buttons
            // Bottom buttons
            if (widget.container.status?.toLowerCase() != 'closed')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isLoading ? null : _saveBox,
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
                              "Save",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _navigateToAddParcels,
                      child: const Text(
                        "Add Parcels",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
