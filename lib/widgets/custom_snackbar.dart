import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/dimensions.dart';


void customSnackBar(String? message, {bool isError = true}) {
  if (message != null && message.isNotEmpty) {
    try {
      Get.rawSnackbar(
        title: isError ? "Error" : "Success",
        message: message,
        backgroundColor: isError ? Colors.red.withOpacity(0.8) : Colors.green.withOpacity(0.8),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
      );
    } catch (e) {
      debugPrint("Error showing customSnackBar: $e");
    }
  }
}
