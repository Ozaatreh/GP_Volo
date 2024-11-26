import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_progect_v2/pages/edit_profile.dart';

class LeaderProfile extends StatefulWidget {
  const LeaderProfile({super.key});

  @override
  _LeaderProfileState createState() => _LeaderProfileState();
}

class _LeaderProfileState extends State<LeaderProfile> {
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

  Future<void> _navigateToEdit() async {
    if (user != null && userData != null) {
      final updatedData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(
            userType: 'Leader',
            userData: userData!,
            userId: user!.uid,
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
            onPressed: _navigateToEdit,
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
                radius: 50,
                backgroundImage: userData!['profilePicture'] != null
                    ? NetworkImage(userData!['profilePicture'])
                    : const AssetImage('assets/photo_2024-11-02_19-33-14.jpg') as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),

            // Username and Badge
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userData!['username'] ?? 'No Username',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24,
                  ),
                ],
              ),
            ),
            Center(child: Text(userData!['email'] ?? 'No Email')),
            const Divider(height: 32),

            // Phone Information
            ListTile(
              title: const Text('Phone'),
              subtitle: Text(userData!['phone'] ?? 'No Phone'),
            ),

            const Divider(height: 32),

            // Skills Section
            const Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (userData!['skills'] != null)
              ...(userData!['skills'] as List)
                  .map<Widget>((skill) => ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(skill),
                      ))
                  .toList(),
            const Divider(height: 32),

            // Achievements Section
            const Text('Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (userData!['achievements'] != null)
              ...(userData!['achievements'] as List)
                  .map<Widget>((achievement) => ListTile(
                        leading: const Icon(Icons.emoji_events, color: Colors.orange),
                        title: Text(achievement),
                      ))
                  .toList(),
            const Divider(height: 32),

            // Upcoming Tasks Section
            const Text('Upcoming Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (userData!['upcomingTasks'] != null)
              ...(userData!['upcomingTasks'] as List)
                  .map<Widget>((task) => ListTile(
                        leading: const Icon(Icons.task, color: Colors.blue),
                        title: Text(task),
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }
}