import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingPage extends StatefulWidget {
  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  // Variables for leader and event ratings
  double _leaderRating = 0;
  double _eventRating = 0;

  String _leaderComment = '';
  String _eventComment = '';

  String? _selectedLeader; // Variable to store the selected leader
  List<String> _leaders = []; // To store the list of leaders from Firestore

  @override
  void initState() {
    super.initState();
    fetchLeaders();
  }

  // Function to fetch leaders from Firebase Firestore
  Future<void> fetchLeaders() async {
    final leaderCollection = FirebaseFirestore.instance.collection('leaders');
    final snapshot = await leaderCollection.get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _leaders = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } else {
      // If no leaders are found in Firestore, add a default leader or display a message
      setState(() {
        _leaders = ['No leaders available'];
      });
    }
  }

  // Function to save the ratings
  void _saveRatings() {
    // Ensure both leader and event ratings are provided before submission
    if (_leaderRating == 0 || _eventRating == 0 || _selectedLeader == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Please provide ratings for both Leader and Event, and select a leader for the event'),
      ));
      return;
    }

    // Display ratings after submission
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Leader Rating: $_leaderRating\nEvent Rating: $_eventRating\n'
        'Leader: $_selectedLeader\nLeader Comment: $_leaderComment\nEvent Comment: $_eventComment',
      ),
    ));
  }

  // Build the rating interface
  Widget _buildRatingSection(String ratingType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate this $ratingType:',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 10),
        RatingBar.builder(
          initialRating: ratingType == 'Leader' ? _leaderRating : _eventRating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false, // Disable half-stars
          itemCount: 5,
          itemSize: 40.0,
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              if (ratingType == 'Leader') {
                _leaderRating = rating;
              } else {
                _eventRating = rating;
              }
            });
          },
        ),
        SizedBox(height: 20),
        Text(
          'Rating: ${ratingType == 'Leader' ? _leaderRating : _eventRating}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            labelText: 'Enter your comment for $ratingType (optional)',
            border: OutlineInputBorder(),
          ),
          onChanged: (text) {
            setState(() {
              if (ratingType == 'Leader') {
                _leaderComment = text;
              } else {
                _eventComment = text;
              }
            });
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate Volunteer Leader and Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section to select a leader for the event
            Text(
              'Select Leader for the Event:',
              style: TextStyle(fontSize: 18),
            ),
            // Display the list of leaders from Firebase
            _leaders.isEmpty
                ? CircularProgressIndicator()
                : DropdownButton<String>(
                    value: _selectedLeader,
                    hint: Text('Choose a leader'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLeader = newValue;
                      });
                    },
                    items:
                        _leaders.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
            SizedBox(height: 20),

            // Display leader rating interface
            _buildRatingSection('Leader'),
            SizedBox(height: 40),
            // Display event rating interface
            _buildRatingSection('Event'),
            SizedBox(height: 20),
            // A single button to submit ratings
            ElevatedButton(
              onPressed: _saveRatings,
              child: Text('Submit Ratings'),
            ),
          ],
        ),
      ),
    );
  }
}