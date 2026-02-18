import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> isOnline = ValueNotifier(false);
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Update online/offline status
      isOnline.value = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
