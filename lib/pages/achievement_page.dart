import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
 
  int pointsCount = 0;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Row( 
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // BackButton(),
            SizedBox(),
            Text("Rewards" ,
            style: GoogleFonts.roboto(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  textStyle: const TextStyle(
                    fontSize: 20,
                  ),
                ),),
           
            Text("MY POINTS ($pointsCount)" ,
            style: GoogleFonts.roboto(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  textStyle: const TextStyle(
                    fontSize: 15,
                  ),
                ),),
        
          ],
        ),
      ),
    );
  }
}