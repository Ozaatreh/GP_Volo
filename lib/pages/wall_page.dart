import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_progect_v2/components/my_drawer.dart';
import 'package:graduation_progect_v2/database/firestore.dart';
import 'package:image_picker/image_picker.dart';

class WallPage extends StatefulWidget {
    WallPage({super.key});

  @override
  State<WallPage> createState() => _WallPageState();
}

class _WallPageState extends State<WallPage> {
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
              "W A L L",
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
      drawer: const MyDrawer(),
      body: 
      
          // test post field
          // Column(
          //   children: [
          //     // Show "Post Something" row only if userType is "Company"
          //     if (userType == "Company")
          //     Padding(
          //       padding: const EdgeInsets.all(25.0),
          //       child: Row(
          //         children: [
          //           Expanded(
          //             child: MyTextfield(
          //               hintText: "Post Somthing ..",
          //               obscuretext: false,
          //               controller: newPostController),
          //           ),
          //           IconButton(
          //             icon: Icon(Icons.image),
          //             onPressed: pickImage,),
          //           PostButton(onTap:() {
          //           postMessage();
          //           setState(() {
          //           selectedImage =null ;
          //           newPostController.clear();
                      
          //           });
                      
          //           }
          //           ),
                      
          //         ],
          //       ),
          //       ),
                
          //       // SizedBox(height: -3,),
          //       // if (userType == "Company")
          //       // Event size input field
          //     Row(
          //       // crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         // Text(" Enter Event Size"),
          //         SizedBox(width: 24,),
          //         Expanded(
          //           child: TextField(
          //             enabled: true,
          //             controller: eventSizeController,
          //             keyboardType: TextInputType.number,
          //             style: TextStyle(fontSize: 14),
          //             decoration: InputDecoration(
          //             label :Text(" Enter Event Size",
          //             style: GoogleFonts.roboto(fontSize: 16,fontWeight: FontWeight.w300),),
          //               border: OutlineInputBorder(
          //                 borderRadius: BorderRadius.circular(10),
          //               ),
          //             ),
          //           ),
          //         ),
          //         SizedBox(width: 10),
          //         // Small square to represent the event size
          //         Container(
          //           width: 30,
          //           height: 30,
          //           decoration: BoxDecoration(
          //             color: Theme.of(context).colorScheme.primary,
          //             borderRadius: BorderRadius.circular(5),
          //           ),
          //           child: Center(
          //             child: Text(
          //               eventSizeController.text.isEmpty
          //                   ? "0"
          //                   : eventSizeController.text,
          //               style: GoogleFonts.roboto(fontSize: 16,fontWeight: FontWeight.w300),
          //             ),
          //           ),
          //         ),
          //         SizedBox(width: 100),
          //       ],
          //     ),
            
          //   SizedBox(height: 10,)
          //   ],
          //     ),
            
   
          //Posts
          StreamBuilder(stream: database.getAllPostStream(), builder: (context, snapshot) {
            //loading circle
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            //get all posts
            final posts = snapshot.data!.docs ;
            
            // no data
            if(posts.isEmpty){
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("No Events Yet.. !"),
                ),
              );
            }

            //return as a list
            return ListView.builder(
            
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                String username = post['Username'] ;
                String userEmail = post['UserEmail'];
                String userType = post['UserType'] ;
                String message = post['PostMessage'];
                int leaderCount = post['LeaderCount'] ?? 0;
                int maxLeaders = post['LeaderMaxCount']; 
                int currentCount = post['CurrentCount'] ?? 0;
                int targetCount = post['TargetCount'] ?? 10;  // Default target
                String? imageUrl = post['ImageUrl'];
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
                           IconButton(icon:Icon(Icons.more_horiz),
                            onPressed: () {
                               showModalBottomSheet(
                                 context: context,
                                 builder: (context) => Column(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     
                                     // Show delete only for own posts or moderators
                                     if (currentUserEmail=="al@gmail.com" || userEmail == currentUserEmail) 
                                     ListTile(
                                       leading: Icon(Icons.delete),
                                       title: Text('Delete Post'),
                                       onTap: () async {
                                         await database.deletePost(postId);
                                         Navigator.pop(context);
                                       },
                                     ),
                                     ListTile(
                                       leading: Icon(Icons.report_gmailerrorred),
                                       title: Text('Report Problem'),
                                       onTap: (){
                                        Navigator.pop(context);
                                        // navigat ot user
                                         Navigator.pushNamed(context, 'Contact_us_page');
                                         }
                                       ),
                                     
                                     
                                   ],
                                 ),
                               );
                             }, ),
                                                          
                                                          
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
                                   Container(
                                   decoration: BoxDecoration( 
                                   color: Theme.of(context).colorScheme.primary,
                                   shape : BoxShape.circle
                                   ),
                                   padding: EdgeInsets.all(6),
                                   child: Icon(Icons.person),
                                    ),
                                 ],
                               ),
                                 if (eventDate != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    "Event Date: $eventDate",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.inversePrimary,
                                    ),
                                  ),],
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
