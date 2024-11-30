import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/components/my_drawer.dart';
import 'package:graduation_progect_v2/database/firestore.dart';

class UniversityPage extends StatefulWidget {
  const UniversityPage({super.key});

  @override
  _UniversityPageState createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage> {
  final FirestoreDatabase database = FirestoreDatabase();
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  // Fetch user data
  Future<void> getUserData() async {
    try {
      user = auth.currentUser;
      if (user != null) {
        final doc = await firestore.collection('Users').doc(user!.email).get();
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

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("University Page")),
      drawer: MyDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .where('status', isEqualTo: 'upcoming')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;
          if (posts.isEmpty) {
            return const Center(child: Text("No Upcoming Events Yet."));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              String username = post['Username'];
              String message = post['PostMessage'];
              String? imageUrl = post['ImageUrl'];
              DateTime eventDate = post['EventDate']?.toDate() ?? DateTime.now();
              String formattedEventDate =
                  "${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}";

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Card(
                  color: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.more_horiz,
                              color: Theme.of(context).colorScheme.inversePrimary),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.report_gmailerrorred),
                                    title: const Text('Report Problem'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, 'Contact_us_page');
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Row(
                          children: [
                            Text(username),
                            const SizedBox(width: 7),
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: userData?['profilePicture'] != null
                                  ? NetworkImage(userData!['profilePicture'])
                                  : const AssetImage('assets/photo_2024-11-02_19-33-14.jpg')
                                      as ImageProvider,
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          "Event Date: $formattedEventDate",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(message),
                        if (imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Image.network(imageUrl, width: 100, height: 100),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}