import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/images.dart';
import '../utils/route_helper.dart';

class GenerateTripSuccessScreen extends StatelessWidget {
  final String? tripId;
  const GenerateTripSuccessScreen({super.key, this.tripId});

  @override
  Widget build(BuildContext context) {
    // Get tripId from arguments if not passed directly (for named routes)
    final String displayTripId = tripId ?? Get.arguments ?? "TRPXXXX";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Image.asset(
                  Images.logo,
                  width: 250,
                  fit: BoxFit.contain,
                ),
              ),

              // Trip ID and Barcode
              Column(
                children: [
                  Text(
                    "Trip ID: $displayTripId",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A90E2), // A soft blue
                    ),
                  ),
                  const SizedBox(height: 60),
                  BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: displayTripId,
                    width: 300,
                    height: 150,
                    drawText: true,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // Home Button
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed(RouteHelper.getUsersHome());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Green from image
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "Home",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
