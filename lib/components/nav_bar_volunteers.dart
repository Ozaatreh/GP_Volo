import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/pages/achievement_page.dart';
import 'package:graduation_progect_v2/pages/profile_pages/profile_volunteer.dart';
import 'package:graduation_progect_v2/pages/volunteer_page.dart';


class VolunteerNavigation extends StatefulWidget {
  const VolunteerNavigation({super.key});

  @override
  State<VolunteerNavigation> createState() => _VolunteerNavigationState();
}

class _VolunteerNavigationState extends State<VolunteerNavigation> {
 
  int selectedIndex = 1;
  

  // List of pages to display based on selected index
  final List<Widget> pages = [
    AchievementPage(),
    UserPage(),
    VolunteerProfile(),
  ];

  // pages changer
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
    onWillPop: () async {
      // Handle custom back navigation logic here if needed
      // Returning `true` will allow the back action
      return false;
    },
      child: Scaffold(
          
          body: pages[selectedIndex],
      
          bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          selectedItemColor:Theme.of(context).colorScheme.inversePrimary ,
          unselectedItemColor:Theme.of(context).colorScheme.surface,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items:  [
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_outlined),
              label: 'Achievement'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account'.tr(),
            ),
          ],
        ),
      
      
      ),
    );
  }
}