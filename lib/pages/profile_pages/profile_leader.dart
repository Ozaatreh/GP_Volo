import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_progect_v2/pages/profile_pages/edit_profile_leader.dart';
import 'package:url_launcher/url_launcher.dart';

class LeaderProfile extends StatefulWidget {
  const LeaderProfile({super.key});

  @override
  LeaderProfileState createState() => LeaderProfileState();
}

class LeaderProfileState extends State<LeaderProfile> {
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

  Future<void> navigateToEditProfile() async {
    if (user != null && userData != null) {
      final updatedData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditLeaderProfilePage(
            userType: 'Leader',
            userData: userData!,
          ),
        ),
      );

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
        title: const Text('Leader Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: navigateToEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: userData?['profilePicture'] != null
                    ? NetworkImage(userData!['profilePicture'])
                    : const AssetImage('assets/prf_pic.jpg') as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),

            // Name and Email
            Center(
              child: Text(
                userData?['username'] ?? 'No Username',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Center(child: Text(userData?['email'] ?? 'No Email')),
            const SizedBox(height: 8),

            // University
            Center(
              child: Text(
                ' ${userData?['university'] ?? 'No University'}',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 16),

            // About Me / Bio
            const Text(
              'About Me',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              userData?['bio'] ?? 'No Bio Available',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(),

            // Skills Section
            const Text(
              'Skills',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: (userData?['skills'] is List)
                  ? (userData!['skills'] as List<dynamic>)
                      .map<Widget>((skill) {
                        return Chip(
                          label: Text(skill.toString()), // Ensure skill is a String
                          backgroundColor: Colors.blue[200],
                        );
                      }).toList()
                  : [], // Return an empty list if it's not a list
            ),
            const Divider(),

            // Achievements / Certifications Section
            const Text(
              'Achievements & Certifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(userData?['achievements'] is List
                ? (userData!['achievements'] as List<dynamic>)
                    .map<Widget>((achievement) => ListTile(
                          leading: const Icon(Icons.emoji_events, color: Colors.amber),
                          title: Text(achievement.toString()),
                        ))
                    .toList()
                : []), // Safe fallback for non-list values

            // Contact / Social Media Links Section
const Text(
  'Contact / Social Media Links',
  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // LinkedIn Icon and action
    if (userData?['linkedin'] != null)
      IconButton(
        icon: const Icon(Icons.link),
        onPressed: () async {
          final url = userData!['linkedin'];
          if (await canLaunchUrl(url)) {
            await launchUrl(url); // Open the LinkedIn URL
          } else {
            throw 'Could not launch $url'; // Error if the URL cannot be opened
          }
        },
      ),

    // Instagram Icon and action
    if (userData?['instagram'] != null)
      IconButton(
        icon: const Icon(Icons.camera_alt),
        onPressed: () async {
          final url = userData!['instagram'];
          if (await canLaunchUrl(url)) {
            await launchUrl(url); // Open the Instagram URL
          } else {
            throw 'Could not launch $url'; // Error if the URL cannot be opened
          }
        },
      ),

    // Facebook Icon and action
    if (userData?['facebook'] != null)
      IconButton(
        icon: const Icon(Icons.facebook),
        onPressed: () async {
          final url = userData!['facebook'];
          if (await canLaunchUrl(url)) {
            await launchUrl(url); // Open the Facebook URL
          } else {
            throw 'Could not launch $url'; // Error if the URL cannot be opened
                  }
        }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}