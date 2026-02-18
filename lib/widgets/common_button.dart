import 'dart:core';

import 'package:flutter/material.dart';

import '../utils/responsive.dart';
import '../utils/tap_throttle.dart';


class CommonBtn extends StatefulWidget {
  const CommonBtn(
      {super.key,
      this.btnWidth = 15,
      this.btnHeight = 10,
      this.btnPadding = 10,
      this.borderColor = Colors.transparent,
      this.borderWidth = 2,
      this.backColor = Colors.transparent,
      this.title = '',
      this.txtColor = Colors.white,
      this.fWeight = FontWeight.normal,
      this.fSize = 12,
      this.btnRadius = 0,
      this.image = false,
      this.widget,
      this.gradient = const LinearGradient(
        colors: [Colors.transparent, Colors.transparent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      this.onTap});

  final double btnWidth;
  final double btnHeight;
  final double btnPadding;
  final Color borderColor;
  final double borderWidth;
  final Color backColor;
  final String title;
  final Color txtColor;
  final FontWeight fWeight;
  final double fSize;
  final double btnRadius;
  final bool image;
  final Widget? widget;
  final Gradient? gradient;
  final void Function()? onTap;


  @override
  State<CommonBtn> createState() => _CommonBtnState();
}

class _CommonBtnState extends State<CommonBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: scrSize(widget.btnWidth),
      height: scrSize(widget.btnHeight),
      decoration: BoxDecoration(
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(scrSize(widget.btnRadius))
      ),
      child: InkWell(
        onDoubleTap: (){},
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(scrSize(widget.btnPadding)),
            backgroundColor: widget.backColor,
            elevation: 0,
              shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(scrSize(widget.btnRadius)),
                side: BorderSide(color: widget.borderColor,width: scrSize(widget.borderWidth)),
            )
          ),
          onPressed: () {
            if (widget.onTap != null && TapThrottle.canTap()) {
              widget.onTap!();
            }
          },
          child: Center(
            child: widget.widget??(widget.image?Image.asset(widget.title):Text(
              widget.title,
              style: TextStyle(
                  color: widget.txtColor,
                  fontWeight: widget.fWeight,
                  fontSize: fontSize(widget.fSize)),
            )),
          ),
        ),
      ),
    );
  }
}