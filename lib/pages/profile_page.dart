import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_progect_v2/components/my_back_button.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
   ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // create logged in user
  final User ?  currentUser = FirebaseAuth.instance.currentUser ;

  File? _selectedImage;

  final ImagePicker profileImPicker = ImagePicker();

  final FirebaseStorage storage = FirebaseStorage.instance;

  // future fetch user details
  Future<DocumentSnapshot<Map<String , dynamic>>> getUserDetails() async{
    if (currentUser == null) {
    throw Exception('No user logged in');
    // print("the err  is hhereee");
  }
   return await FirebaseFirestore.instance
   .collection("Users")
   .doc(currentUser!.email)
   .get();
  }

   // Method to pick an image
  Future<void> pickProfImage() async {
    final pickedFile = await profileImPicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

   // Method to upload image to Firebase Storage
  Future<void> uploadProfImage() async {
    if (_selectedImage == null) return;

    try {
      final ref = storage.ref().child('uploaded_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_selectedImage!);
      final imageUrl = await ref.getDownloadURL();
      print('Image uploaded successfully: $imageUrl');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully! URL: $imageUrl")),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<DocumentSnapshot<Map<String,dynamic>>>(
        future: getUserDetails(),
        builder: (context ,snapshot){
        //loding circle
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        //error 
        else if (snapshot.hasError){
          return Text("Error : ${snapshot.error}");
        }
        


        
        //data resciving
        else if(snapshot.hasData && snapshot.data != null){

          //extract data
         Map<String ,dynamic>?  user = snapshot.data!.data();
        if (user == null) {
         return const Text('No user data found');
  }
         return  Center(
           child: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //backbutton
               Padding(
                 padding: const EdgeInsets.only(
                  top: 40,
                  left: 10
                  ),
                 child: Row(
                   children: [
                     MyBackButton(),
                   ],
                 ),
               ),

             Container(
              decoration: BoxDecoration( 
              color: Theme.of(context).colorScheme.primary,
              shape : BoxShape.circle
              ),
              padding: EdgeInsets.all(50),
              
             ),
             SizedBox(height: 15,),
             Text(
              user['username'],
              style:  GoogleFonts.roboto(fontSize: 20 ,fontWeight: FontWeight.w600),
             ), 
             Text(
              user['email'],
               style:  GoogleFonts.roboto(fontSize: 14 ,fontWeight: FontWeight.w300 , color: Theme.of(context).colorScheme.secondary),
              ),
             SizedBox(height: 10,) ,
             Divider(height: 10, indent: 20,endIndent: 20,),

              
            ],
           ),
         );
        }
        //if we have nothing
        else{
          return const Text('No Data');
          }
         
      }
      ),
    );
  }
}



// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }


// class _ProfilePageState extends State<ProfilePage> {
//   bool _isPhotoExpanded = false;


//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color.fromARGB(255, 207, 161, 101),
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).colorScheme.inverseSurface,
//           title: Center(
//             child: Padding(
//               padding: const EdgeInsets.only(right: 40),
//               child: Text("My Profile",
//               style: GoogleFonts.roboto(
//                     color: Theme.of(context).colorScheme.onPrimary,
//                     textStyle: const TextStyle(
//                       fontSize: 20,
//                     ),
//                   ),
//               ),
//             ),
//           ),
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _isPhotoExpanded = !_isPhotoExpanded;
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     width: _isPhotoExpanded ? 150.0 : 100.0,
//                     height: _isPhotoExpanded ? 150.0 : 100.0,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       image: DecorationImage(
//                         image: NetworkImage(
//                             'https://via.placeholder.com/150'), // Placeholder Image
//                         fit: BoxFit.cover,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 10.0,
//                           spreadRadius: 1.0,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   'WISE',
//                   style: TextStyle(
//                     fontSize: 24.0,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal[800],
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'We are the bist university',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16.0,
//                     color: Colors.grey[700],
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                  RatingBar.builder(
//                   initialRating: 4.5,
//                   minRating: 1,
//                   direction: Axis.horizontal,
//                   allowHalfRating: true,
//                   itemCount: 5,
//                   itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                   itemBuilder: (context, _) => Icon(
//                     Icons.star,
//                     color: Colors.amber,
//                   ),
//                   onRatingUpdate: (rating) {
//                     print(rating);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }





