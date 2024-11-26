import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_progect_v2/pages/edit_profile.dart';


class NgoProfile extends StatefulWidget {
  const NgoProfile({super.key});

  @override
  _NgoProfileState createState() => _NgoProfileState();
}

class _NgoProfileState extends State<NgoProfile> {
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
            userType: 'Ngo',
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
        title: const Text('Ngo Profile'),
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
            // Background Image
            if (userData!['backgroundImage'] != null)
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(userData!['backgroundImage']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // NGO Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Non-Profit Organization (Ngo)',
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

            // Organization Name
            Center(
              child: Text(
                userData!['organizationName'] ?? 'No Organization Name',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Email
            Center(child: Text(userData!['email'] ?? 'No Email')),
            const SizedBox(height: 16),

            // Phone Information
            ListTile(
              title: const Text('Phone'),
              subtitle: Text(userData!['phone'] ?? 'No Phone'),
            ),

            // Bio Information
            ListTile(
              title: const Text('Bio'),
              subtitle: Text(userData!['bio'] ?? 'No Bio'),
            ),

            // Mission Statement
            if (userData!['mission'] != null)
              ListTile(
                title: const Text('Mission Statement'),
                subtitle: Text(userData!['mission']),
              ),

            // Location Information
            if (userData!['location'] != null)
              ListTile(
                title: const Text('Location'),
                subtitle: Text(userData!['location']),
              ),
            const Divider(),

            // Key Stats
            if (userData!['eventsOrganized'] != null)
              ListTile(
                title: const Text('Events Organized'),
                subtitle: Text(userData!['eventsOrganized'].toString()),
              ),
            if (userData!['volunteersEngaged'] != null)
              ListTile(
                title: const Text('Volunteers Engaged'),
                subtitle: Text(userData!['volunteersEngaged'].toString()),
              ),
            const Divider(),

            // Posts Section
            const Text(
              'Recent Posts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(userData!['posts'] ?? [])
                .map<Widget>((post) => ListTile(
                      leading: const Icon(Icons.post_add, color: Colors.blue),
                      title: Text(post['PostMessage'] ?? 'Untitled Post'),
                      // subtitle: Text(post['PostMessage'] ?? 'No content available'),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}