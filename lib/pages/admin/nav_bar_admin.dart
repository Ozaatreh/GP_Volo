import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/pages/admin/admin_wall.dart';
import 'package:graduation_progect_v2/pages/admin/posts_active.dart';
import 'package:graduation_progect_v2/pages/admin/posts_archive.dart';


class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => AdminNavigationState();
}

class AdminNavigationState extends State<AdminNavigation> {
 int selectedIndex = 1;
 
  // List of pages to display based on selected index
  final List<Widget> pages = [
     AdminWall(),
     ActiveEvents(),
     PostArchive(),
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
        selectedItemColor:const Color.fromARGB(255, 228, 187, 6) ,
        unselectedItemColor: Theme.of(context).colorScheme.inversePrimary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items:  [
          BottomNavigationBarItem(
            icon: Icon(Icons.panorama_wide_angle_outlined),
            label: 'Admin Wall',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.blur_on_outlined),
            label: 'Active Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            label: 'Events Archive',
          ),
        ],
      ),

    );
    }
}
    
   