import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

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
                DrawerHeader(
                  child: Image.asset('assets/volo_icon1.png',width: 130, height: 130,)
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
                    ).tr(),
                    onTap: () {
                      // Navigator.pop(context);
                      Navigator.pushNamed(context, 'Users_Toggle_page');
                    },
                  ),
                ),
        
                //profile tile
                // Padding(
                //   padding: const EdgeInsets.only(left: 25.0),
                //   child: ListTile(
                //     leading: Icon(
                //       Icons.person,
                //       color: Theme.of(context).colorScheme.inversePrimary,
                //     ),
                //     title: Text(
                //       "Profile",
                //       style: GoogleFonts.roboto(
                //         color: Theme.of(context).colorScheme.inversePrimary,
                //         textStyle: const TextStyle(
                //             fontSize: 18, fontWeight: FontWeight.w300),
                //       ),
                //     ),
                //     onTap: () {
                //       //pop out drawer
                //        Navigator.pop(context);
                //       // navigat ot user
                //       Navigator.pushNamed(context, 'profile_page');
                //     },
                //   ),
                // ),
        
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
                    ).tr(),
                    onTap: () {
                      //pop out drawer
                       Navigator.pop(context);
                      // navigat ot user
                      Navigator.pushNamed(context, 'setting_page');
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.contact_support_rounded,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text(
                      "FAQ",
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ),
                    onTap: () {
                      //pop out drawer
                       Navigator.pop(context);
                      // navigat ot user
                      Navigator.pushNamed(context, 'FAQ');
                    },
                  ),
                ),
        
                //users tile
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.group,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text(
                      "About us",
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ).tr(),
                    onTap: () {
                      //pop out drawer
                       Navigator.pop(context);
                      // navigat ot user
                      Navigator.pushNamed(context, 'about_us_page');
                    },
                  ),
                ),
        
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
                    ).tr(),
                    onTap: () {
                      //pop out drawer
                       Navigator.pop(context);
                      // navigat ot user
                      Navigator.pushNamed(context, 'Contact_us_page');
                    },
                  ),
                ),
                Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text(
        "History",
        style: GoogleFonts.roboto(
          color: Theme.of(context).colorScheme.inversePrimary,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
        ),
            ).tr(),
            onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.pushNamed(context, '/history');
            },
          ),
        ),
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
                    ).tr(),
                    onTap: () {
                      //pop out drawer
                       Navigator.pop(context);
                      // navigat ot user
                      Navigator.pushNamed(context, 'users_log_page');
                    },
                  ),
                ),
                
        
              ],
            ),
                //Logout tile
                Padding(
                  padding: const EdgeInsets.only(left: 25.0 , bottom: 25),
                  child: ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text(
                      "Logout".tr(),
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ).tr(),
                    onTap: () {
                        //pop out drawer
                       Navigator.pop(context);
                      // navigat ot loginreg
                      //  Navigator.pushNamed(context, 'login_register_page');
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