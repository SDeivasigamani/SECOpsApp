import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/images.dart';
import '../utils/responsive.dart';

class EasyTextField extends StatefulWidget {
  const EasyTextField(
      {super.key,
      required this.width,
      required this.height,
      this.borderColor = Colors.transparent,
      this.bgColor = Colors.transparent,
      this.hintColor = Colors.grey,
      this.borderWidth = 0,
      this.fontSize = 16,
      this.topPadding = 4,
      this.iconsMaxHeight = 40,
      this.rightPadding = 16,
      this.leftPadding = 10,
      this.borderRadius = 0,
      this.errorFontSize = 12,
      this.controller,
      this.hintTxt = '',
      this.onChange,
      this.protectPassword = false,
        this.suffixIcon,
      this.validation,
      this.keyboardType,
        this.expands=false,
        this.center=true,
        // this.showValidation=false,
        this.bottomPadding=16,
        this.readOnly=false,
        this.secureState=false,
        this.isDense=true,
        this.focusNode,
      this.prefixIcon});

  final double width;
  final double height;
  final double topPadding;
  final double rightPadding;
  final double leftPadding;
  final double iconsMaxHeight;
  final double fontSize;
  final Color borderColor;
  final Color bgColor;
  final double borderWidth;
  final double borderRadius;
  final TextEditingController? controller;
  final String hintTxt;
  final Color hintColor;
  final bool protectPassword;
  final double errorFontSize;
  final String? validation;
  final ValueChanged<String>? onChange;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final bool center;
  final bool expands;
  final double? bottomPadding;
  final bool readOnly;
  final bool secureState;
  final FocusNode? focusNode;
  final bool isDense;
  // final bool? showValidation;

  @override
  State<EasyTextField> createState() => _EasyTextFieldState();
}

bool showValidation = false;

class _EasyTextFieldState extends State<EasyTextField> {
  bool obSecure = false;
  // bool showValidation = true;
  int _linesCount = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    obSecure = widget.secureState;

    // widget.controller?.addListener(_updateLineCount);
  }

  void _updateLineCount() {
    final text = widget.controller?.text!;
    final lines = '\n'.allMatches(text!).length + 1; // Count the number of newlines
    if (lines != _linesCount) {
      setState(() {
        _linesCount = lines;

        print("_linesCount: $_linesCount");
      });
    }
  }

  // @override
  // void dispose() {
  //   widget.controller?.removeListener(_updateLineCount);
  //   widget.controller?.dispose();
  //   super.dispose();
  // }


  Widget txtField (){
    return TextFormField(
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      expands: widget.expands,
      controller: widget.controller,
      obscureText: obSecure,
      maxLines: widget.expands?null:1,
      keyboardType: widget.keyboardType,
      style: TextStyle(fontSize: fontSize(widget.fontSize)),
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: widget.onChange,
      validator: (value){
        return widget.validation;
      },
      // validator: (value) {
      //
      //   return widget.validation;
      //   // setState(() {
      //   //   // showValidation = true;
      //   // });
      // },
      textAlignVertical: widget.isDense?TextAlignVertical.center:TextAlignVertical.top,
      decoration: InputDecoration(
          isDense: widget.isDense,
          border: InputBorder.none,
          hintText: widget.hintTxt,
          hintStyle: TextStyle(color: widget.hintColor,fontSize: fontSize(widget.fontSize)),
          errorText: 'checking',
          errorStyle: const TextStyle(fontSize: 0),
          suffixIcon: widget.suffixIcon ?? const SizedBox(),
          prefixIcon: Padding(
            padding: EdgeInsets.only(right: scrSize(6)),
            child: widget.prefixIcon ?? const SizedBox(),
          ),
          suffixIconColor: Theme.of(context).primaryColorDark,
          prefixIconColor: Theme.of(context).primaryColorDark,
          prefixIconConstraints: BoxConstraints(maxHeight: scrSize(widget.iconsMaxHeight)),
          suffixIconConstraints: BoxConstraints(maxHeight: scrSize(widget.iconsMaxHeight))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: scrSize(widget.width),
          height: scrSize(widget.height),
          padding: EdgeInsets.only(
              left: widget.prefixIcon ==null ?scrSize(16):scrSize(widget.leftPadding),
              right: widget.protectPassword ? 0 : scrSize(widget.rightPadding)),
          decoration: BoxDecoration(
              border: Border.all(
                  color: widget.borderColor,
                  width: scrSize(widget.borderWidth)),
              borderRadius: BorderRadius.circular(scrSize(widget.borderRadius)),
              color: widget.bgColor),
          child: widget.center?Center(
            child: txtField(),
          ):txtField(),
        ),
        if(showValidation)Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.validation == null)
                ? SizedBox(
                    height: scrSize(widget.bottomPadding!),
                  )
                :  const SizedBox(),
            (widget.validation != null)
                ? Container(
                    padding: EdgeInsets.only(left: scrSize(2), right: scrSize(16)),
                    child: Text(
                      widget.validation ?? '',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: scrSize(widget.errorFontSize+2)),
                    ))
                : const SizedBox(),
          ],
        )
      ],
    );
  }
}
