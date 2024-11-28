import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/pages/admin/admin_drawer.dart';
import 'package:graduation_progect_v2/pages/admin/posts_details.dart';

class ActiveEvents extends StatefulWidget {
   ActiveEvents({super.key});

  @override
  State<ActiveEvents> createState() => _ActiveEventsState();
}

class _ActiveEventsState extends State<ActiveEvents> {
  // Track expanded cards
  Map<String, bool> expandedCards = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Active Posts"),
      ),
      drawer: AdminDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .where('EventDate', isGreaterThanOrEqualTo: DateTime.now())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No active posts available."));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              String username = post['Username'];
              String message = post['PostMessage'];
              DateTime eventDate = post['EventDate'].toDate();
              String formattedEventDate =
                  "${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}";
              String? imageUrl = post['ImageUrl'];
              int leaderCount = post['LeaderCount'] ?? 0;
              int maxLeaders = post['LeaderMaxCount'] ?? 5;
              int currentCount = post['CurrentCount'] ?? 0;
              int targetCount = post['TargetCount'] ?? 10;
              final postId = post.id;

              bool isExpanded = expandedCards[postId] ?? false;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: Column(
                  children: [
                    ListTile(
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
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                      // trailing: IconButton(
                      //   icon: Icon(
                      //     isExpanded
                      //         ? Icons.expand_less
                      //         : Icons.expand_more,
                      //     color: Colors.orange,
                      //   ),
                        // onPressed: () {
                          // setState(() {
                            // expandedCards[postId] = !isExpanded;
                            
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         EventDetailsPage(postId: post.id),
                        //   ),
                        // );
                     
                          // }
                          // );
                        // },
                      // ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Message:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(message),
                            SizedBox(height: 10),
                            if (imageUrl != null)
                              Image.network(
                                imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            SizedBox(height: 10),
                            Text(
                              "Leader Progress: $leaderCount / $maxLeaders",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            LinearProgressIndicator(
                              value: leaderCount / maxLeaders,
                              minHeight: 6,
                              backgroundColor: Colors.grey[300],
                              color: Colors.orange,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Volunteer Progress: $currentCount / $targetCount",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            LinearProgressIndicator(
                              value: currentCount / targetCount,
                              minHeight: 6,
                              backgroundColor: Colors.grey[300],
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
