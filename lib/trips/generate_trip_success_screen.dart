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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Image.asset(
                    Images.logo,
                    width: 280,
                    fit: BoxFit.contain,
                  ),
                ),

                // Trip ID and Barcode
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Trip ID: $displayTripId",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A90E2), // Matching the blue in the screenshot
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 50),
                    BarcodeWidget(
                      barcode: Barcode.code128(), // Highly scannable format
                      data: displayTripId,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 160,
                      drawText: true,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                // Home Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: SizedBox(
                    width: 220,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offAllNamed(RouteHelper.getUsersHome());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50), // Premium green
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Home",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
