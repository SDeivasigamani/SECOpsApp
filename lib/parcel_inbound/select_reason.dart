import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../login/auth_controller.dart';
import 'model/reasons_list_model.dart';

class SelectReasonScreen extends StatefulWidget {
  final String parcelNumber;
  final DateTime fromDate;
  final DateTime toDate;

  const SelectReasonScreen({
    Key? key,
    required this.parcelNumber,
    required this.fromDate,
    required this.toDate,
  }) : super(key: key);

  @override
  State<SelectReasonScreen> createState() => _SelectReasonScreenState();
}

class _SelectReasonScreenState extends State<SelectReasonScreen> {
  final TextEditingController _searchController = TextEditingController();
  final authController = Get.find<AuthController>();


  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterReasons);
  }

  void _filterReasons() {
    final query = _searchController.text.toLowerCase();

    authController.filteredReasons = authController.allReasonsList
          ?.where((reason) =>
      reason.title != null &&
          reason.title!.toLowerCase().contains(query))
          .toList();
   authController.update();

  }

  void _onConfirm() {
    if (authController.selectedReason != null) {
      Get.find<AuthController>().validateParcel(widget.parcelNumber, widget.toDate, widget.fromDate, "02.04.002.1.002.999");
      Get.back();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Select Reason',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GetBuilder<AuthController>(
          builder: (controller) {

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔍 Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search here',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🧱 Grid of reasons
                  Expanded(
                    child: GridView.builder(
                      itemCount: controller.filteredReasons?.length ?? 0,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columns
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      itemBuilder: (context, index) {
                        final reason = controller.filteredReasons?[index].title;
                        final isSelected = controller.selectedReason == reason;

                        return GestureDetector(
                          onTap: () {

                            print(reason);
                            controller.selectedReason = reason;
                            controller.update();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                controller.filteredReasons?[index].title ?? "",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                  isSelected ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ✅ Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }
}
