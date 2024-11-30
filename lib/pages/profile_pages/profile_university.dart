import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_progect_v2/pages/profile_pages/edit_profile_university.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversityProfile extends StatefulWidget {
  const UniversityProfile({super.key});

  @override
  _UniversityProfileState createState() => _UniversityProfileState();
}

class _UniversityProfileState extends State<UniversityProfile> {
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
          builder: (context) => EditUniversityProfilePage(
            userType: 'University',
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
        title: const Text('University Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University Logo
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: userData?['universityLogo'] != null
                    ? NetworkImage(userData!['universityLogo'])
                    : const AssetImage('assets/default_logo.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 30),

            // University Name and Email
            Center(
              child: Column(
                children: [
                  Text(
                    userData?['universityName'] ?? 'University Name',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData?['email'] ?? 'No Email',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // About Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'About Us',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                userData?['about'] ?? 'No description available.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Divider(),

            // Departments Offered
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Departments Offered',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...(userData?['departments'] is List
                ? (userData!['departments'] as List<dynamic>)
                    .map<Widget>((department) => ListTile(
                          leading: const Icon(Icons.school, color: Colors.blue),
                          title: Text(department.toString()),
                        ))
                    .toList()
                : []),
            const Divider(),

            // Events Hosted
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Events Hosted',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...(userData?['events'] is List
                ? (userData!['events'] as List<dynamic>)
                    .map<Widget>((event) => ListTile(
                          leading: const Icon(Icons.event, color: Colors.green),
                          title: Text(event.toString()),
                        ))
                    .toList()
                : []),
            const Divider(),

            // Contact Information
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Contact Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            _buildContactLink(Icons.email, 'Email', userData?['email']),
            _buildContactLink(Icons.phone, 'Phone', userData?['phone']),
            _buildContactLink(Icons.web, 'Website', userData?['website']),
          ],
        ),
      ),
    );
  }

  Widget _buildContactLink(IconData icon, String label, String? value) {
    return value != null
        ? ListTile(
            leading: Icon(icon),
            title: Text(label),
            onTap: () async {
              final Uri? uri = Uri.tryParse(value);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot open $label')),
                );
              }
            },
          )
        : ListTile(
            leading: Icon(icon, color: Colors.grey),
            title: Text('$label not available'),
          );
  }
}