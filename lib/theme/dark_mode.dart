import 'package:flutter/material.dart'; 

ThemeData darkMode =ThemeData(
brightness: Brightness.dark,
colorScheme: ColorScheme.dark(
  surface: Colors.grey.shade900,
  primary:  Colors.grey.shade800,
  secondary:  Colors.grey.shade700,
  inversePrimary: Colors.grey[200],
  inverseSurface:  const Color.fromARGB(255, 62, 58, 58),
  ),

  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey[200],
    displayColor: Colors.white,
  )

);