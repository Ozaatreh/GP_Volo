import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/pages/ngo_page.dart';
import 'package:graduation_progect_v2/pages/profile_pages/profile_ngo.dart';
import 'package:graduation_progect_v2/pages/wall_page.dart';

class NGONavigation extends StatefulWidget {
   const NGONavigation({super.key});

  @override
  State<NGONavigation> createState() => _NGONavigationState();
}

class _NGONavigationState extends State<NGONavigation> {
  int selectedIndex = 1;
  

    // List of pages to display based on selected index
  final List<Widget> pages = [
    WallPage(),
    NgoPage(),
    NGOProfile(),
  ];

  // pages changer
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(


      
      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        selectedItemColor:Theme.of(context).colorScheme.inversePrimary ,
        unselectedItemColor: const Color.fromARGB(255, 33, 33, 191),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.panorama_wide_angle_outlined),
            label: 'App Wall',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            // activeIcon: Text('data'),
            icon: Icon(Icons.account_box_outlined),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}