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
  String? _selectedNgo; // Variable to store the selected NGO
  List<String> _leaders = []; // To store the list of leaders from Firestore
  List<String> _ngos = []; // To store the list of NGOs from Firestore
  Map<String, List<Map<String, dynamic>>> _leaderBadges = {}; // Store badges with points for leaders
  Map<String, List<Map<String, dynamic>>> _ngoBadges = {}; // Store badges for NGOs
  double _extraPoints = 0; // Points awarded from selected badges
  String? _selectedLeaderBadge; // Variable to store the selected badge for leader
  String? _selectedNgoBadge; // Variable to store the selected badge for NGO
  String? _ngoComment = ''; // Comment section for NGO

  @override
  void initState() {
    super.initState();
    fetchLeaders();
    fetchNgos();
  }

  // Fetch leaders from Firestore
  Future<void> fetchLeaders() async {
    final leaderCollection = FirebaseFirestore.instance.collection('leaders');
    final snapshot = await leaderCollection.get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _leaders = snapshot.docs.map((doc) => doc['name'] as String).toList();
        _leaderBadges = Map.fromIterable(
          snapshot.docs,
          key: (doc) => doc['name'],
          value: (doc) => List<Map<String, dynamic>>.from(doc['badges'.tr()]?.map((badge) {
            return {
              'badge'.tr(): badge['name'] as String,
              'points'.tr(): badge['points'] as double,
            };
          }) ?? []),
        );
      });
    } else {
      setState(() {
        _leaders = ['No leaders available'.tr()];
      });
    }
  }

  // Fetch NGOs from Firestore
  Future<void> fetchNgos() async {
    final ngoCollection = FirebaseFirestore.instance.collection('ngos'.tr());
    final snapshot = await ngoCollection.get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _ngos = snapshot.docs.map((doc) => doc['name'.tr()] as String).toList();
        _ngoBadges = Map.fromIterable(
          snapshot.docs,
          key: (doc) => doc['name'.tr()],
          value: (doc) => List<Map<String, dynamic>>.from(doc['badges'.tr()]?.map((badge) {
            return {
              'badge'.tr(): badge['name'.tr()] as String,
              'points'.tr(): badge['points'.tr()] as double,
            };
          }) ?? []),
        );
      });
    } else {
      setState(() {
        _ngos = ['No NGOs available'.tr()];
      });
    }
  }

  // Function to save the ratings
  void _saveRatings() {
    // Ensure both leader and event ratings are provided before submission
    if (_leaderRating == 0 || _eventRating == 0 || _selectedLeader == null || _selectedNgo == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please provide ratings for both Leader and Event, and select a Leader and NGO for the event'.tr()),
      ));
      return;
    }

    // Save ratings to Firestore
    FirebaseFirestore.instance.collection('ratings'.tr()).add({
      'leader': _selectedLeader,
      'leaderRating': _leaderRating,
      'leaderComment': _leaderComment,
      'eventRating': _eventRating,
      'eventComment': _eventComment,
      'ngo': _selectedNgo,
      'timestamp': FieldValue.serverTimestamp(),
      'extraPoints': _extraPoints, // Save the extra points earned from badges
      'selectedLeaderBadge': _selectedLeaderBadge,
      'selectedNgoBadge': _selectedNgoBadge,
      'ngoComment': _ngoComment,
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ratings submitted for $_selectedLeader and $_selectedNgo'),
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
          onPressed: _selectedLeaderBadge == null || _selectedLeaderBadge != badge['badge']
              ? () {
                  setState(() {
                    _selectedLeaderBadge = badge['badge']; // Set the selected badge
                    _extraPoints = badge['points']; // Set the points from selected badge
                  });
                }
              : null, // Disable button if the badge is already selected
          child: Text('${badge['badge']} (+${badge['points']} points)'),
        );
      }).toList(),
    );
  }
  // Build the badge buttons for NGO (allow multiple badges and comment section)
  Widget _buildNgoBadgeButtons(String ngo) {
    List<Map<String, dynamic>> badges = _ngoBadges[ngo] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: badges.map((badge) {
        return ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedNgoBadge = badge['badge']; // Allow selecting only one badge
              _extraPoints = badge['points']; // Set the points for the badge
            });
          },
          child: Text('${badge['badge']} (+${badge['points']} points)'),
        );
      }).toList(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate Volunteer Leader and Event'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select NGO
            Text(
              'Select NGO for the Event:'.tr(),
              style: TextStyle(fontSize: 18),
            ),
            _ngos.isEmpty
                ? CircularProgressIndicator()
                : DropdownButton<String>(
                    value: _selectedNgo,
                    hint: Text('Choose an NGO'.tr()),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedNgo = newValue;
                      });
                    },
                    items: _ngos.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
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
            _selectedLeader != null
                ? _buildRatingSection('Leader')
                : SizedBox(),
            // Event Rating Section
            _selectedNgo != null
                ? _buildRatingSection('Event')
                : SizedBox(),
            // Badge Buttons for Leader
            _selectedLeader != null
                ? _buildLeaderBadgeButtons(_selectedLeader!)
                : SizedBox(),
            // Badge Buttons for NGO with optional comment section
            _selectedNgo != null
                ? _buildNgoBadgeButtons(_selectedNgo!)
                : SizedBox(),
            // NGO Comment Section
            _selectedNgo != null
                ? TextField(
                    decoration: InputDecoration(
                      labelText: 'Enter a comment for the NGO (optional)'.tr(),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      setState(() {
                        _ngoComment = text;
                      });
                    },
                  )
                : SizedBox(),
            SizedBox(height: 20),
            ElevatedButton(
              
              onPressed: _saveRatings,
              child: Text('Submit Ratings'.tr() , style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            ),
          ],
        ),
      ),
    );
  }
}