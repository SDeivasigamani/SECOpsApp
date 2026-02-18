import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';


class LoadingGauge {
  void showLoader(BuildContext context) {
    Loader.show(
      context,
      overlayFromTop: 0.0,
      progressIndicator: CircularProgressIndicator(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      themeData: Theme.of(context).copyWith(hintColor: Theme.of(context).primaryColorLight),


    );
  }
  void hideLoader() {
    Loader.hide();
  }

}