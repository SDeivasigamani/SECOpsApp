import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_beep/flutter_beep.dart';

class BarcodeScannerScreen extends StatelessWidget {
  final Function(String) onDetect;

  BarcodeScannerScreen({required this.onDetect});
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Barcode")),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          if (_isScanned) return;

          final List<Barcode> barcodes = barcodeCapture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? rawValue = barcodes.first.rawValue;
            if (rawValue != null) {
              FlutterBeep.beep();
              _isScanned = true;
              onDetect(rawValue);
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}