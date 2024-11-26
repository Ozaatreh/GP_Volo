import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_progect_v2/pages/edit_profile.dart';

class VolunteerProfile extends StatefulWidget {
  const VolunteerProfile({super.key});

  @override
  _VolunteerProfileState createState() => _VolunteerProfileState();
}

class _VolunteerProfileState extends State<VolunteerProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('Users').doc(user!.email).get();
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  Future<void> _navigateToEditProfile() async {
    if (user != null && userData != null) {
      final updatedData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(
            userType: 'Volunteer',
            userData: userData!,
            userId: user!.uid,
          ),
        ),
      );

      // Update the profile data on return
      if (updatedData != null) {
        setState(() {
          userData = updatedData;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text('No user data found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Volunteer Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blue[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Volunteer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: userData!['profilePicture'] != null
                    ? NetworkImage(userData!['profilePicture'])
                    : const AssetImage('assets/photo_2024-11-02_19-33-14.jpg') as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Center(
              child: Text(
                userData!['name'] ?? 'No Name',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Email
            Center(child: Text(userData!['email'] ?? 'No Email')),
            const SizedBox(height: 16),

            // Phone Number
            ListTile(
              title: const Text('Phone'),
              subtitle: Text(userData!['phone'] ?? 'No Phone'),
            ),

            // Volunteer Points or Hours
            if (userData!['volunteerPoints'] != null)
              ListTile(
                title: const Text('Volunteer Points'),
                subtitle: Text(userData!['volunteerPoints'].toString()),
              ),
            if (userData!['volunteerHours'] != null)
              ListTile(
                title: const Text('Volunteer Hours'),
                subtitle: Text(userData!['volunteerHours'].toString()),
              ),
            const Divider(),

            // Achievements Section
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(userData!['achievements'] ?? [])
                .map<Widget>((achievement) => ListTile(
                      leading: const Icon(Icons.emoji_events, color: Colors.orange),
                      title: Text(achievement),
                    ))
                .toList(),
            const Divider(),

            // Upcoming Events Section
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(userData!['upcomingEvents'] ?? [])
                .map<Widget>((event) => ListTile(
                      leading: const Icon(Icons.event, color: Colors.blue),
                      title: Text(event),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}