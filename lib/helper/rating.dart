import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

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
  String? _selectedPost; // Variable to store the selected post
  List<String> _leaders = []; // To store the list of leaders from Firestore
  List<String> _posts = []; // To store the list of posts from Firestore
  Map<String, List<Map<String, dynamic>>> _leaderBadges =
      {}; // Store badges with points for leaders
  Map<String, List<Map<String, dynamic>>> _postBadges =
      {}; // Store badges for posts
  double _extraPoints = 0; // Points awarded from selected badges
  String? _selectedLeaderBadge; // Variable to store the selected badge for leader
  String? _selectedPostBadge; // Variable to store the selected badge for post
  String? _postComment = ''; // Comment section for post
  List<String> _pastEvents = []; // To store past events the user participated in

  // Function to fetch data with error handling
  Future<void> fetchData() async {
    try {
      await fetchLeaders();
      await fetchPosts();
      await fetchPastEvents(); // Fetch past events
    } catch (e) {
      // Handle error
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching data. Please try again later.'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Call the function to fetch data
  }

  // Fetch leaders from Users collection (assuming leaders are users with a specific userType)
  Future<void> fetchLeaders() async {
    try {


      final usersCollection = FirebaseFirestore.instance.collection('Users');
      final snapshot =
          await usersCollection.where('userType', isEqualTo: 'Leader').get(); // Query for leaders

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _leaders =
              snapshot.docs.map((doc) => doc['username'] as String).toList(); // Use 'username' instead of 'name'
          // Assuming badges are stored within the User document
          _leaderBadges = { for (var doc in snapshot.docs) doc['username'] : List<Map<String, dynamic>>.from(doc['badges']?.map((badge) {
              return {
                'badge': badge['name'] as String,
                'points': badge['points'] as double,
              };
            }) ?? []) };
        });
      } else {
        setState(() {
          _leaders = ['No leaders available'];
        });
      }
    } catch (e) {
      print("Error fetching leaders: $e");
      // Handle error, e.g., display a snackbar
    }
  }

  // Fetch posts from Posts collection
  Future<void> fetchPosts() async {
    try {
      final postsCollection = FirebaseFirestore.instance.collection('Posts');
      final snapshot = await postsCollection.get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _posts =
              snapshot.docs.map((doc) => doc['PostMessage'] as String).toList(); // Use 'PostMessage' instead of 'name'
          // Assuming badges are stored within the Post document
          _postBadges = { for (var doc in snapshot.docs) doc['PostMessage'] : List<Map<String, dynamic>>.from(doc['badges']?.map((badge) {
              return {
                'badge': badge['name'] as String,
                'points': badge['points'] as double,
              };
            }) ?? []) };
        });
      } else {
        setState(() {
          _posts = ['No posts available'];
        });
      }
    } catch (e) {
      print("Error fetching posts: $e");
      // Handle error, e.g., display a snackbar
    }
  }

  // Fetch past events that the user participated in and didn't rate
  Future<void> fetchPastEvents() async {
    try {
      final currentUserEmail =
          'test@example.com'; // Replace with actual user email retrieval
      final now = DateTime.now();

      final postsSnapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .where('EventDate', isLessThan: Timestamp.fromDate(now))
          .get();

      final ratedEventsSnapshot = await FirebaseFirestore.instance
          .collection('Ratings')
          .where('user', isEqualTo: currentUserEmail)
          .get();

      final ratedEventIds = ratedEventsSnapshot.docs
          .map((doc) => doc['post'] as String)
          .toList();

      final pastEvents = postsSnapshot.docs.where((doc) {
        final postId = doc['PostMessage'] as String;
        final appliedUsers = List<String>.from(doc['AppliedUsers'] ?? []);
        return appliedUsers.contains(currentUserEmail) &&
            !ratedEventIds.contains(postId);
      }).map((doc) => doc['PostMessage'] as String);

      setState(() {
        _pastEvents = pastEvents.toList();
      });
    } catch (e) {
      print("Error fetching past events: $e");
      // Handle error, e.g., display a snackbar
    }
  }

  // Function to save the ratings
  void _saveRatings() {
    // Ensure both leader and event ratings are provided before submission
    if (_leaderRating == 0 ||
        _eventRating == 0 ||
        _selectedLeader == null ||
        _selectedPost == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Please provide ratings for both Leader and Event, and select a Leader and Post for the event'),
      ));
      return;
    }

    // Save ratings to Firestore
    FirebaseFirestore.instance.collection('Ratings').add({
      'leader': _selectedLeader,
      'leaderRating': _leaderRating,
      'leaderComment': _leaderComment,
      'eventRating': _eventRating,
      'eventComment': _eventComment,
      'post': _selectedPost,
      'timestamp': FieldValue.serverTimestamp(),
      'extraPoints': _extraPoints, // Save the extra points earned from badges
      'selectedLeaderBadge': _selectedLeaderBadge,
      'selectedPostBadge': _selectedPostBadge,
      'postComment': _postComment,
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text('Ratings submitted for $_selectedLeader and $_selectedPost'),
    ));
  }

  // Build the rating section
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
          allowHalfRating: false,
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

  // Build the badge buttons for leader (only allow selecting one badge)
  Widget _buildLeaderBadgeButtons(String leader) {
    List<Map<String, dynamic>> badges = _leaderBadges[leader] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: badges.map((badge) {
        return ElevatedButton(
          onPressed: _selectedLeaderBadge == badge['badge']
              ? null
              : () {
                  setState(() {
                    _selectedLeaderBadge = badge['badge']; // Set the selected badge
                    _extraPoints = badge['points']; // Set the points from selected badge
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedLeaderBadge == badge['badge']
                ? Colors.blue // Change color if selected
                : null,
          ),
          child: Text('${badge['badge']} (+${badge['points']} points)'),
        );
      }).toList(),
    );
  }

  // Build the badge buttons for Post (allow multiple badges and comment section)
  Widget _buildPostBadgeButtons(String post) {
    List<Map<String, dynamic>> badges = _postBadges[post] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: badges.map((badge) {
        return ElevatedButton(
          onPressed: _selectedPostBadge == badge['badge']
              ? null
              : () {
                  setState(() {
                    _selectedPostBadge = badge['badge']; // Allow selecting only one badge
                    _extraPoints = badge['points']; // Set the points for the badge
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedPostBadge == badge['badge']
                ? Colors.blue // Change color if selected
                : null,
          ),
          child: Text('${badge['badge']} (+${badge['points']} points)'),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rating Page'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Select Post (instead of NGO)
              Text(
                'Select Post for the Event:'.tr(),
                style: TextStyle(fontSize: 18),
              ),
              _posts.isEmpty
                  ? CircularProgressIndicator()
                  : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DropdownButton<String>(
                        value: _selectedPost,
                        hint: Text('Choose a Post'.tr()), // Updated hint
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPost = newValue;
                          });
                        },
                        items: _posts.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                  ),
              SizedBox(height: 20),
          
              // Select Leader
              Text(
                'Select Leader for the Event:'.tr(),
                style: TextStyle(fontSize: 18),
              ),
              _leaders.isEmpty
                  ? CircularProgressIndicator()
                  : DropdownButton<String>(
                      value: _selectedLeader,
                      hint: Text('Choose a leader'.tr()),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLeader = newValue;
                        });
                      },
                      items: _leaders.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
              SizedBox(height: 20),
          
              // Leader Rating Section
              _selectedLeader != null ? _buildRatingSection('Leader') : SizedBox(),
              // Event Rating Section
              _selectedPost != null ? _buildRatingSection('Event') : SizedBox(),
              // Badge Buttons for Leader
              _selectedLeader != null
                  ? _buildLeaderBadgeButtons(_selectedLeader!)
                  : SizedBox(),
              // Badge Buttons for Post with optional comment section
              _selectedPost != null
                  ? _buildPostBadgeButtons(_selectedPost!)
                  : SizedBox(),
              // Post Comment Section
              _selectedPost != null
                  ? TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter a comment for the Post (optional)'.tr(),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _postComment = text;
                        });
                      },
                    )
                  : SizedBox(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRatings,
                child: Text(
                  'Submit Ratings'.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                ),
              ),
              // Display past events
              if (_pastEvents.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Rate Past Events:',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    ..._pastEvents.map((event) => Card(
                          child: ListTile(
                            title: Text(event),
                            onTap: () {
                              // Handle navigation to rating page for the selected past event
                              // You might want to pass the event details to the rating page
                            },
                          ),
                        )),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

