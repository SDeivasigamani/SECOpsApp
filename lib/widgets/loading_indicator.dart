import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double strokeWidth;
  const LoadingIndicator({super.key, this.color, this.strokeWidth = 4});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
            color: color ??
                (Get.isDarkMode
                    ? Colors.green
                    : HexColor('#CC579B')),
            strokeWidth: strokeWidth));
  }
}

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


