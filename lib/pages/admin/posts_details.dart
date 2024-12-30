import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final String postId; // Post ID to fetch details from Firestore

  const EventDetailsPage({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        title: Text("Event Details"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Event not found."));
          }

          final post = snapshot.data!;
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
          List<dynamic> appliedUsers = post['AppliedUsers'] ?? [];
          List<dynamic> leaders = post['Leaders'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Posted by: $username",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold ,color: Theme.of(context).colorScheme.onSecondary,),
                ),
                SizedBox(height: 10),
                Text(
                  "Event Date: $formattedEventDate",
                  style: TextStyle(fontSize: 16 , color: Theme.of(context).colorScheme.onSecondary),
                ),
                SizedBox(height: 10),
                if (imageUrl != null)
                  Center(
                    child: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
                  ),
                SizedBox(height: 10),
                Text(
                  "Message:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold ,color: Theme.of(context).colorScheme.onSecondary),
                ),
                Text(message),
                SizedBox(height: 20),
                Text(
                  "Leaders: $leaderCount / $maxLeaders",
                  style: TextStyle(fontSize: 16 , color: Theme.of(context).colorScheme.onSecondary),
                ),
                LinearProgressIndicator(
                  value: leaderCount / maxLeaders,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                  color: Colors.orange,
                ),
                SizedBox(height: 20),
                Text(
                  "Volunteers: $currentCount / $targetCount",
                  style: TextStyle(fontSize: 16,color: Theme.of(context).colorScheme.onSecondary),
                ),
                LinearProgressIndicator(
                  value: currentCount / targetCount,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                Text(
                  "Applied Users:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondary),
                ),
                ...appliedUsers.map((user) => Text("- $user")).toList(),
                SizedBox(height: 10),
                Text(
                  "Leaders:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondary),
                ),
                ...leaders.map((leader) => Text("- $leader")).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
