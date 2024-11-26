import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_progect_v2/components/my_buttons.dart';
import 'package:graduation_progect_v2/components/my_textfield.dart';
import 'package:graduation_progect_v2/helper/err_message.dart';

// ignore: must_be_immutable
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.registerPageTap});

  final Function()? registerPageTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController userNameControler = TextEditingController();

  final TextEditingController emailControler = TextEditingController();

  final TextEditingController passwordControler = TextEditingController();

  final TextEditingController confirmPasControler = TextEditingController();
  
  TextEditingController birthDateControler = TextEditingController();
  // final TextEditingController birthdayController = TextEditingController();
  DateTime? selectedBirthDate;
  String? selectedGender;
  String? selectedCity;
  String? selectedUserType; // New variable to store user type selection

  void registerUser() async {
    // loding circle
    showDialog(
      context: context,
      builder: (context) =>  Center(
        child: CircularProgressIndicator(),
        
      ),
      
      
    );
    if (passwordControler.text != confirmPasControler.text) {
    // Dismiss loading circle
    Navigator.pop(context);

    // Show error message
    displayMessageToUser("Passwords don't match!", context);
  } else {
    try {
      // Create user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailControler.text, password: passwordControler.text);

      // Create a user document in Firestore
      await creatUserDocument(userCredential);

      // Dismiss loading circle
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Navigate to the appropriate page based on user type
      if (userCredential.user != null) {
        await handleUserNavigation(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      // Dismiss loading circle
      Navigator.pop(context);

      // Show error message
      displayMessageToUser(e.code, context);
    }
  }
}
    
    void navigateToPage(String userType) {
  if (userType == "Ngo") {
    Navigator.pushReplacementNamed(context, 'Ngo_page');
  } else if (userType == "Volunteer") {
    Navigator.pushReplacementNamed(context, 'User_page');
  } else if (userType == "Leader") {
    Navigator.pushReplacementNamed(context, 'Leader_page');
  } else {
    // Default page for undefined user types
    // Navigator.pushReplacementNamed(context, 'Home_page');
  }
}

Future<void> handleUserNavigation(User user) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final userDoc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.email)
        .get();

    final userType = userDoc['userType'];
    navigateToPage(userType);
  }
}

   // Date Picker function
  Future<void> selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1999),
      firstDate: DateTime(1950),
      lastDate: DateTime(2008),
    );
    if (picked != null && picked != selectedBirthDate) {
      setState(() {
        selectedBirthDate = picked;
        birthDateControler.text = "${picked.toLocal()}".split(' ')[0]; // Display in yyyy-MM-dd format
      });
    }
  }

  // user doucument colect to firebase
  Future<void> creatUserDocument(UserCredential? userCredential) async {
    if(userCredential != null && userCredential.user != null && selectedBirthDate != null) {
      await FirebaseFirestore.instance.collection("Users")
      .doc(userCredential.user!.email)
      .set({
        'email' :userCredential.user!.email ,
        'username' :userNameControler.text  ,
        'userType': selectedUserType , // Assign default type if none selected
        'city': selectedCity,
        'birthday': selectedBirthDate,
        'gender': selectedGender,
      });
    }else {
        // Show error if no birthdate is selected
        showDialog(context: context, builder:(context) =>  Text('Please select your birthdate'));
      }
  }
  

  Future<void> checkEmailVerification(User? user) async {
    if (user == null) return print('User is not here lol');


    // Check if email is verified and wait until it's verified.
    bool isVerified = user.emailVerified;


    while (!isVerified) {
      // Wait for 2 seconds before checking the status again
      await Future.delayed(Duration(seconds: 2));


      // Reload the user's data to check the latest email verification status
      await user.reload();


      // Get the updated email verification status
      isVerified = user.emailVerified;
    }


    if (isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email verified! You can now proceed.')),
      );


      // Navigate to hobbies selection page after successful verification
      // Navigator.pushReplacement(
        // context,
        // MaterialPageRoute(builder: (context) => HobbiesSelectionPage()),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 90,
                ),

                Icon(
                  Icons.person,
                  size: 90,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),

                const SizedBox(
                  height: 25,
                ),

                Text(
                  "V o l u n t e e r s",
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w300),
                  ),
                ),

                const SizedBox(
                  height: 50,
                ),

                // Username textfield
                MyTextfield(
                    hintText: "Username",
                    obscuretext: false,
                    controller: userNameControler),

                const SizedBox(
                  height: 14,
                ),
                
               // Email textfield
                MyTextfield(
                    hintText: "Email",
                    obscuretext: false,
                    controller: emailControler),

                const SizedBox(
                  height: 14,
                ),

                // Password textfield
                MyTextfield(
                    hintText: "Password",
                    obscuretext: true,
                    controller: passwordControler),

                const SizedBox(
                  height: 14,
                ),

                MyTextfield(
                    hintText: "Confirm Password",
                    obscuretext: true,
                    controller: confirmPasControler),

                const SizedBox(
                  height: 14,
                ),

                Row(
              children: [
                 Expanded(
                  child: TextField(
                    controller: birthDateControler,
                    cursorColor: Theme.of(context).colorScheme.inversePrimary,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Birth Date',
                      labelStyle: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => selectBirthDate(context),
                ),
              ],
            ),

                const SizedBox(
                  height: 14,
                ),
                 
                 PopupMenuButton<String>(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  onSelected: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: "Male", child: Column(
                      children: [
                        Text("Male"),
                        SizedBox(height: 10,),
                        Divider(height: 5,)
                      ],
                    )),
                    PopupMenuItem(value: "Female", child: Column(
                      children: [
                        Text("Female"),
                        SizedBox(height: 10,),
                        Divider(height: 5,)
                      ],
                    )),
                    ],
                    child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                    decoration: BoxDecoration(
                      // color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.inversePrimary,
                       // width: 1.0, // Border width
                           ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedGender ?? "Select Gender Type",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w300 ,
                        fontSize: 16 ,
                        color: Theme.of(context).colorScheme.inversePrimary)
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                    ),

                const SizedBox(
                  height: 14,
                ),

                // User Type Selection Dropdown
                PopupMenuButton<String>(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  onSelected: (value) {
                    setState(() {
                      selectedUserType = value;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: "Ngo", child: Column(
                      children: [
                        Text("Ngo"),
                        SizedBox(height: 10,),
                        Divider(height: 5,)
                      ],
                    )),
                    PopupMenuItem(value: "Volunteer", child: Column(
                      children: [
                        Text("Volunteer"),
                        SizedBox(height: 10,),
                        Divider(height: 5,)
                      ],
                    )),
                    PopupMenuItem(value: "University", child: Column(
                      children: [
                        Text("University"),
                        SizedBox(height: 10,),
                        Divider(height: 5,)
                      ],
                    )),
                  ],
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                    decoration: BoxDecoration(
                      // color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.inversePrimary,
                       // width: 1.0, // Border width
                           ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedUserType ?? "Select User Type",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w300 ,
                        fontSize: 16 ,
                        color: Theme.of(context).colorScheme.inversePrimary)
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                
                 
                const SizedBox(
                  height: 14,
                ),

                
                
               
                
                   

                // city selector
                PopupMenuButton<String>(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  onSelected: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
      value: "Amman",
      child: Column(
        children: [
          Text("Amman"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                    PopupMenuItem(
      value: "Irbid",
      child: Column(
        children: [
          Text("Irbid"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                    PopupMenuItem(
      value: "Zarqa",
      child: Column(
        children: [
          Text("Zarqa"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                    PopupMenuItem(
      value: "Balqa",
      child: Column(
        children: [
          Text("Balqa"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                    PopupMenuItem(
      value: "Madaba",
      child: Column(
        children: [
          Text("Madaba"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                    PopupMenuItem(
      value: "Aqaba",
      child: Column(
        children: [
          Text("Aqaba"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                    PopupMenuItem(
      value: "Mafraq",
      child: Column(
        children: [
          Text("Mafraq"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                    PopupMenuItem(
      value: "Jerash",
      child: Column(
        children: [
          Text("Jerash"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                    PopupMenuItem(
      value: "Ajloun",
      child: Column(
        children: [
          Text("Ajloun"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                    PopupMenuItem(
      value: "Karak",
      child: Column(
        children: [
          Text("Karak"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                    PopupMenuItem(
      value: "Tafilah",
      child: Column(
        children: [
          Text("Tafilah"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                    PopupMenuItem(
      value: "Ma'an",
      child: Column(
        children: [
          Text("Ma'an"),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
                  ],
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                         selectedCity ?? "Select City",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),

                // MyTextfield(
                //     hintText: "City",
                //     obscuretext: false,
                //     controller: cityController),

                const SizedBox(
                  height: 14,
                ),

                
                MyButton(buttonText: "Register", onTap: () {
                  
                  setState(() {
                       registerUser();
                    // registerUser();
                 //pop out drawer
                     Navigator.pop(context);
                    // navigat to 
                    // Navigator.pushNamed(context, 'User_Ngo_page');  
                  });
                  
                }, 
                ),

                const SizedBox(
                  height: 7,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.registerPageTap,
                      child:  Text(
                        " Login Here",
                        style:  GoogleFonts.roboto(fontSize: 14 ,fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
