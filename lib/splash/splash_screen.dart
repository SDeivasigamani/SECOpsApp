import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/auth_controller.dart';
import '../utils/route_helper.dart';
import '../utils/images.dart';
import 'controller/splash_controller.dart';
import '../utils/globals.dart' as globals;

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  bool isBusy = false;

  @override
  void initState() {
    super.initState();

    _route();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _route() async {
    Timer(const Duration(seconds: 3), () async {
      if (Get.find<AuthController>().isLoggedIn()) {

        Get.offAllNamed(RouteHelper.getUsersHome());
      } else {
        Get.offAllNamed(RouteHelper.getSignInRoute('splash'));
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: Theme.of(context).cardColor,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Images.logo,
                    // color: Colors.white,
                    width: MediaQuery.of(context).size.width / 2.2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SplashCustomPainter extends CustomPainter {
  final BuildContext? context;

  SplashCustomPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    Paint leftCorner = Paint();
    leftCorner.color = Theme.of(context!).primaryColor.withOpacity(.3);
    Path path = Path();
    path.lineTo(0, 170);
    //Added this line
    path.relativeQuadraticBezierTo(100, -20, 110, -170);
    canvas.drawPath(path, leftCorner);
    Paint paint = Paint();

    // Path number 3
    paint.color = Theme.of(context!).primaryColor.withOpacity(.3);
    path = Path();
    path.lineTo(size.width, size.height / 3);
    path.cubicTo(size.width * 1.8, size.height * 0.5, size.width / 2,
        size.height, size.width / .99, size.height);
    path.cubicTo(size.width, 10, size.width, size.height / 10, size.width,
        size.height / 3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SplashCustomPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(SplashCustomPainter oldDelegate) => false;
}
