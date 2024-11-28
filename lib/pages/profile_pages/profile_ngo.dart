import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_progect_v2/pages/profile_pages/edit_profile_ngo.dart';
import 'package:url_launcher/url_launcher.dart';

class NGOProfile extends StatefulWidget {
  const NGOProfile({super.key});

  @override
  _NGOProfileState createState() => _NGOProfileState();
}

class _NGOProfileState extends State<NGOProfile> {
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
          builder: (context) => EditNGOProfilePage(
            userType: 'NGO',
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
        title: const Text('NGO Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile and Background Images
         
                // SizedBox(
                  // height: 180,
                  // width: double.infinity,
                // ),
                Container(
                  // top: 60,
                  // right: 250,
                  child: Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: userData?['profilePicture'] != null
                          ? NetworkImage(userData!['profilePicture'])
                          : const AssetImage('assets/photo_2024-11-02_19-33-14.jpg')
                              as ImageProvider,
                    ),
                  ),
                ),
           
            const SizedBox(height: 30),

            // Name and Description
            Center(
              child: Column(
                children: [
                  Text(
                    userData?['organizationName'] ?? 'Organization Name',
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

            // About Us Section
            const Text(
              'About Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              userData?['bio'] ?? 'No Description Available',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(),

            // Services Offered
            const Text(
              'Services Offered',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(userData?['services'] is List
                ? (userData!['services'] as List<dynamic>)
                    .map<Widget>((service) => ListTile(
                          leading: const Icon(Icons.check_circle_outline,
                              color: Colors.green),
                          title: Text(service.toString()),
                        ))
                    .toList()
                : []),
            const Divider(),

            // Projects
            const Text(
              'Current Projects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(userData?['projects'] is List
                ? (userData!['projects'] as List<dynamic>)
                    .map<Widget>((project) => ListTile(
                          leading: const Icon(Icons.folder_open,
                              color: Colors.blue),
                          title: Text(project.toString()),
                        ))
                    .toList()
                : []),
            const Divider(),

            // Testimonials
            const Text(
              'Testimonials',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(userData?['testimonials'] is List
                ? (userData!['testimonials'] as List<dynamic>)
                    .map<Widget>((testimonial) => ListTile(
                          leading: const Icon(Icons.format_quote,
                              color: Colors.amber),
                          title: Text(testimonial.toString()),
                        ))
                    .toList()
                : []),
            const Divider(),

            // Contact / Social Media
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildContactLink(Icons.email, 'Email', userData?['email']),
            _buildContactLink(Icons.phone, 'Phone', userData?['phone']),
            _buildContactLink(Icons.web, 'Website', userData?['website']),
            _buildContactLink(Icons.facebook, 'Facebook', userData?['facebook']),
            _buildContactLink(Icons.linked_camera, 'Instagram', userData?['instagram']),
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