import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_progect_v2/components/my_back_button.dart';
import 'package:graduation_progect_v2/helper/err_message.dart';


class UsersLogPage extends StatelessWidget {
  const UsersLogPage({super.key});
  
   // Function to update userType in Firestore
  Future<void> updateUserType(String userId, String newType, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'userType': newType});
      displayMessageToUser("User type updated successfully!", context);
    } catch (e) {
      displayMessageToUser("Failed to update user type: $e", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
     body: StreamBuilder(stream: FirebaseFirestore.instance.collection("Users").snapshots(),
      builder: (context , snapshot) {
      //any errors
      if (snapshot.hasError){
        displayMessageToUser("Something went wrong", context);
      }
      //loading circle
      if (snapshot.connectionState == ConnectionState.waiting){
        return const Center(
        child: CircularProgressIndicator(),
        );
      }

      if (snapshot.data == null){
        return const Text("No data");
      }

      // get all users
      final users = snapshot.data!.docs;

      return Column(
        children: [
          //backbutton & title
               Padding(
                 padding: const EdgeInsets.only(
                  top: 40,
                  left: 10
                  ),
                 child: Row(
                   children: [
                     MyBackButton(),
                    
                    SizedBox(width: 70,),
                     Text(
              "Users Log",
              style: GoogleFonts.roboto(
                color: Theme.of(context).colorScheme.inversePrimary,
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
                   ],
                 ),
               ),               
             
             
            
             //list of users log
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(1),
              itemCount : users.length ,
              itemBuilder: (context, index) {
                final user = users[index];
                final userId = user.id;
                final currentType = user.data()?['userType'] ?? "Unknown Type";

                return  SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary, // background color of the ListTile
                      border: Border.all(color: const Color.fromARGB(255, 145, 167, 207), width: 2.0), // border color and width
                      borderRadius: BorderRadius.circular(15), // rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // shadow color
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),child: ListTile( 
                      dense: true,
                      title:  Text(user.data()?['username'] ?? "Unknown Username"),
                      subtitle:Text(user.data()?['email'] ?? "No Email"),
                      trailing: DropdownButton<String>(
                            value: currentType,
                            items:  [
                              DropdownMenuItem(
                                value: "Volunteer",
                                child: Text("Volunteer", style: GoogleFonts.roboto(
                                color: Theme.of(context).colorScheme.inversePrimary,
                                textStyle:  TextStyle(
                                  fontSize: 14,
                                    ),
                                   ),),
                              ),
                              DropdownMenuItem(
                                value: "University",
                                child: Text("University", style: GoogleFonts.roboto(
                                color: Theme.of(context).colorScheme.inversePrimary,
                                textStyle:  TextStyle(
                                  fontSize: 14,
                                    ),
                                   ), ),
                              ),
                              DropdownMenuItem(
                                value: "Ngo",
                                child: Text("Ngo" ,style: GoogleFonts.roboto(
                                color: Theme.of(context).colorScheme.inversePrimary,
                                textStyle:  TextStyle(
                                  fontSize: 14,
                                    ),
                                   ),),
                              ),
                              DropdownMenuItem(
                                value: "Leader",
                                child: Text("Leader" , style: GoogleFonts.roboto(
                                color: Theme.of(context).colorScheme.inversePrimary,
                                textStyle:  TextStyle(
                                  fontSize: 14,
                                    ),
                                   ),),
                              ),
                              DropdownMenuItem(
                                value: "Admin",
                                child: Text("Admin" , style: GoogleFonts.roboto(
                                color: Theme.of(context).colorScheme.inversePrimary,
                                textStyle:  TextStyle(
                                  fontSize: 14,
                                    ),
                                   ),),
                              ),
                            ],
                            onChanged: (newValue) {
                              if (newValue != null && newValue != currentType) {
                                updateUserType(userId, newValue, context);
                              }
                            },
                          ),
                      // style : ListTileStyle.drawer,
                                
                                 ) 
                   ),
                );
              }
            ),
          ),
        ],
      );
      }, 
      ),
   
    );
  }
}
