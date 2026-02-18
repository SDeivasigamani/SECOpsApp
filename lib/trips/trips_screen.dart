import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/route_helper.dart';
import 'generate_trip_controller.dart';
import 'generate_trip_repo.dart';
import 'search_trip_controller.dart';
import 'search_trip_repo.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Trips',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Generate Trip Card
            _buildTripCard(
              context: context,
              imagePath: 'assets/images/generate_trip.png',
              title: 'Generate Trip',
              onTap: () {
                // Ensure controller is available
                Get.lazyPut(() => GenerateTripController(
                  generateTripRepo: GenerateTripRepo(
                    apiClient: Get.find(), 
                    sharedPreferences: Get.find()
                  )
                ));
                Get.toNamed(RouteHelper.getGenerateTripScreen());
              },
            ),
            
            const SizedBox(height: 16),
            
            // Search Trip Card
            _buildTripCard(
              context: context,
              imagePath: 'assets/images/search_trip.png',
              title: 'Search Trip',
              onTap: () {
                // Ensure controller is available
                Get.lazyPut(() => SearchTripController(
                  searchTripRepo: SearchTripRepo(
                    apiClient: Get.find(), 
                    sharedPreferences: Get.find()
                  )
                ));
                Get.toNamed(RouteHelper.getSearchTripScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard({
    required BuildContext context,
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image placeholder (you can replace with actual asset)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                title == 'Generate Trip' ? Icons.local_shipping : Icons.search,
                size: 40,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 20),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // Arrow icon
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
