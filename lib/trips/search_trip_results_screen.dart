import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:intl/intl.dart';
import 'search_trip_controller.dart';
import 'trip_results_model.dart';

class SearchTripResultsScreen extends StatelessWidget {
  const SearchTripResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchTripController>(
      builder: (controller) {
        final trips = controller.tripData?.matches ?? [];

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
              'Results',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          body: trips.isEmpty
              ? const Center(child: Text("No trips found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return _buildTripCard(trip);
                  },
                ),
        );
      },
    );
  }

  Widget _buildTripCard(Matches trip) {
    // Extract trip data
    String tripId = trip.id ?? '';
    String createdDate = trip.createdOn ?? '';
    String deliveryDate = trip.estimatedDeliveryTime ?? '';
    List<String> trackingNumbers = trip.trackingNumbers ?? [];
    String truckId = trip.truckId ?? '';
    String notes = trip.note ?? '';

    // Format dates
    String formattedCreatedDate = '';
    String formattedDeliveryDate = '';
    
    try {
      if (createdDate.isNotEmpty) {
        DateTime dt = DateTime.parse(createdDate);
        formattedCreatedDate = DateFormat('dd-MMM-yyyy hh:mma').format(dt);
      }
    } catch (e) {
      formattedCreatedDate = createdDate;
    }

    try {
      if (deliveryDate.isNotEmpty) {
        DateTime dt = DateTime.parse(deliveryDate);
        formattedDeliveryDate = DateFormat('dd-MMM-yyyy hh:mma').format(dt);
      }
    } catch (e) {
      formattedDeliveryDate = deliveryDate;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barcode
          if (tripId.isNotEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: tripId,
                  width: 250,
                  height: 80,
                  drawText: true,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Created Date and Delivery Date
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Created Date:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedCreatedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Date:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDeliveryDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Trip ID
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Trip ID: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  tripId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tracking Numbers
          if (trackingNumbers.isNotEmpty) ...[
            Text(
              'Tracking Number(s):',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              trackingNumbers.join(', '),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Truck ID
          if (truckId.isNotEmpty) ...[
            Text(
              'Truck ID:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              truckId,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Notes
          if (notes.isNotEmpty) ...[
            Text(
              'Notes:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notes,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
