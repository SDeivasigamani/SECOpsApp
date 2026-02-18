

import 'package:get/get.dart';
import 'package:opsapp/home/home.dart';
import 'package:opsapp/search_parcel/search_parcel.dart';
import 'package:opsapp/splash/splash_screen.dart';

import '../login/login.dart';
import '../parcel_inbound/parcel_inbound.dart';
import '../sortation/sortation.dart';
import '../destination_handling/destination_handling_screen.dart';
import '../trips/trips_screen.dart';
import '../trips/generate_trip_screen.dart';
import '../trips/search_trip_screen.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String signIn = '/login';

  static const String messages = '/messages';
  static const String userChat = '/user-chat';
  static const String profile = '/profile';
  static const String patientInfo = '/patient-info';

  static const String home = '/home';
  static const String search_parcel = '/search_parcel';
  static const String parcel_inbound = '/parcel_inbound';
  static const String sortation = '/sortation';
  static const String destination_handling = '/destination_handling';
  static const String trips = '/trips';
  static const String generate_trip = '/generate_trip';
  static const String search_trip = '/search_trip';

  static String getInitialRoute() => initial;
  static String getSplashRoute() => splash;
  static String getSignInRoute(String page) => '$signIn?page=$page';
  static String getUsersRoute() => userChat;
  static String getProfileScreen() => profile;
  static String getPatientInfo() => patientInfo;

  static String getUsersHome() => home;
  static String getSearchParcelScreen() => search_parcel;
  static String getParcelInboundScreen() => parcel_inbound;
  static String getSortationScreen() => sortation;
  static String getDestinationHandlingScreen() => destination_handling;
  static String getTripsScreen() => trips;
  static String getGenerateTripScreen() => generate_trip;
  static String getSearchTripScreen() => search_trip;

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(
        name: signIn,
        page: () => const SignInScreen()),

    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: search_parcel, page: () => SearchParcelScreen()),
    GetPage(name: parcel_inbound, page: () => const ParcelInboundScreen()),
    GetPage(name: sortation, page: () => const SortationScreen()),
    GetPage(name: destination_handling, page: () => const DestinationHandlingScreen()),
    GetPage(name: trips, page: () => const TripsScreen()),
    GetPage(name: generate_trip, page: () => const GenerateTripScreen()),
    GetPage(name: search_trip, page: () => const SearchTripScreen()),
  ];
}