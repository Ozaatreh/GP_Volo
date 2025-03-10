import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  const MyBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container( 
      decoration: BoxDecoration(
        //  color: Theme.of(context).colorScheme.onPrimary,
         shape: BoxShape.circle),
      padding: EdgeInsets.all(10),
      child: Icon(Icons.arrow_back_rounded ,
      color: Theme.of(context).colorScheme.inversePrimary, ),
    ),
    );
  }
}