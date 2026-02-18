import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_snackbar.dart';
import 'generate_trip_controller.dart';

class GenerateTripConfirmScreen extends StatefulWidget {
  const GenerateTripConfirmScreen({super.key});

  @override
  State<GenerateTripConfirmScreen> createState() => _GenerateTripConfirmScreenState();
}

class _GenerateTripConfirmScreenState extends State<GenerateTripConfirmScreen> {
  final TextEditingController _truckIdController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _estimatedDeliveryTime;

  @override
  void dispose() {
    _truckIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _estimatedDeliveryTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GenerateTripController>(
      builder: (controller) {
        // Get selected package numbers (trackingNumber)
        final selectedPackages = controller.searchResults
            .where((item) => controller.isItemSelected(item.trackingNumber))
            .map((item) => item.trackingNumber ?? '')
            .where((tn) => tn.isNotEmpty)
            .toList();

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
              'Generate Trip',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estimated Delivery Time
                Text(
                          "Estimated Delivery Time",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectDateTime,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _estimatedDeliveryTime == null
                                      ? ""
                                      : DateFormat('yyyy-MM-dd HH:mm').format(_estimatedDeliveryTime!),
                                  style: TextStyle(
                                    color: _estimatedDeliveryTime == null ? Colors.grey : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Truck ID
                const Text(
                  "Truck ID",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _truckIdController,
                  decoration: InputDecoration(
                    // hintText: "Enter Truck ID",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                const Text(
                  "Notes",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    // hintText: "Enter Notes",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Selected Boxes
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Selected Boxes",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...selectedPackages.map((packageNum) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              packageNum,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () {
                            if (_estimatedDeliveryTime == null) {
                              Get.snackbar(
                                "Error",
                                "Please select estimated delivery time",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                              return;
                            }
                            if (_truckIdController.text.trim().isEmpty) {
                              Get.snackbar(
                                "Error",
                                "Please enter truck ID",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                              return;
                            }

                            controller.confirmGenerateTrip(
                              estimatedDeliveryTime: _estimatedDeliveryTime!,
                              truckId: _truckIdController.text.trim(),
                              note: _notesController.text.trim(),
                            );
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
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Confirm",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
