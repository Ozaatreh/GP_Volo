import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_progect_v2/components/my_drawer.dart';
import 'package:graduation_progect_v2/database/firestore.dart';
import 'package:graduation_progect_v2/helper/event_location_users.dart';
import 'package:graduation_progect_v2/helper/status.dart';
import 'package:image_picker/image_picker.dart';

class AdminWall extends StatefulWidget {
    AdminWall({super.key});

  @override
  State<AdminWall> createState() => AdminWallWallPageState();
}

class AdminWallWallPageState extends State<AdminWall> {
  // access the firestore class 
  final FirestoreDatabase database = FirestoreDatabase();

  final TextEditingController newPostController = TextEditingController();
 
  // For the event size
  final TextEditingController eventSizeController = TextEditingController(); 
  File? selectedImage;

  // Image picker to select an image
  final ImagePicker picker = ImagePicker();

  // to ensure that the user can do hiss own operation on post  
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  
  //user type
  String? userType; 

     final FirebaseAuth auth = FirebaseAuth.instance;
   final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  
   @override
  void initState() {
    super.initState();
    database.updateEventStatus();
    getUserData();
  }

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
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }
  
  // methode of picking image 
   Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path); // Update selectedImage and refresh UI
      });
  //   print("Image selected: ${selectedImage!.path}"); // Debug log}
  // } else {
  //   print("No image selected.");
  }
  }

   // Updated post function to handle message and image
  Future<void> postMessage() async {
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      String? imageUrl;
      int eventSize = int.tryParse(eventSizeController.text) ?? 10; 
      
    // Check if an image is selected and upload it
    if (selectedImage != null) {
      imageUrl = await database.uploadImage(selectedImage!);
      // print("Image uploaded successfully: $imageUrl"); // Debug log for image URL
    } else {
      // print("No image selected for upload.");
    }
      // Add post with image URL if available
      await database.addPost(message, imageUrl: imageUrl ,targetCount: eventSize);
      newPostController.clear();
      selectedImage = null; // Reset image selection
      eventSizeController.clear();
    }
  }

  void logout() { 
    setState(() {
   FirebaseAuth.instance.signOut();   
    });
    
  }
  

  
  
  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Text(
              "A D M I N   W A L L",
              style: GoogleFonts.roboto(
                color: Theme.of(context).colorScheme.inversePrimary,
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
                
              ),
            ),
          ),
        ),
        // elevation: 0,
      ),
      drawer:  MyDrawer(),
      body: 
         
          //Posts
          StreamBuilder(
            stream: database.getAllPostStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;
          if (posts.isEmpty) {
            return Center(child: Text("No events Yet.."));
          }

            
            //return as a list
            return ListView.builder(
            
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                String username = post['Username'] ;
                String userEmail = post['UserEmail'];
                // String userType = post['UserType'] ;
                String message = post['PostMessage'];
                int leaderCount = post['LeaderCount'] ?? 0;
                int maxLeaders = post['LeaderMaxCount']; 
                int currentCount = post['CurrentCount'] ?? 0;
                int targetCount = post['TargetCount'] ?? 10;  // Default target
                String? imageUrl = post['ImageUrl'];
                final postData = post.data() as Map<String, dynamic>;
                String status = postData['status']  ;
                final postId = post.id; // Get document ID for delete
                List<dynamic> appliedUsers = post['AppliedUsers'] ?? [];
                Timestamp? eventTimestamp = post['EventDate']; // Retrieve the event date field
                   String? eventDate = eventTimestamp != null
                    ? DateTime.fromMillisecondsSinceEpoch(eventTimestamp.millisecondsSinceEpoch)
                        .toLocal()
                        .toString()
                        .split(' ')[0] // Format the date as yyyy-MM-dd
                    : null;
                bool hasApplied = appliedUsers.contains(FirebaseAuth.instance.currentUser!.email);
                
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
                return  Padding(
                  padding: const EdgeInsets.only(bottom: 20), 
                  child: Card
                  (color: Theme.of(context).colorScheme.primary,
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
                               IconButton(icon:Icon(Icons.more_horiz),
                                onPressed: () {
                                   showModalBottomSheet(
                                     context: context,
                                     builder: (context) => Column(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         
                                         // Show delete only for own posts or moderators
                                         ListTile(
                                           leading: Icon(Icons.delete),
                                           title: Text('Delete Post'),
                                           onTap: () async {
                                             await database.deletePost(postId);
                                             Navigator.pop(context);
                                           },
                                         ),
                                         ListTile(
                                           leading: Icon(Icons.message_rounded),
                                           title: Text('Send Message'),
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
                                                          
                                                          
                           //useremail and username
                           Column(
                            // crossAxisAlignment:CrossAxisAlignment.end,
                             children: [
                               Row(
                                 children: [
                                   Column(
                                    crossAxisAlignment:CrossAxisAlignment.end,
                                     children: [
                                       Text(username, style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500)),
                                       Text(userEmail ,style:  GoogleFonts.roboto(fontSize: 15 ,fontWeight: FontWeight.w300),),
                                     ],
                                   ),
                                   SizedBox(width: 10,),
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
                                 if (eventDate != null) ...[
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
                                    "Event Date: $eventDate",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.inversePrimary,
                                    ),
                                  ),
                                  ],
                        ),
                        ],
                                 ],
                           ),
                                                   
                          //  SizedBox(width: 10,),
                           
                         ],
                       ),
                    
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 20,),
                          
                          Text(message),
                    
                          SizedBox(height: 50,),
                    
                          if (imageUrl != null) // Display image if available
                            Padding(
                              padding:  EdgeInsets.
                              // all(100),
                              only(top: 8.0),
                              child: Image.network(
                                imageUrl,
                                width: 100,
                                height: 100, 
                                fit: BoxFit.cover,
                              ),
                            ),
            
                            SizedBox(height: 30,),
                            LinearProgressIndicator(
                        value: leaderCount / maxLeaders,
                        minHeight: 8,
                        color: Colors.orange,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                     SizedBox(height: 8,),
                      // Supervisor Apply Section
                       Text('$leaderCount / $maxLeaders (Leaders)'),
                                          
                      SizedBox(height: 15,),
                                          Divider(height: 21, indent: 1,endIndent: 1,),
                         SizedBox(height:40 ,),
                         LinearProgressIndicator(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            borderRadius:BorderRadius.circular(5),
                            value: currentCount / targetCount,
                            minHeight: 8,
                          ),
                          SizedBox(height: 8),
                          Text('$currentCount / $targetCount (Volnteers)'),
                            
                        ],
                      ),
                    ),
                  ),
                );
              },
            );

          },)

        // ],
      // ),
    );
  }
}
