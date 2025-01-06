import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/pages/university_page.dart';
import 'package:graduation_progect_v2/pages/profile_pages/profile_university.dart';
import 'package:graduation_progect_v2/pages/wall_page.dart';

class UniversityNavigation extends StatefulWidget {
  const UniversityNavigation({super.key});

  @override
  _UniversityNavigationState createState() => _UniversityNavigationState();
}

class _UniversityNavigationState extends State<UniversityNavigation> {
  int _currentIndex = 0; // To track the selected tab

  // List of pages for navigation
  final List<Widget> _pages = [
     WallPage(), // Main university page
     UniversityPage(),     // A placeholder for events
     UniversityProfile(),    // User profile page
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
    onWillPop: () async {
      // Handle custom back navigation logic here if needed
      // Returning `true` will allow the back action
      return false;
    },
      child: Scaffold(
        body: _pages[_currentIndex], // Display the current page
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex, // Highlight the selected tab
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Update the selected tab
            });
          },
          items:  [
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Events'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile'.tr(),
            ),
          ],
          selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
          unselectedItemColor:Theme.of(context).colorScheme.surface,
          showSelectedLabels: true,
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}