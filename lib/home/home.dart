import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:opsapp/destination_handling/destination_handling_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../destination_handling/destination_handling_repo.dart';
import '../login/auth_controller.dart';
import '../trips/generate_trip_controller.dart';
import '../trips/generate_trip_repo.dart';
import '../utils/images.dart';
import '../utils/route_helper.dart';
import '../utils/app_constants.dart';
import '../widgets/loading_indicator.dart';
import '../utils/responsive.dart';
import '../utils/styles.dart';
import 'preferences_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  final List<_FeatureItem> featureItems = [
    _FeatureItem('Parcel Search', Images.parcelSearch),
    _FeatureItem('Destination Handling', Images.destinationHandling),
    _FeatureItem('Trips', Images.trips),
    _FeatureItem('Returns', Images.returns),
    _FeatureItem('Parcel Inbound', Images.parcel_inbound),
    _FeatureItem('Sortation', Images.sortation),
  ];
  String selectedOperation = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSelectedOperation();
    Get.find<AuthController>().updateUserEntities();
  }

  void getSelectedOperation() async {
    final operation = await Get.find<AuthController>().getSelectedOperation();

    setState(() {
      selectedOperation = operation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: AutoSizeText(
          'Select location and process',
          style: robotoBold.copyWith(
            fontSize: fontSize(18),
            color: Colors.black,
          ),
        ),
        /*actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],*/
      ),
        drawer: Drawer(
          backgroundColor: Colors.white, // Light background
          child: Column(
            children: <Widget>[
              // Header with logo and close button
              Container(
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    // Row(
                    //   children: [
                    //     Text(
                    //       'SHIPA',
                    //       style: TextStyle(
                    //         color: Colors.black,
                    //         fontSize: 24,
                    //         fontWeight: FontWeight.bold,
                    //         letterSpacing: 2,
                    //       ),
                    //     ),
                    //     Text(
                    //       '/ECOMMERCE',
                    //       style: TextStyle(
                    //         color: Colors.green,
                    //         fontSize: 24,
                    //         fontWeight: FontWeight.bold,
                    //         letterSpacing: 1,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: 100,
                      child: Image.asset(
                        Images.logo,
                        // scale: 3,
                        // color: Theme.of(context).primaryColor,
                      ),
                    ),

                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black, size: 30),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Colors.grey, thickness: 0.5),
              
              // Menu items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Select location and process
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.green, size: 20),
                      title: const Text(
                        'Select location and process',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to location selection screen
                      },
                    ),
                    
                    // Preference
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.green, size: 20),
                      title: const Text(
                        'Preference',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to preferences screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PreferencesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Signout button at bottom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      // Close drawer
                      Navigator.pop(context);
                      
                      // Show confirmation dialog
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      
                      if (shouldLogout == true) {
                        try {
                          // Clear user data in AuthController
                          final authController = Get.find<AuthController>();
                          authController.clearUserData();
                          
                          // Get SharedPreferences instance directly
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove(AppConstants.token);
                          await prefs.remove(AppConstants.entities);
                          await prefs.remove(AppConstants.userId);
                          await prefs.remove(AppConstants.userName);
                          
                          // Navigate to login screen
                          Get.offAllNamed('/login');
                        } catch (e) {
                          print('Error during logout: $e');
                          // Still navigate to login even if there's an error
                          Get.offAllNamed('/login');
                        }
                      }
                    },
                    child: const Text(
                      'Signout',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      body: GetBuilder<AuthController>(builder: (controller) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'Hi, ',
                          children: [
                            TextSpan(
                              text: controller.userName,
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(selectedOperation, style: const TextStyle(fontSize: 16)),
                          const Text("SEC SDEV (v4.0)", style: TextStyle(fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Location Dropdown
                  if(controller.selectedEntity!.isNotEmpty)Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedEntity,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (String? newValue) {
                            controller.selectedEntity = newValue!;
                            controller.update();
                        },
                        items: controller.userEntities.map((String location) {
                          return DropdownMenuItem<String>(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grid of Feature Cards
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: featureItems.map((item) => _buildFeatureCard(item)).toList(),
                    ),
                  ),
                ],
              ),
            ),
            controller.isLoading
                ? const LoadingIndicator()
                : const SizedBox(),
          ],
        );
      }),


    );
  }

  Widget _buildFeatureCard(_FeatureItem item) {
    return GestureDetector(
      onTap: () {
        // Handle navigation or function call
        print(item.title);
        String itemClicked = item.title;

        if (itemClicked == "Parcel Search") {
          Get.toNamed(RouteHelper.getSearchParcelScreen());
        } else if (itemClicked == "Destination Handling") {
          Get.lazyPut(()=>DestinationHandlingController(destinationHandlingRepo: DestinationHandlingRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
          Get.toNamed(RouteHelper.getDestinationHandlingScreen());
        }
        else if (itemClicked == "Trips") {
          Get.lazyPut(()=>GenerateTripController(generateTripRepo: GenerateTripRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
          Get.toNamed(RouteHelper.getTripsScreen());
        }
        else if (itemClicked == "Returns") {

        }
        else if (itemClicked == "Parcel Inbound") {
          final authController = Get.find<AuthController>();
          authController.okCount.value = 0;
          authController.holdCount.value = 0;
          authController.condition = "OK";
          authController.update();

          Get.toNamed(RouteHelper.getParcelInboundScreen());
        }else if (itemClicked == "Sortation") {
          Get.toNamed(RouteHelper.getSortationScreen());
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String imagePath;
  _FeatureItem(this.title, this.imagePath);
}
