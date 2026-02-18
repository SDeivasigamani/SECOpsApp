import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> showPermissionDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Microphone Permission Required"),
      content: Text(
        "The app needs microphone access to record audio. Please enable it in the app settings.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await openAppSettings();
          },
          child: Text("Open Settings"),
        ),
      ],
    ),
  );
}
