import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/dimensions.dart';


void customSnackBar(String? message, {bool isError = true}) {
  if(message != null && message.isNotEmpty) {
    Get.snackbar(
      isError ? "Error" : "Success",
      message,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      maxWidth: Get.width,
      duration: const Duration(seconds: 2),
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
      borderRadius: 5,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }
}