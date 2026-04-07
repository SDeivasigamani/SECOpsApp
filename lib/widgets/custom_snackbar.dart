import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/dimensions.dart';


void customSnackBar(String? message, BuildContext context, {bool isError = true}) {
  if (message != null && message.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
