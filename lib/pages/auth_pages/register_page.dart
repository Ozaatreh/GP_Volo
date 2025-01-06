import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? selectedUniversity;
  void registerUser() async {
    // loding circle
    showDialog(
      context: context,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
    if (passwordControler.text != confirmPasControler.text) {
      // Dismiss loading circle
      // Dismiss loading circle
      Navigator.pop(context);

      // Show error message
      displayMessageToUser("Passwords don't match!".tr(), context);
    } else {
      try {
        // Create user
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailControler.text, password: passwordControler.text);

        // Create a user document in Firestore
        await creatUserDocument(userCredential);

        // Dismiss loading indicator
        Navigator.pop(context); 

        // Send verification email
        await userCredential.user!.sendEmailVerification();

        // Display message to check email
        displayMessageToUser(
            "Verification email sent! Please check your inbox.".tr(), context);

        // Navigate based on user type
        handleUserNavigation(userCredential.user!);
      } on FirebaseAuthException catch (e) { 
        // If sign-in fails, display a message to the user.
        // print('Sign in failed with error code: ${e.code}');
        // print(e.message);

        // Dismiss loading indicator and any previous dialogs
        Navigator.popUntil(context, (route) => route.isFirst);
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
    } else if (userType == "Admin") {
      Navigator.pushReplacementNamed(context, 'Admin_page');
    } else if (userType == "University") {
      Navigator.pushReplacementNamed(context, 'University_page');
    }
  }

  Future<void> handleUserNavigation(User user) async {
    // Check if email is verified
    print("handleUserNavigation called");
    await user.reload(); // Reload user data to get the latest verification status
    if (user.emailVerified) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDocSnapshot = await FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .get();

        if (userDocSnapshot.exists) {
          final userType = userDocSnapshot.data()?['userType'] as String;
          navigateToPage(userType);
        } else {
          displayMessageToUser("User document not found!".tr(), context);
        }
      }
    } else {
      print("Email not verified yet");
      // Show a dialog or snackbar prompting the user to verify their email
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Verify Email".tr()),
              content: Text(
                  "Please check your inbox and verify your email to proceed.".tr()),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context), child: Text("OK".tr()))
              ],
            );
          });
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
        birthDateControler.text =
            "${picked.toLocal()}".split(' ')[0]; // Display in yyyy-MM-dd format
      });
    }
  }

  // user doucument colect to firebase
  Future<void> creatUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      // Ensure all required fields are selected
      String userType = selectedUserType ?? 'Volunteer'; // Default to Volunteer
      String city = selectedCity ?? 'Amman'; // Default to Amman
      DateTime birthday = selectedBirthDate!; // Birthdate is now required
      String gender = selectedGender ?? 'Not specified'; // Default to Not specified
      String university = selectedUniversity ?? 'Not specified'; // Default to Not specified

      if (selectedBirthDate == null) {
        displayMessageToUser("Please select your birthdate".tr(), context);
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(userCredential.user!.email)
            .set({
          'email': userCredential.user!.email,
          'username': userNameControler.text,
          'userType': userType, 
          'city': city,
          'birthday': birthday,
          'gender': gender,
          'university': university,
        });
      } catch (e) {
        print("Error creating user document: $e");
        displayMessageToUser("Error creating user document", context);
      }
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

                Image(image: AssetImage("assets/volo_icon1.png") , height: 150, width:150 ),

                const SizedBox(
                  height: 17,
                ),

                Text(
                  "V o l o",
                  style: GoogleFonts.nanumMyeongjo(
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
                    hintText: "Username".tr(),
                    obscuretext: false,
                    controller: userNameControler),

                const SizedBox(
                  height: 14,
                ),

                // Email textfield
                MyTextfield(
                    hintText: "Email".tr(),
                    obscuretext: false,
                    controller: emailControler),

                const SizedBox(
                  height: 14,
                ),

                // Password textfield
                MyTextfield(
                    hintText: "Password".tr(),
                    obscuretext: true,
                    controller: passwordControler),

                const SizedBox(
                  height: 14,
                ),

                MyTextfield(
                    hintText: "Confirm Password".tr(),
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
                        cursorColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Birth Date'.tr(),
                          labelStyle: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
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
                    PopupMenuItem(
                        value: "Male",
                        child: Column(
                          children: [
                            Text("Male").tr(),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              height: 5,
                            )
                          ],
                        )),
                    PopupMenuItem(
                        value: "Female",
                        child: Column(
                          children: [
                            Text("Female").tr(),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              height: 5,
                            )
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
                        Text(selectedGender ?? "Sex".tr(),
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w300,
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
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
                    PopupMenuItem(
                        value: "Ngo",
                        child: Column(
                          children: [
                            Text("Npo").tr(),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              height: 5,
                            )
                          ],
                        )),
                    PopupMenuItem(
                        value: "Volunteer",
                        child: Column(
                          children: [
                            Text("Volunteer").tr(),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              height: 5,
                            )
                          ],
                        )),
                    PopupMenuItem(
                        value: "University",
                        child: Column(
                          children: [
                            Text("University").tr(),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              height: 5,
                            )
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
                        Text(selectedUserType ?? "Select User Type".tr(),
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w300,
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // University selector
                PopupMenuButton<String>(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  onSelected: (value) {
                    setState(() {
                      selectedUniversity =
                          value; // Updating selected university
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: "Not a Student",
                      child: Column(
                        children: [
                          Text("Not a Student").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "(Wise) The World Islamic Scie..",
                      child: Column(
                        children: [
                          Text("(Wise) The World Islamic Scie.. ", ).tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "University of Jordan",
                      child: Column(
                        children: [
                          Text("University of Jordan").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Yarmouk University",
                      child: Column(
                        children: [
                          Text("Yarmouk University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Jordan University of Scie..",
                      child: Column(
                        children: [
                          Text("Jordan University of Scie..", ).tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Al-Balqa' Applied University",
                      child: Column(
                        children: [
                          Text("Al-Balqa' Applied University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Hashemite University",
                      child: Column(
                        children: [
                          Text("Hashemite University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Mutah University",
                      child: Column(
                        children: [
                          Text("Mutah University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "German Jordanian University",
                      child: Column(
                        children: [
                          Text("German Jordanian University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Princess Sumaya University",
                      child: Column(
                        children: [
                          Text("Princess Sumaya University" , ).tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Al-Hussein Bin Talal University",
                      child: Column(
                        children: [
                          Text("Al-Hussein Bin Talal University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Tafila Technical University",
                      child: Column(
                        children: [
                          Text("Tafila Technical University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Al-Ahliyya Amman University",
                      child: Column(
                        children: [
                          Text("Al-Ahliyya Amman University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Applied Science Private University",
                      child: Column(
                        children: [
                          Text("Applied Science Private University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Middle East University",
                      child: Column(
                        children: [
                          Text("Middle East University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Petra University",
                      child: Column(
                        children: [
                          Text("Petra University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Philadelphia University",
                      child: Column(
                        children: [
                          Text("Philadelphia University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Zarqa University",
                      child: Column(
                        children: [
                          Text("Zarqa University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Amman Arab University",
                      child: Column(
                        children: [
                          Text("Amman Arab University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Irbid National University",
                      child: Column(
                        children: [
                          Text("Irbid National University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Jadara University",
                      child: Column(
                        children: [
                          Text("Jadara University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Ajloun National University",
                      child: Column(
                        children: [
                          Text("Ajloun National University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "American University of Madaba",
                      child: Column(
                        children: [
                          Text("American University of Madaba").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Al-Isra University",
                      child: Column(
                        children: [
                          Text("Al-Isra University").tr(),
                          SizedBox(height: 10),
                          Divider(height: 5),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "Jordan Academy of Music",
                      child: Column(
                        children: [
                          Text("Jordan Academy of Music").tr(),
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
                          selectedUniversity ?? "Select University".tr(),
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
      value: "Ajloun",
      child: Column(
        children: [
          Text("Ajloun").tr(),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
    PopupMenuItem(
      value: "Amman",
      child: Column(
        children: [
          Text("Amman").tr(),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
    PopupMenuItem(
      value: "Aqaba",
      child: Column(
        children: [
          Text("Aqaba").tr(),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
    PopupMenuItem(
      value: "Balqa",
      child: Column(
        children: [
          Text("Balqa").tr(),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
    PopupMenuItem(
      value: "Irbid",
      child: Column(
        children: [
          Text("Irbid").tr(),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
    PopupMenuItem(
      value: "Jerash",
      child: Column(
        children: [
          Text("Jerash").tr(),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
    PopupMenuItem(
      value: "Karak",
      child: Column(
        children: [
          Text("Karak").tr(),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
    PopupMenuItem(
      value: "Ma'an",
      child: Column(
        children: [
          Text("Ma'an").tr(),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
    PopupMenuItem(
      value: "Madaba",
      child: Column(
        children: [
          Text("Madaba").tr(),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
    PopupMenuItem(
      value: "Mafraq",
      child: Column(
        children: [
          Text("Mafraq").tr(),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
    PopupMenuItem(
      value: "Tafilah",
      child: Column(
        children: [
          Text("Tafilah").tr(),
          SizedBox(height: 10),
          Divider(height: 5),
        ],
      ),
    ),
    PopupMenuItem(
      value: "Zarqa",
      child: Column(
        children: [
          Text("Zarqa").tr(),
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
                          selectedCity ?? "Select City".tr(),
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

                MyButton(                  
                  buttonText: "Register".tr(),
                  onTap: registerUser,
                ),

                const SizedBox(
                  height: 7,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?".tr(),
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.registerPageTap,
                      child: Text(
                        " Login Here".tr(),
                        style: GoogleFonts.roboto(
                            fontSize: 14, fontWeight: FontWeight.w600),
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