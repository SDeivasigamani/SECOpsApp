import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:opsapp/sortation/model/container_detail_model.dart';
import 'package:opsapp/sortation/repository/sortation_repo.dart';
import 'package:opsapp/utils/client_api.dart';
import 'package:opsapp/utils/route_helper.dart';

import '../widgets/custom_snackbar.dart';

class BoxDetailsPreviewScreen extends StatefulWidget {
  final ContainerDetailModel containerDetail;

  const BoxDetailsPreviewScreen({Key? key, required this.containerDetail}) : super(key: key);

  @override
  State<BoxDetailsPreviewScreen> createState() => _BoxDetailsPreviewScreenState();
}

class _BoxDetailsPreviewScreenState extends State<BoxDetailsPreviewScreen> {
  late TextEditingController _weightController;
  late TextEditingController _lengthController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late SortationRepo _sortationRepo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sortationRepo = SortationRepo(apiClient: Get.find<ApiClient>());
    _weightController = TextEditingController(
      text: _calculateTotalWeight(),
    );
    _lengthController = TextEditingController(
      text: widget.containerDetail.dimensions?.length?.toString() ?? '0',
    );
    _widthController = TextEditingController(
      text: widget.containerDetail.dimensions?.width?.toString() ?? '0',
    );
    _heightController = TextEditingController(
      text: widget.containerDetail.dimensions?.height?.toString() ?? '0',
    );
  }

  String _calculateTotalWeight() {
    double totalWeight = 0.0;
    final parcels = widget.containerDetail.parcels ?? [];
    for (var parcel in parcels) {
      if (parcel is Map<String, dynamic>) {
        if (parcel['weight'] != null && parcel['weight']['value'] != null) {
          totalWeight += (parcel['weight']['value'] as num).toDouble();
        }
      }
    }
    // Return value only, no unit, as the text field handles the number part
    return totalWeight.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  @override
  void dispose() {
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with box number and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Box #: ${widget.containerDetail.id ?? 'N/A'}",
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
                      widget.containerDetail.shipper?.name ?? 'N/A',
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
                      widget.containerDetail.receiver?.name ?? 'N/A',
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
                widget.containerDetail.sortationRuleCode ?? "Not assigned",
                style: TextStyle(
                  fontSize: 14,
                  color: widget.containerDetail.sortationRuleCode != null ? Colors.black : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weight field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Weight",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
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
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.containerDetail.weight?.unit ?? 'kg',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dimensions row
          Row(
            children: [
              // Length
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Length",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _lengthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Width
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Width",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _widthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Height
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Height",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Padding(
                padding: const EdgeInsets.only(top: .0),
                child: Text(
                  widget.containerDetail.dimensions?.unit ?? 'cm',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 24),

          // Close Box button
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
              onPressed: _isLoading ? null : _closeBox,
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
                      "Close Box",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _closeBox() async {
    // Get updated values
    final updatedWeight = double.tryParse(_weightController.text) ?? 0;
    final updatedLength = double.tryParse(_lengthController.text) ?? 0;
    final updatedWidth = double.tryParse(_widthController.text) ?? 0;
    final updatedHeight = double.tryParse(_heightController.text) ?? 0;

    setState(() {
      _isLoading = true;
    });

    try {
      Response response = await _sortationRepo.updateContainer(
        number: widget.containerDetail.id ?? '',
        type: widget.containerDetail.type ?? 'BAG',
        weightValue: updatedWeight,
        weightUnit: widget.containerDetail.weight?.unit ?? 'kg',
        length: updatedLength,
        width: updatedWidth,
        height: updatedHeight,
        dimensionsUnit: widget.containerDetail.dimensions?.unit ?? 'cm',
        closeContainer: true,
        sortationRuleCode: widget.containerDetail.sortationRuleCode,
        entity: widget.containerDetail.entity ?? 'DXB',
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Get.snackbar("Success", "Container closed successfully", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
          Get.offNamedUntil(RouteHelper.getSortationScreen(),
              (route) => route.settings.name == RouteHelper.getUsersHome());
        }
      } else {
        if (mounted) {
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
