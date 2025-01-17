import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/pages/admin/posts_details.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    // Check if currentUserEmail is null
    if (currentUserEmail == null) {
      return Center(child: Text('You must be logged in to view event history.'.tr()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Event History').tr()),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Users').doc(currentUserEmail).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError || !userSnapshot.hasData) {
            return Center(child: Text('Error loading user data.'.tr()));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final userType = userData['userType'];

          Query<Map<String, dynamic>> query;

          if (userType == 'NGO') {
            query = FirebaseFirestore.instance
                .collection('Posts')
                .where('UserEmail', isEqualTo: currentUserEmail)
                .where('status', isEqualTo: 'completed');
          } else {
            query = FirebaseFirestore.instance
                .collection('Posts')
                .where('AppliedUsers', arrayContains: currentUserEmail)
                .where('status', isEqualTo: 'completed');
          }

          return StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('${'Error:'.tr()} ${snapshot.error}'));
              }

              final posts = snapshot.data!.docs;

              if (posts.isEmpty) {
                return Center(child: Text('No completed events yet.'.tr()));
              }

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  String message = post['PostMessage'];
                  Timestamp? eventTimestamp = post['EventDate'];
                  String formattedDate = '';
                  if (eventTimestamp != null) {
                    DateTime eventDate = eventTimestamp.toDate();
                    formattedDate = DateFormat('yyyy-MM-dd').format(eventDate);
                  }

                  return Card(
                    color:  Theme.of(context).colorScheme.primary  ,
                    child: ListTile(
                      title: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${'Event Date:'.tr()} $formattedDate'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailsPage(postId: post.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}