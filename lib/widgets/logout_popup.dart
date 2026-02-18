
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../login/auth_controller.dart';
import '../utils/responsive.dart';
import '../utils/route_helper.dart';
import 'common_button.dart';
import 'custom_button.dart';


logoutPopup (){
  showModalBottomSheet(
      context: Get.context!,isDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async{
            Get.back();
            return false;
          },
          child: SizedBox(
            height: scrSize(177),
            child: Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: scrSize(358),
                    child: AutoSizeText(
                      'Are you sure you want to logout your account?',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: fontSize(20),
                          color: Theme.of(context).primaryColorDark),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      minFontSize: 1,
                    ),
                  ),
                  SizedBox(
                    width: scrSize(325),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonBtn(
                          btnWidth: 150,
                          btnHeight: 50,
                          borderColor: Theme.of(context).primaryColor,
                          borderWidth: 1.5,
                          btnRadius: 12,
                          title: 'No',
                          txtColor: Theme.of(context).primaryColor,
                          fWeight: FontWeight.w500,
                          fSize: 16,
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        CommonBtn(
                          btnWidth: 150,
                          btnHeight: 50,
                          borderWidth: 2,
                          title: 'Yes',
                          txtColor: Theme.of(context).cardColor,
                          fWeight: FontWeight.w500,
                          backColor: Theme.of(context).primaryColor,
                          btnRadius: 12,
                          fSize: 16,
                          onTap: (){
                            Navigator.pop(context);
                            Get.find<AuthController>().clearSharedData();
                            Get.offAllNamed(RouteHelper.getSignInRoute('splash'));
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
  );
}