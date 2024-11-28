import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/components/my_drawer.dart';
import 'package:graduation_progect_v2/pages/admin/posts_details.dart';

class PostArchive extends StatelessWidget {
  const PostArchive({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Archived Events"),
      ),
      drawer: MyDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .where('EventDate', isLessThan: Timestamp.fromDate(DateTime.now()))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No archived events yet.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final archivedPosts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: archivedPosts.length,
            itemBuilder: (context, index) {
              final post = archivedPosts[index];
              String username = post['Username'];
              String message = post['PostMessage'];
              DateTime eventDate = post['EventDate'].toDate();
              String formattedEventDate =
                  "${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}";
              String? imageUrl = post['ImageUrl'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailsPage(postId: post.id),
                          ),
                        );
                      },
                      title: Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text("Event Date: $formattedEventDate"),
                          SizedBox(height: 5),
                          Text(message),
                          if (imageUrl != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    )),
              );
            },
          );
        },
      ),
    );
  }
}
