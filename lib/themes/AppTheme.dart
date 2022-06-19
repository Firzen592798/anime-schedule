import 'package:flutter/material.dart';

class AppTheme{
  ThemeData themedata = ThemeData(
    appBarTheme: AppBarTheme(
      color: Colors.teal,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
            onPrimary: Colors.white,
            primary: Colors.lightGreen[900],
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          ),

    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.teal,
        ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colors.grey,
      cursorColor: Color(0xff171d49),
      selectionHandleColor: Color(0xff005e91),
    ),
    scaffoldBackgroundColor: Colors.amber[50],
    floatingActionButtonTheme:
      FloatingActionButtonThemeData (backgroundColor: Colors.blue,focusColor: Colors.blueAccent , splashColor: Colors.lightBlue),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
    textTheme: TextTheme(
      bodyText1: TextStyle(
        fontSize: 22,
      ),
      bodyText2: TextStyle(
        fontSize: 16,
      ),
    ).apply(
      bodyColor: Colors.black87,
      fontFamily: "Roboto",

    ));
}