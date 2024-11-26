import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextfield extends StatelessWidget {
  const MyTextfield({super.key, required this.hintText, required this.obscuretext, required this.controller});
  
  final String hintText ;
  final bool obscuretext ;
  final TextEditingController controller ;
  @override
  Widget build(BuildContext context) {
    return  TextField(
      enableInteractiveSelection: true,
      style: GoogleFonts.roboto(fontWeight: FontWeight.w300),
      controller: controller,
      decoration:  InputDecoration(
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))) ,
        hintText: hintText  ,
      ),
     obscureText: obscuretext,

    );
  }
}