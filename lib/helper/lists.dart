

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class MyWidget extends StatefulWidget {
//   const MyWidget({super.key});

//   @override
//   State<MyWidget> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<MyWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<String>(
//                   color: Theme.of(context).colorScheme.inverseSurface,
//                   onSelected: (value) {
//                     setState(() {
//                       selectedCity = value;
//                     });
//                   },
//                   itemBuilder: (context) => [
//                     PopupMenuItem(
//                       value: "Amman",
//                       child: Column(
//                         children: [
//                           Text("Amman"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "Irbid",
//                       child: Column(
//                         children: [
//                           Text("Irbid"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "Zarqa",
//                       child: Column(
//                         children: [
//                           Text("Zarqa"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "Balqa",
//                       child: Column(
//                         children: [
//                           Text("Balqa"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "Madaba",
//                       child: Column(
//                         children: [
//                           Text("Madaba"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "Aqaba",
//                       child: Column(
//                         children: [
//                           Text("Aqaba"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "Mafraq",
//                       child: Column(
//                         children: [
//                           Text("Mafraq"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "Jerash",
//                       child: Column(
//                         children: [
//                           Text("Jerash"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "Ajloun",
//                       child: Column(
//                         children: [
//                           Text("Ajloun"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "Karak",
//                       child: Column(
//                         children: [
//                           Text("Karak"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "Tafilah",
//                       child: Column(
//                         children: [
//                           Text("Tafilah"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "Ma'an",
//                       child: Column(
//                         children: [
//                           Text("Ma'an"),
//                           SizedBox(height: 10),
//                           Divider(height: 5),
//                         ],
//                       ),
//                     ),
//                   ],
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: Theme.of(context).colorScheme.inversePrimary,
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           selectedCity ?? "Select City",
//                           style: GoogleFonts.roboto(
//                             fontWeight: FontWeight.w300,
//                             fontSize: 16,
//                             color: Theme.of(context).colorScheme.inversePrimary,
//                           ),
//                         ),
//                         Icon(Icons.arrow_drop_down),
//                       ],
//                     ),
//                   ),
//                 ),
// }
// } 