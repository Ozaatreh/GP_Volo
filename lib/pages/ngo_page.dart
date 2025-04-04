import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graduation_progect_v2/components/my_drawer.dart';
import 'package:graduation_progect_v2/components/my_textfield.dart';
import 'package:graduation_progect_v2/components/post_button.dart';
import 'package:graduation_progect_v2/database/firestore.dart';
import 'package:graduation_progect_v2/helper/event_location_users.dart';
import 'package:graduation_progect_v2/helper/location_picker.dart';
import 'package:graduation_progect_v2/helper/status.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class NgoPage extends StatefulWidget {
  const NgoPage({super.key});

  @override
  _NgoPageState createState() => _NgoPageState();
}

class _NgoPageState extends State<NgoPage> {
  final FirestoreDatabase database = FirestoreDatabase();
  final CollectionReference post = FirebaseFirestore.instance.collection('Posts');
  final TextEditingController newPostController = TextEditingController();
  final TextEditingController eventSizeController = TextEditingController();
  final TextEditingController leadresController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController(); // Added
  final TextEditingController locationController = TextEditingController();
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  int selectedIndex = 1;
  DateTime? selectedEventDate; // To store the picked date


  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }
  // Event Date
  Future<void> selectEventDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Prevent past dates
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedEventDate = pickedDate;
        eventDateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Display in yyyy-MM-dd format
      });
    }
  }

  Future<void> postEvent() async {
    if (newPostController.text.isNotEmpty && selectedEventDate != null) {
      String message = newPostController.text;
      String? imageUrl;
      int eventSize = int.tryParse(eventSizeController.text) ?? 10;
      int leader = int.tryParse(leadresController.text) ?? 3;
      String location = locationController.text; // Get the location input
      double? latitude;
      double? longitude;

    // Extract latitude and longitude from the location text if needed
    if (location.isNotEmpty) {
      final parts = location.split(',');
      if (parts.length == 2) {
        latitude = double.tryParse(parts[0].substring(4));
        longitude = double.tryParse(parts[1].substring(5));
      }
    }
      if (selectedImage != null) {
        imageUrl = await database.uploadImage(selectedImage!);
      }

      await database.addPost(
        message,
        imageUrl: imageUrl,
        targetCount: eventSize,
        leaderMaxCount: leader,
        eventDate: selectedEventDate,
        location: location, // Store the location
        latitude: latitude,  // Store latitude
        longitude: longitude, // Store longitude
      );
      
      // Schedule Notifications
    //  CustomNotificationState().scheduleEventNotifications(selectedEventDate!);

      newPostController.clear();
      selectedImage = null;
      eventSizeController.clear();
      leadresController.clear();
      eventDateController.clear();
      locationController.clear();
      selectedEventDate = null;

       // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event posted and participants notified!'.tr())),
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
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Text(
              "H o m e".tr(),
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
      body: Column(
        children: [
          if (selectedImage != null)
            Column(
              children: [
                Image.file(selectedImage!, width: screenWidth * 0.8, height: screenWidth * 0.5),
                IconButton(icon: Icon(Icons.cancel_outlined),
                 onPressed: () => setState(() {
                   selectedImage = null;})),
              ],
            ),

          Row(
            children: [
              Expanded(
                child: MyTextfield(
                  hintText: "Post Something..".tr(),
                  obscuretext: false,
                  controller: newPostController,
                ),
              ),
              IconButton(icon: Icon(Icons.image), onPressed: pickImage),
              PostButton(onTap:() async {
                    await postEvent(); 
                    setState(() {
                    selectedImage =null ;
                    newPostController.clear();
                      
                    });
              }, ),
            ],
          ),
          SizedBox(height: 15,),
          Row(
                // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text(" Enter Event Size"),
                  // SizedBox(width: 80,),
                  Expanded(
                    child: TextField(
                      enabled: true,
                      controller: eventSizeController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                      label :Text("Volunteers Count".tr(),
                      style: GoogleFonts.roboto(fontSize: 16,fontWeight: FontWeight.w300),),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      cursorColor: Theme.of(context).colorScheme.inversePrimary,
                      enabled: true,
                      controller: leadresController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                      label :Text("Leaders Count".tr(),
                      style: GoogleFonts.roboto(fontSize: 16,fontWeight: FontWeight.w300),),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  // Small square to represent the event size

                  ], ),

                  const SizedBox(height: 15),

                  // Event Date
                  Row(
                    children: [

                      Expanded(
                        child: TextField(
                          cursorColor: Theme.of(context).colorScheme.inversePrimary,
                          enabled: false,
                          controller: eventDateController,
                          decoration: InputDecoration(
                            labelStyle:TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                            label: Text(
                              "Event Date".tr() ,
                              style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w300 ,
                              color: Theme.of(context).colorScheme.inversePrimary),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: selectEventDate,
                      ),
                    ],
                  ),
                  SizedBox(height: 15,),
                  Row(
  children: [
    Expanded(
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.inversePrimary,
        enabled: false, // Make the text field read-only
        controller: locationController, // Use locationController for displaying selected location
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          label: Text(
            "Event Location".tr(),
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
    IconButton(
      icon: const Icon(Icons.location_on),
      onPressed: () async {
    // Navigate to the LocationPickerPage and wait for the returned selected location
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPickerPage()),
    );

    // Check if the location was selected and set it in the locationController
    if (selectedLocation != null) {
      setState(() {
        locationController.text = '${selectedLocation.latitude}, ${selectedLocation.longitude}';
      });
      print("${'Selected Location:'.tr()} ${locationController.text}");
    }
  },
    ),
  ],
),

        // Divider
        Divider(height: 20, thickness: 2),

        // StreamBuilder to show company posts
        Expanded(
          child: StreamBuilder(
            stream: database.getNgoUserPostsStream(currentUserEmail!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final posts = snapshot.data?.docs ?? [];

              if (posts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("No Posts Yet.. Post Something!".tr()),
                  ),
                );
                }
                return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  String message = post['PostMessage'];
                  String? imageUrl = post['ImageUrl'];
                  int currentCount = post['CurrentCount'] ?? 0;
                  int targetCount = post['TargetCount'] ?? 10;
                  int leaderCount = post['LeaderCount'] ?? 0;
                  final postData = post.data() as Map<String, dynamic>;
                  String status = postData['status']                                                                                                                                                                                                                                        ;
                  int maxLeaders = post['LeaderMaxCount'] ?? 10; 
                  List<dynamic> leaders = post['Leaders'] ?? [];
                  List<dynamic> appliedUsers = post['AppliedUsers'] ?? [];
                  Timestamp? eventTimestamp = post['EventDate']; // Retrieve the event date field
                   String? eventDate = eventTimestamp != null
                    ? DateTime.fromMillisecondsSinceEpoch(eventTimestamp.millisecondsSinceEpoch)
                        .toLocal()
                        .toString()
                        .split(' ')[0] // Format the date as yyyy-MM-dd
                    : null;
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                    child: ListTile(
                      title: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                    leading: Icon(Icons.delete),
                                                    title: Text('Delete Post'.tr()),
                                                    onTap: () async {
                                                      await database.deletePost(post.id);
                                                      Navigator.pop(context);
                                                    },
                                                  ),
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
                                    
                                ],
                              ),
                            SizedBox(height: 10,),
                            if (eventDate != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          "${'Event Date:'.tr()} $eventDate",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.inversePrimary,
                                          ),
                                        ),],
                            ],
                          ),
                          Row(
                            children: [
                              
                              
                            ],
                          ),
                        ],
                      ),
                      
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          
                          Text(
                            message,
                            maxLines: 20, // Limit to 2 lines
                            overflow: TextOverflow.ellipsis,
                          ),
                        
                          SizedBox(height: 20,),
                          if (imageUrl != null)
                            Image.network(
                              imageUrl,
                              width: screenWidth * 0.8,
                              fit: BoxFit.cover,
                            ),
                          SizedBox(height: 40),
                          LinearProgressIndicator(
                            value: leaderCount / maxLeaders,
                            minHeight: 8,
                            color: Colors.orange,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                          ),
                         SizedBox(height: 8,),
                          // Supervisor Apply Section
                           Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             children: [
                               Text('$leaderCount / $maxLeaders (${'Leaders'.tr()})',),
                             ],
                           ),
                        
                          SizedBox(height: 20,),

                           Wrap(
                           spacing: 5,
                           children: leaders
                               .map<Widget>((supervisor) => Chip(
                                     label: Text(supervisor),
                                     backgroundColor: const Color.fromARGB(255, 206, 140, 53),
                                   ))
                               .toList(),
                          ),
                          Divider(height: 21, indent: 1,endIndent: 1,),

                          SizedBox(height: 30),
                          LinearProgressIndicator(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(13),
                            value: currentCount / targetCount,
                            minHeight: 8,
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('$currentCount / $targetCount (${'Volnteers'.tr()})'),
                            ],
                          ),
                          Wrap(
                           spacing: 5,
                           children: appliedUsers
                               .map<Widget>((volunteer) => Chip(
                                     label: Text(volunteer),
                                     backgroundColor: Theme.of(context).colorScheme.surface,
                                   ))
                               .toList(),
                         ),
                         SizedBox(height: 8),
                          Divider(height: 21, indent: 1,endIndent: 1,),
                        ],
                      ),
                    ),),
                  );
                },
                );
            },),
          ),
        ],
      ),
    );
  }
}  