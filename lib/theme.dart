import 'package:flutter/material.dart';

const primaryColor = Colors.black;

final themeData = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  canvasColor: Colors.grey[50],
  shadowColor: Color.fromARGB(30, 100, 100, 100),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: "Poppins",
  primaryIconTheme: IconThemeData(
    color: primaryColor,
  ),
  primaryTextTheme: TextTheme(
  // for AppBar title theme
    headline6: TextStyle(
      fontWeight: FontWeight.w600,
      color: primaryColor,
    ),
  ),
  textTheme: TextTheme(
    headline1: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    headline2: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    headline3: TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    headline4: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    subtitle1: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.normal,
      color: primaryColor,
    ),
    bodyText1: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primaryColor,
    ),
    bodyText2: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    button: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.bold,
    ),
  ),
  appBarTheme: AppBarTheme(
    color: Colors.grey[50],
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(width: 5.0)),
      side: BorderSide(color: primaryColor, width: 2.0),
      primary: primaryColor,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      primary: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    titleTextStyle: TextStyle(
      color: primaryColor,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
  ),
);
