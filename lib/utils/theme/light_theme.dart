import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

ThemeData light = ThemeData(
  useMaterial3: true,
  fontFamily: 'URWGeometric',
  primaryColor: HexColor('#44C058'),
// primaryColor: const Color(0xFFFF0168),
  primaryColorLight: HexColor('#FDFBFF'),
// primaryColorLight: HexColor('#F8F9FF'),
  // primaryColorLight: const Color(0xffE4E5EB),
  dividerColor: HexColor('#F8F9FF'),
  primaryColorDark: Colors.black,
  secondaryHeaderColor:  HexColor('#F3E7FF'),
    disabledColor: const Color(0xFFA6A8B2),
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),

  brightness: Brightness.light,
  hintColor: HexColor('#535353').withOpacity(.7),
  focusColor: Colors.transparent,
  hoverColor: Colors.transparent,
  unselectedWidgetColor: HexColor('#F8F8F8').withOpacity(.7),
  shadowColor: Colors.grey[300],
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  cardColor: Colors.white,
  appBarTheme: const AppBarTheme(color: Color(0xFFFDFBFF)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(),
  sliderTheme: const SliderThemeData(
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10)),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF0461A5))),
  colorScheme: const ColorScheme.light(
          primary: Color(0xFF0B2677),
          secondary: Color(0xFFFF9900),
          outline: Color(0xFFFDCC0D),
          error: Color(0xFFFF6767),
          surface: Color(0xffFCFCFC),
          tertiary: Color(0xFFd35221))
      .copyWith(surface: const Color(0xffFCFCFC))
      .copyWith(error: const Color(0xFFFF6767)),
);