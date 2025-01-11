import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AdminDrawer extends StatelessWidget {
  AdminDrawer({super.key});

  String? currentUserType; // Store the logged-in user's type

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // Drawer header
                // Drawer header
                  DrawerHeader(
                    child: Image.asset('assets/volo_icon1.png', width: 130, height: 130)
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text(
                      "Home",
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, 'Users_Toggle_page');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text(
                      "Settings",
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushNamed(context, 'setting_page');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.star_rate_sharp,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text(
                      "Rating",
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushNamed(context, 'rating');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text(
                      "Add Achievement",
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushNamed(context, 'reward_creation');
                    },
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 25.0),
                //   child: ListTile(
                //     leading: Icon(
                //       Icons.group,
                //       color: Theme.of(context).colorScheme.inversePrimary,
                //     ),
                //     title: Text(
                //       "About us",
                //       style: GoogleFonts.roboto(
                //         color: Theme.of(context).colorScheme.inversePrimary,
                //         textStyle: const TextStyle(
                //             fontSize: 18, fontWeight: FontWeight.w300),
                //       ),
                //     ),
                //     onTap: () {
                //       Navigator.pop(context); // Close the drawer
                //       Navigator.pushNamed(context, 'about_us_page');
                //     },
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.phone_rounded,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text(
                      "Contact us",
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushNamed(context, 'Contact_us_page');
                    },
                  ),
                ),
                // Conditional rendering of Userslog tile
                // if (currentUserType == 'admin') ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.people_outline,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      title: Text(
                        "Userslog",
                        style: GoogleFonts.roboto(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w300),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.pushNamed(context, 'users_log_page');
                      },
                    ),
                  ),
                ],
              // ],
            ),
            // Logout tile
            Padding(
              padding: const EdgeInsets.only(left: 25.0, bottom: 25),
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                title: Text(
                  "Logout",
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.pushNamedAndRemoveUntil(
                           context,
                           'login_register_page',
                           (route) => false, // Remove all previous routes
                         );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}