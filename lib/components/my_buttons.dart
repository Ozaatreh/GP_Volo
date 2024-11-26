import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key,required this.buttonText , required this.onTap });
  
  final Function()? onTap ;
  final String buttonText ;


  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
     onTap: onTap ,
     child: Container(
      
      decoration:  BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(12)) ,
      ),

      padding: const EdgeInsets.all(25),
      child: Center(child: Text( buttonText , style: const TextStyle(fontSize: 16,),)),
      
     ),
    );
  }
}