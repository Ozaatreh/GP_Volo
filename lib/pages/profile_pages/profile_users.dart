import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_progect_v2/pages/profile_pages/edit_profile_volunteer.dart';
import 'package:url_launcher/url_launcher.dart';

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
          builder: (context) => EditVolunteerProfilePage(
            userType: 'Volunteer',
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
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: userData?['profilePicture'] != null
                    ? NetworkImage(userData!['profilePicture'])
                    : const AssetImage('assets/photo_2024-11-02_19-33-14.jpg')
                        as ImageProvider,
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

            // Achievements Section
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(userData?['achievements'] is List
                ? (userData!['achievements'] as List<dynamic>)
                    .map<Widget>((achievement) => ListTile(
                          leading: const Icon(Icons.star, color: Colors.amber),
                          title: Text(achievement.toString()),
                        ))
                    .toList()
                : []),

            // Social Media Links
            const Divider(),
            const Text(
              'Social Media Links',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSocialLink(Icons.link_sharp, 'LinkedIn', userData?['linkedin']),
            _buildSocialLink(Icons.facebook, 'Facebook', userData?['facebook']),
            _buildSocialLink(Icons.camera_alt, 'Instagram', userData?['instagram']),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLink(IconData icon, String label, String? url) {
    return url != null
        ? ListTile(
            leading: Icon(icon),
            title: Text(label),
            onTap: () async {
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch $label')),
                );
              }
            },
          )
        : ListTile(
            leading: Icon(icon, color: Colors.grey),
            title: Text('$label not provided'),
          );
  }
}