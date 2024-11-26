import 'package:flutter/material.dart'; 

ThemeData lightMode =ThemeData(
brightness: Brightness.light,
colorScheme: ColorScheme.light(
  surface: const Color.fromARGB(255, 132, 175, 200),
  primary:  Colors.grey.shade200,
  secondary:  const Color.fromARGB(255, 48, 47, 47),
  inversePrimary:  const Color.fromARGB(255, 0, 0, 0),
  inverseSurface:  const Color.fromARGB(255, 82, 142, 195),
  ),

  textTheme:ThemeData.light().textTheme.apply(
    bodyColor: Colors.grey[800],
    displayColor: Colors.black,
  )

);