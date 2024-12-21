import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  int pointsCount = 0;
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    _calculatePoints();
  }

  Future<void> _calculatePoints() async {
    if (currentUserEmail == null) {
      return; // Handle case where user is not logged in
    }

    final userType = await _getUserType();
    if (userType == null) {
      return; // Handle case where user data is unavailable
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .where('AppliedUsers', arrayContains: currentUserEmail)
        .where('status', isEqualTo: 'completed')
        .get();

    // Calculate the points
    pointsCount = snapshot.docs.fold(
      0,
      (acc, doc) {
        // Leader gets 10 points, User gets 5 points for each completed event
        if (userType == 'Leader') {
          return acc + 10;
        } else if (userType == 'User') {
          return acc + 5;
        }
        return acc;
      },
    );

    // Add extra points (e.g., from badges) if needed.
    // Assuming extra points come from a badge collection or other source
    pointsCount += (await _getExtraPoints())!;
    setState(() {}); // Update state to trigger UI rebuild
  }

  Future<int?> _getExtraPoints() async {
    // Add any extra points from badges or rewards system if necessary
    final userDocSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserEmail)
        .get();
    if (userDocSnapshot.exists) {
      final badges = userDocSnapshot.data()?['badges'] ?? [];
      int extraPoints = 0; // Initialize extraPoints as an integer
      // Calculate extra points based on badges (example logic)
      for (var badge in badges) {
        // Ensure that the badge points are properly cast to int
        final points = badge['points'] ?? 0;
        extraPoints += points is num ? points.toInt() : 0; // Safely cast num to int
      }
      return extraPoints;
    }
    return 0; // Default return value if no badges are found
  }
  Future<String?> _getUserType() async {
    final userDocSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserEmail)
        .get();

    if (!userDocSnapshot.exists) {
      return null;
    }

    return userDocSnapshot.data()!['userType'];
  }

  void _redeemReward(String reward) {
    // Handle reward redemption, e.g., update Firestore or show confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Redeem $reward'),
        content: Text('You have redeemed the $reward for ${reward.length * 10} points!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  // Create a list of rewards based on pointsCount
  List<Widget> _buildRewardCards() {
    List<Map<String, dynamic>> rewards = [
      {'reward': 'Free T-shirt', 'cost': 20},
      {'reward': 'Gift Card', 'cost': 50},
      {'reward': 'Event Ticket', 'cost': 100},
      {'reward': 'Premium Membership', 'cost': 200},
    ];
    List<Widget> rewardCards = [];
    for (var reward in rewards) {
      rewardCards.add(
        Card(
          margin: const EdgeInsets.all(8),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reward['reward'],
                  style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: pointsCount >= reward['cost']
                      ? () {
                          // Handle reward redemption logic
                          _redeemReward(reward['reward']);
                        }
                      : null, // Disable button if the user doesn't have enough points
                  child: Text('Redeem'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return rewardCards;
  }
  Widget _buildBodyContent() {
    // Build content based on points and rewards
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'You have earned $pointsCount points!',
              style: GoogleFonts.roboto(fontSize: 18),
            ),
          ),
          ..._buildRewardCards(), // Display reward cards based on earned points
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 20),
            Text(
              "Rewards",
              style: GoogleFonts.roboto(
                color: Theme.of(context).colorScheme.inversePrimary,
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Text(
              "MY POINTS ($pointsCount)",
              style: GoogleFonts.roboto(
                color: Theme.of(context).colorScheme.inversePrimary,
                textStyle: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        leading: SizedBox(),
      ),
      body: _buildBodyContent(),
    );
  }
}
