import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/components/my_drawer.dart';
import 'package:graduation_progect_v2/database/firestore.dart';
import 'package:graduation_progect_v2/helper/event_location_users.dart';
import 'package:graduation_progect_v2/helper/status.dart';


class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirestoreDatabase database = FirestoreDatabase();
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  String? currentUserType; // Store the logged-in user's type
  List<String> appliedVolunteerPostIds = []; // Track posts applied as volunteers
  List<DateTime> appliedVolunteerEventDates = []; // Event dates for volunteers
   //user type
   String? userType; 

    int selectedIndex = 1;
  
    
   final FirebaseAuth auth = FirebaseAuth.instance;
   final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user;
  Map<String, dynamic>? userData;
  bool isLoading = true;


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
  // Update selected index and navigate to the appropriate page
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  } 
@override
  void initState() {
    super.initState();
    fetchAppliedPosts(); // Fetch applied posts on initialization
    database.updateEventStatus();
    getUserData();
  }

  // Fetch the posts the user has applied to
  void fetchAppliedPosts() async {
    if (currentUserEmail != null) {
      final volunteerPostsSnapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .where('AppliedUsers', arrayContains: currentUserEmail)
          .get();

      setState(() {
        appliedVolunteerPostIds =
            volunteerPostsSnapshot.docs.map((doc) => doc.id).toList();
        appliedVolunteerEventDates = volunteerPostsSnapshot.docs
            .map((doc) => (doc['EventDate'] as Timestamp).toDate())
            .toList();
      });
    }
  }

  // Check if a post should be hidden due to a conflicting date
  bool shouldHidePost(String postId, DateTime eventDate) {
    // Show posts already applied by the user
    if (appliedVolunteerPostIds.contains(postId)) {
      return false;
    }

    // Check for conflicting event dates
    return appliedVolunteerEventDates.any((date) =>
        date.year == eventDate.year &&
        date.month == eventDate.month &&
        date.day == eventDate.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Volunteers Page".tr()))),
      drawer:  MyDrawer(),
      body: StreamBuilder(
        // Filter events with "Upcoming" status
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .where('status', isEqualTo: 'upcoming')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;
          if (posts.isEmpty) {
            return Center(child: Text("No Upcoming Events Yet.".tr()));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              String username = post['Username'];
              String userEmail = post['UserEmail'];
              String message = post['PostMessage'];
              int leaderCount = post['LeaderCount'] ?? 0;
              int maxLeaders = post['LeaderMaxCount'] ?? 5; 
              int currentCount = post['CurrentCount'] ?? 0;
              int targetCount = post['TargetCount'] ?? 10;
              String? imageUrl = post['ImageUrl'];
              final postId = post.id;
              final postData = post.data() as Map<String, dynamic>;
              String status = postData['status']  ;
              List<dynamic> appliedUsers = post['AppliedUsers'] ?? [];
              bool hasApplied = appliedUsers.contains(currentUserEmail);
              DateTime eventDate = post['EventDate']?.toDate() ?? DateTime.now();
              // Format to 'yyyy-MM-dd'
              String formattedEventDate =
               "${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}";
 
              // Hide conflicting posts
              if (shouldHidePost(postId, eventDate)) {
                return Container(); // Skip rendering this post
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
                  print('Error parsing location: $e');
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
                    child:ListTile(
                title: Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween ,
                  children: [
                     Row(
                       children: [
                         IconButton(
                              icon: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.inversePrimary),
                              onPressed: () {
                                showModalBottomSheet(
                                          context: context,
                                          builder: (context) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: Icon(Icons.report_gmailerrorred),
                                                title: Text('Report Problem'.tr()),
                                                onTap: (){
                                                 Navigator.pop(context);
                                                 // navigat ot user
                                                  Navigator.pushNamed(context, 'Contact_us_page');
                                                  }
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

                         SizedBox(width: 7,),

                          //pic of user
                                   CircleAvatar(
                                  radius: 25,
                                  backgroundImage: userData?['profilePicture'] != null
                                      ? NetworkImage(userData!['profilePicture'])
                                      : const AssetImage('assets/photo_2024-11-02_19-33-14.jpg')
                                          as ImageProvider,
                                   ),
                            ],
                          ),
                    
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //  ...[
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
                              "${'Event Date:'.tr()} $formattedEventDate",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                    // ],
                    SizedBox(height: 11,),
                     
                    Text(message),
                    
                    SizedBox(height: 20,),

                    if (imageUrl != null) Image.network(imageUrl, width: 100, height: 100),
                          SizedBox(height: 20),
                          LinearProgressIndicator(
                            value: leaderCount / maxLeaders,
                            minHeight: 6,
                            color: Colors.orange,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                          ),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [ 
                         
                           Text('$leaderCount / $maxLeaders ${'(Leaders)'.tr()}'),
                        ],),
                      
                      SizedBox(height: 15,),
                      Divider(height: 21, indent: 1,endIndent: 1,),
                      SizedBox(height: 20,),

                    LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(5),
                    value: currentCount / targetCount ,
                    minHeight: 6,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    backgroundColor: Theme.of(context).colorScheme.surface,),
                    Row( 
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        ElevatedButton(
                          onPressed: () async {
                            if (hasApplied) {
                              await database.cancelApplication(postId);
                            } else {
                              await database.applyToEvent(postId , eventDate);
                            }
                            fetchAppliedPosts(); // Refresh applied posts
                          },
                          child: Text(hasApplied ? "Cancel".tr() : "Apply".tr() ,style: TextStyle(color :Theme.of(context).colorScheme.inversePrimary,)),
                        ),

                        Text('$currentCount / $targetCount ${'(Volnteers)'.tr()}'),
                      ],
                    ),                  
                  ],
                ),),),
              );
            },
          );
        },
      ),
  
    );
  }
}
