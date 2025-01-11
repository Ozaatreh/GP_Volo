import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graduation_progect_v2/components/my_drawer.dart';
import 'package:graduation_progect_v2/database/firestore.dart';
import 'package:graduation_progect_v2/helper/event_location_users.dart';
import 'package:graduation_progect_v2/helper/status.dart';
import 'package:latlong2/latlong.dart';


class LeadersPage extends StatefulWidget {
  @override
  _LeadersPageState createState() => _LeadersPageState();
}

class _LeadersPageState extends State<LeadersPage> {
  final FirestoreDatabase database = FirestoreDatabase();
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  String? currentUserType; // Store the logged-in user's type
  List<String> appliedLeaderPostIds = []; // Track posts applied as leaders
  List<DateTime> appliedLeaderEventDates = []; // Event dates for leaders
  List<String> appliedVolunteerPostIds =  []; // Track posts applied as volunteers
  List<DateTime> appliedVolunteerEventDates = []; // Event dates for volunteers

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  LatLng? currentLocation;
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
        SnackBar(content: Text('${'Failed to load profile:'.tr()} $e')),
      );
    }
  }
  
  
  @override
  void initState() {
    super.initState();
     // Update event statuses
    // getCurrentLocation();
    Future.microtask(() => database.updateEventStatus());
    fetchCurrentUserType();
    fetchAppliedPosts(); // Fetch applied event dates when the page loads
    getUserData();
  }

  // Fetch the current user's type
  void fetchCurrentUserType() async {
    if (currentUserEmail != null) {
      final type = await database.getUserType(currentUserEmail!);
      setState(() {
        currentUserType = type;
      });
    }
  }

  // Fetch applied posts for both leaders and volunteers
  void fetchAppliedPosts() async {
    if (currentUserEmail != null) {
      // Fetch posts where the user is a leader
      final leaderPostsSnapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .where('Leaders', arrayContains: currentUserEmail)
          .get();

      // Fetch posts where the user is a volunteer
      final volunteerPostsSnapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .where('AppliedUsers', arrayContains: currentUserEmail)
          .get();

      setState(() {
        appliedLeaderPostIds =
            leaderPostsSnapshot.docs.map((doc) => doc.id).toList();
        appliedLeaderEventDates = leaderPostsSnapshot.docs
            .map((doc) => (doc['EventDate'] as Timestamp).toDate())
            .toList();

        appliedVolunteerPostIds =
            volunteerPostsSnapshot.docs.map((doc) => doc.id).toList();
        appliedVolunteerEventDates = volunteerPostsSnapshot.docs
            .map((doc) => (doc['EventDate'] as Timestamp).toDate())
            .toList();
      });
    }
  }

  // Check whether to hide a post based on leader or volunteer conflict
  bool shouldHidePost(String postId, DateTime eventDate) {
    // Show posts already applied as leader or volunteer
    if (appliedLeaderPostIds.contains(postId) ||
        appliedVolunteerPostIds.contains(postId)) {
      return false;
    }

    // Check for conflicting dates
    return appliedLeaderEventDates.any((date) =>
            date.year == eventDate.year &&
            date.month == eventDate.month &&
            date.day == eventDate.day) ||
        appliedVolunteerEventDates.any((date) =>
            date.year == eventDate.year &&
            date.month == eventDate.month &&
            date.day == eventDate.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Leaders Page").tr())),
      drawer: MyDrawer(),
      body: StreamBuilder(
        // Filter events with "Upcoming" status
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .where('status', isEqualTo:'upcoming')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;
          if (posts.isEmpty) {
            return Center(child: Text("No Upcoming Events Yet.").tr());
          }
//  return Center(child: Text("No Posts Yet.. Post Something!"));
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              String username = post['Username'];
              String message = post['PostMessage'];
              int leaderCount = post['LeaderCount'] ?? 0;
              int maxLeaders = post['LeaderMaxCount'] ?? 5;
              int currentCount = post['CurrentCount'] ?? 0;
              int targetCount = post['TargetCount'] ?? 10;
              String? imageUrl = post['ImageUrl'];
              final postId = post.id;
              final postData = post.data() as Map<String, dynamic>;
              String status = postData['status'] ?? 'unknown';
              List<dynamic> leaders = post['Leaders'] ?? [];
              List<dynamic> appliedUsers = post['AppliedUsers'] ?? [];
              bool isLeader = leaders.contains(currentUserEmail);
              bool isVolunteer = appliedUsers.contains(currentUserEmail);
              DateTime eventDate =
                  post['EventDate']?.toDate() ?? DateTime.now();
              // Format to 'yyyy-MM-dd'
              String formattedEventDate =
                  "${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}";
              
              // Hide posts with conflicting dates unless it's the applied post
              if (shouldHidePost(postId, eventDate)) {
                return Container();
              }
             final location = post['Location'];
              if (location == null) return Container(); // Skip if location is not available

              double latitude = 0.0;
              double longitude = 0.0;

              // If location is a map with latitude and longitude
              if (location is Map) {
                latitude = location['latitude']?.toDouble() ?? 0.0;
                longitude = location['longitude']?.toDouble() ?? 0.0;
              } 
              // If location is a string
              else if (location is String) {
                try {
                  List<String> locationParts = location.split(',');
                  latitude = double.tryParse(locationParts[0]) ?? 0.0;
                  longitude = double.tryParse(locationParts[1]) ?? 0.0;
                } catch (e) {
                  print('${'Error parsing location:'.tr()} $e');
                }
              }
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
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.more_horiz,
                                  color:
                                      Theme.of(context).colorScheme.inversePrimary),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.report_gmailerrorred),
                                        title: Text('Report Problem').tr(),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.pushNamed(
                                              context, 'Contact_us_page');
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            
                             StatusDot(
                                onTap: () => StatusUtils.showStatusDialog(context, status), // Call static method
                                color: StatusUtils.getStatusColor(status), // Call static method
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(username),
                            SizedBox(
                              width: 7,
                            ),
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: userData?['profilePicture'] !=
                                      null
                                  ? NetworkImage(userData!['profilePicture'])
                                  : const AssetImage(
                                          'assets/photo_2024-11-02_19-33-14.jpg')
                                      as ImageProvider,
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // ...[
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Location button: on pressed, navigate to EventMapPage
                            IconButton(
                              icon: Icon(Icons.location_on,size: 21, color: Colors.red,),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => 
                                    EventMapPage(
                                      latitude: latitude,
                                      longitude: longitude,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Text(
                              "${"Event Date:".tr()}$formattedEventDate" ,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ).tr(),
                          ],
                        ),
                        // ],
                        SizedBox(height: 10),
                        Text(message , textAlign: TextAlign.justify,),
                        if (imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Image.network(imageUrl,
                                width: 100, height: 100),
                          ),
                        SizedBox(height: 16),
                        // Supervisor progress and button
                        LinearProgressIndicator(
                          value: leaderCount / maxLeaders,
                          minHeight: 6,
                          color: Colors.orange,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                        ),
                        Row(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (isLeader) {
                                  await database
                                      .cancelLeaderApplication(postId);
                                } else {
                                  // Remove from Volunteers if they apply as Supervisor
                                  if (isVolunteer) {
                                    await database.cancelApplication(postId);
                                  }
                                  await database.applyAsLeader(
                                      postId, eventDate);
                                }
                                // Fetch applied posts and rebuild
                                fetchAppliedPosts();

                                //  setState(() {

                                //  });
                              },
                              child: Text(
                                isLeader
                                    ? "Cancel as Leader".tr()
                                    : "Apply as Leader".tr(),
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        const Color.fromARGB(255, 169, 101, 5)),
                              ).tr(),
                            ),
                            Flexible(child: Text('$leaderCount /$maxLeaders (${"Leaders".tr()})',style: TextStyle(fontSize: 14),)),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Volunteer progress and button
                        LinearProgressIndicator(
                          value: currentCount / targetCount,
                          minHeight: 6,
                          color: Theme.of(context).colorScheme.inversePrimary,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (isVolunteer) {
                                  await database.cancelApplication(postId);
                                } else {
                                  // Remove from Supervisors if they apply as Volunteer
                                  if (isLeader) {
                                    await database
                                        .cancelLeaderApplication(postId);
                                  }
                                  await database.applyToEvent(
                                      postId, eventDate);
                                }
                                fetchAppliedPosts();
                              },
                              child: Text(
                                isVolunteer ? "Cancel".tr() : "Apply".tr(),
                                style: TextStyle(fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary),
                              ).tr(),
                            ),
                            Flexible(child: Text('$currentCount / $targetCount (${"Volunteers" .tr()})', style: TextStyle(fontSize: 14),)),
                          ],
                        ),
                        if (isLeader) ...[
                          Wrap(
                            spacing: 5,
                            children: appliedUsers
                                .map<Widget>((volunteer) => Chip(
                                      label: Text(volunteer ,overflow: TextOverflow.clip,),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.surface,
                                    ))
                                .toList(),
                          ),
                        ]
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
