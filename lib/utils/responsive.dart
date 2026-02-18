import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

scrSize(double size){
  double ratio = Get.width / 390;
  return ratio * size;
}
fontSize(double size){
  double ratio = Get.width / 390;
  double fRatio = ratio * 0.97;
  return fRatio * size;
}
fPrint(content){
  if (kDebugMode) {
    print(content);
  }
}
extension StringCasingExtension on String {
  String get toCapitalized => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String get toTitleCase => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized).join(' ');
}
