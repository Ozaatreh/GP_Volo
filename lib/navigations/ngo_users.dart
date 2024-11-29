import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/components/nav_bar_leader.dart';
import 'package:graduation_progect_v2/components/nav_bar_ngo.dart';
import 'package:graduation_progect_v2/components/nav_bar_users.dart';
import 'package:graduation_progect_v2/pages/admin/nav_par_admin.dart';
import 'package:graduation_progect_v2/pages/admin/posts_active.dart';
import 'package:graduation_progect_v2/pages/auth_pages/login_page.dart';
import 'package:graduation_progect_v2/pages/admin/posts_archive.dart';


class AllUsersToggle extends StatefulWidget {
  const AllUsersToggle({super.key});

  @override
  State<AllUsersToggle> createState() => _AllUsersToggleState();
}

class _AllUsersToggleState extends State<AllUsersToggle> {
  // Call this function during initialization
  @override
  void initState() {
    super.initState();
    navigateBasedOnUserType();
  }

  // Function to check user type and navigate accordingly
  Future<void> navigateBasedOnUserType() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Fetch the user type from Firestore
        final userDoc =
            await FirebaseFirestore.instance.collection('Users').doc(user.email).get();

        // Check if the document exists and retrieve userType
        if (userDoc.exists) {
          final userType = userDoc['userType'];

          // Navigate based on user type
          if (userType == 'Ngo') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NGONavigation()),
            );
          } else if (userType == 'Leader') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>LeaderNavigation()),
            );
          }else if (userType == 'Volunteer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  UserNavigation()),
            );
            }else if (userType == 'Admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  AdminNavigation()),
            );
            }else {
            _showError("Invalid user type.");
          }
        } else {
          _showError("User document not found.");
        }
      } catch (e) {
        _showError("Error retrieving user type: $e");
      }
    } else {
      // If no user is logged in, navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  // Function to show error dialog
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading screen while the navigation is determined
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
