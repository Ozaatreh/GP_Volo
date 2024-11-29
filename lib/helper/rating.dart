

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication


void main() {
  runApp(RatingApp());
}


class RatingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Page Rating',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LeaderRatingPage(),
    );
  }
}


// Global variables to collect all ratings
double leaderRateEvent = 0.0;
double leaderRateVolunteer = 0.0;
double eventRateLeader = 0.0;
double eventRateVolunteer = 0.0;
double volunteerRateEvent = 0.0;
double volunteerRateLeader = 0.0;


final TextEditingController leaderCommentController = TextEditingController();
final TextEditingController eventCommentController = TextEditingController();
final TextEditingController volunteerCommentController =
    TextEditingController();
final TextEditingController leaderCommandController = TextEditingController();
final TextEditingController eventCommandController = TextEditingController();
final TextEditingController volunteerCommandController =
    TextEditingController();


/// Leader Rating Page
class LeaderRatingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leader Ratings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rate Event',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RatingBar.builder(
              initialRating: leaderRateEvent,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemSize: 40,
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.orange),
              onRatingUpdate: (value) {
                leaderRateEvent = value;
              },
            ),
            SizedBox(height: 16),
            Text('Rate Volunteer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RatingBar.builder(
              initialRating: leaderRateVolunteer,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemSize: 40,
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.orange),
              onRatingUpdate: (value) {
                leaderRateVolunteer = value;
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: leaderCommentController,
              decoration: InputDecoration(
                  labelText: 'Event Comments', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: leaderCommandController,
              decoration: InputDecoration(
                  labelText: 'Volunteer Comments',
                  border: OutlineInputBorder()),
              maxLines: 2,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Proceed to the next page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventRatingPage()),
                );
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}


/// Event Rating Page
class EventRatingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Ratings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rate Leader',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RatingBar.builder(
              initialRating: eventRateLeader,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemSize: 40,
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.orange),
              onRatingUpdate: (value) {
                eventRateLeader = value;
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: eventCommentController,
              decoration: InputDecoration(
                  labelText: 'Leader Comments', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Proceed to the next page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VolunteerRatingPage()),
                );
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}


/// Volunteer Rating Page
class VolunteerRatingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Volunteer Ratings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rate Event',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RatingBar.builder(
              initialRating: volunteerRateEvent,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemSize: 40,
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.orange),
              onRatingUpdate: (value) {
                volunteerRateEvent = value;
              },
            ),
            SizedBox(height: 16),
            Text('Rate Leader',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RatingBar.builder(
              initialRating: volunteerRateLeader,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemSize: 40,
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.orange),
              onRatingUpdate: (value) {
                volunteerRateLeader = value;
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: volunteerCommentController,
              decoration: InputDecoration(
                  labelText: 'Event Comments', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: volunteerCommandController,
              decoration: InputDecoration(
                  labelText: 'Leader Comments', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Get the current user's email and username from Firebase Authentication
                  User? user = FirebaseAuth.instance.currentUser;
                  String email = user?.email ?? 'Unknown';
                  String username = user?.displayName ?? 'Anonymous';


                  // Submit the ratings and points to Firebase
                  await FirebaseFirestore.instance.collection('ratings').add({
                    'leaderRateEvent': leaderRateEvent,
                    'leaderRateVolunteer': leaderRateVolunteer,
                    'eventRateLeader': eventRateLeader,
                    'eventRateVolunteer': eventRateVolunteer,
                    'volunteerRateEvent': volunteerRateEvent,
                    'volunteerRateLeader': volunteerRateLeader,
                    'totalLeaderPoints': leaderRateEvent + leaderRateVolunteer,
                    'totalEventPoints': eventRateLeader + eventRateVolunteer,
                    'totalVolunteerPoints':
                        volunteerRateEvent + volunteerRateLeader,
                    'comments': {
                      'leader': leaderCommentController.text,
                      'event': eventCommentController.text,
                      'volunteer': volunteerCommentController.text,
                    },
                    'commands': {
                      'leader': leaderCommandController.text,
                      'event': eventCommandController.text,
                      'volunteer': volunteerCommandController.text,
                    },
                    'userEmail': email, // Add email to the Firestore document
                    'userName':
                        username, // Add username to the Firestore document
                    'timestamp': FieldValue.serverTimestamp(),
                  });


                  // Confirm data submission
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Feedback Submitted Successfully!')));


                  // Navigate back to the first screen
                  Navigator.popUntil(context, (route) => route.isFirst);


                  // Optional: Show a thank you message on the final screen
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Thank you for your feedback!'),
                    backgroundColor: Colors.green,
                  ));
                } catch (e) {
                  // Handle error
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}



