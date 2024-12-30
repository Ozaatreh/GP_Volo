
import 'package:flutter/material.dart';
import 'dart:math';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat(reverse: true);

    _animations = List.generate(25, (index) {
      final start = _random.nextDouble();
      final end = (start + 0.1).clamp(0.0, 1.0); // Ensure end does not exceed 1.0
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.fastOutSlowIn),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: PopInPopOutPainter(_animations),
                child: Container(),
              );
            },
          ),
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              SizedBox(height: 70),

              _buildSettingsTile(
                context,
                icon: Icons.person,
                title: 'Profile Settings',
                onTap: () {},
              ),
              SizedBox(height: 16),
              _buildSettingsTile(
                context,
                icon: Icons.help,
                title: 'Support and Feedback',
                onTap: () {},
              ),
              SizedBox(height: 16),
              _buildSettingsTile(
                context,
                icon: Icons.info,
                title: 'Legal Information',
                onTap: () {},
              ),
              SizedBox(height: 16),
              _buildSettingsTile(
                context,
                icon: Icons.language,
                title: 'Language',
                onTap: () {},
              ),
              // SizedBox(height: 16),
              // _buildSettingsTile(
              //   context,
              //   icon: Icons.notifications,
              //   title: 'Notifications',
              //   onTap: () {},
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.inversePrimary),
          title: Text(title),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: onTap,
        ),
      ),
    );
  }
}

class PopInPopOutPainter extends CustomPainter {
  final List<Animation<double>> animations;
  final Random random = Random(30);

  PopInPopOutPainter(this.animations);

  @override
  void paint(Canvas canvas, Size size) {
    final icon = Icons.settings;
    final paint = Paint();
    final iconSize = 24.0;

    for (int i = 0; i < animations.length; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final scale = animations[i].value;
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: iconSize * scale,
            fontFamily: icon.fontFamily,
            color: const Color.fromARGB(255, 42, 38, 38).withOpacity(0.5),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


// class FallingIconsPainter extends CustomPainter {
//   final double progress;
//   final Random random = Random();
  
//   FallingIconsPainter(this.progress);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final icon = Icons.settings;
//     final paint = Paint();
//     final iconSize = 24.0;

//     // A scale factor to slow down the falling speed
//     double fallSpeed = 0.05; // 5% of normal speed

//     for (int i = 0; i < 6; i++) {
//       final x = random.nextDouble() * size.width;

//       // Slower falling by reducing how much progress moves the icons down
//       final y = (random.nextDouble() * size.height + (progress * fallSpeed) * size.height) % size.height;

//       final textPainter = TextPainter(
//         text: TextSpan(
//           text: String.fromCharCode(icon.codePoint),
//           style: TextStyle(
//             fontSize: iconSize,
//             fontFamily: icon.fontFamily,
//             color: Colors.grey.withOpacity(0.5),
//           ),
//         ),
//         textDirection: TextDirection.ltr,
//       );
//       textPainter.layout();
//       textPainter.paint(canvas, Offset(x , y));
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }














// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: SettingsPage(),
//     );
//   }
// }

// class SettingsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Settings'),
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(16.0),
//         children: [
//           _buildSettingsTile(
//             context,
//             icon: Icons.person,
//             title: 'Profile Settings',
//             onTap: () {},
//           ),
//           SizedBox(height: 16),
//           _buildSettingsTile(
//             context,
//             icon: Icons.lock,
//             title: 'Account Settings',
//             onTap: () {},
//           ),
//           SizedBox(height: 16),
//           _buildSettingsTile(
//             context,
//             icon: Icons.palette,
//             title: 'App Preferences',
//             onTap: () {},
//           ),
//           SizedBox(height: 16),
//           _buildSettingsTile(
//             context,
//             icon: Icons.security,
//             title: 'Security Settings',
//             onTap: () {},
//           ),
//           SizedBox(height: 16),
//           _buildSettingsTile(
//             context,
//             icon: Icons.storage,
//             title: 'Data Management',
//             onTap: () {},
//           ),
//           SizedBox(height: 16),
//           _buildSettingsTile(
//             context,
//             icon: Icons.help,
//             title: 'Support and Feedback',
//             onTap: () {},
//           ),
//           SizedBox(height: 16),
//           _buildSettingsTile(
//             context,
//             icon: Icons.info,
//             title: 'Legal Information',
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       elevation: 4,
//       child: ListTile(
//         leading: Icon(icon, color: Theme.of(context).primaryColor),
//         title: Text(title),
//         trailing: Icon(Icons.arrow_forward_ios),
//         onTap: onTap,
//       ),
//     );
//   }
// }





















// // import 'package:flutter/material.dart';
// // import 'package:flutter_neumorphic/flutter_neumorphic.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return NeumorphicApp(
// //       debugShowCheckedModeBanner: false,
// //       theme: NeumorphicThemeData(
// //         baseColor: Color(0xFFFFFFFF),
// //         lightSource: LightSource.topLeft,
// //         depth: 10,
// //       ),
// //       home: SettingsPage(),
// //     );
// //   }
// // }

// // class SettingsPage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: NeumorphicAppBar(
// //         title: Text('Settings'),
// //       ),
// //       body: ListView(
// //         padding: EdgeInsets.all(16.0),
// //         children: [
// //           Neumorphic(
// //             style: NeumorphicStyle(
// //               depth: -5,
// //               intensity: 0.8,
// //               boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
// //             ),
// //             child: ListTile(
// //               leading: Icon(Icons.person),
// //               title: Text('Profile Settings'),
// //               onTap: () {},
// //             ),
// //           ),
// //           SizedBox(height: 16),
// //           Neumorphic(
// //             style: NeumorphicStyle(
// //               depth: -5,
// //               intensity: 0.8,
// //               boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
// //             ),
// //             child: ListTile(
// //               leading: Icon(Icons.lock),
// //               title: Text('Account Settings'),
// //               onTap: () {},
// //             ),
// //           ),
// //           SizedBox(height: 16),
// //           Neumorphic(
// //             style: NeumorphicStyle(
// //               depth: -5,
// //               intensity: 0.8,
// //               boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
// //             ),
// //             child: ListTile(
// //               leading: Icon(Icons.palette),
// //               title: Text('App Preferences'),
// //               onTap: () {},
// //             ),
// //           ),
// //           SizedBox(height: 16),
// //           Neumorphic(
// //             style: NeumorphicStyle(
// //               depth: -5,
// //               intensity: 0.8,
// //               boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
// //             ),
// //             child: ListTile(
// //               leading: Icon(Icons.security),
// //               title: Text('Security Settings'),
// //               onTap: () {},
// //             ),
// //           ),
// //           SizedBox(height: 16),
// //           Neumorphic(
// //             style: NeumorphicStyle(
// //               depth: -5,
// //               intensity: 0.8,
// //               boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
// //             ),
// //             child: ListTile(
// //               leading: Icon(Icons.storage),
// //               title: Text('Data Management'),
// //               onTap: () {},
// //             ),
// //           ),
// //           SizedBox(height: 16),
// //           Neumorphic(
// //             style: NeumorphicStyle(
// //               depth: -5,
// //               intensity: 0.8,
// //               boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
// //             ),
// //             child: ListTile(
// //               leading: Icon(Icons.help),
// //               title: Text('Support and Feedback'),
// //               onTap: () {},
// //             ),
// //           ),
// //           SizedBox(height: 16),
// //           Neumorphic(
// //             style: NeumorphicStyle(
// //               depth: -5,
// //               intensity: 0.8,
// //               boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
// //             ),
// //             child: ListTile(
// //               leading: Icon(Icons.info),
// //               title: Text('Legal Information'),
// //               onTap: () {},
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SettingsPage(),
//     );
//   }
// }

// class SettingsPage extends StatefulWidget {
//   @override
//   _SettingsPageState createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   bool _isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Settings'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(16.0),
//         children: [
//           _buildSettingsTile(
//             context,
//             icon: Icons.person,
//             title: 'Profile Settings',
//             onTap: () {},
//           ),
//           SizedBox(height: 16),
//           _buildSettingsTile(
//             context,
//             icon: Icons.help,
//             title: 'Support and Feedback',
//             onTap: () {},
//           ),
//           SizedBox(height: 16),
//           _buildSettingsTile(
//             context,
//             icon: Icons.info,
//             title: 'Legal Information',
//             onTap: () {},
//           ),
//           SizedBox(height: 16),
//           _buildSettingsTile(
//             context,
//             icon: Icons.language,
//             title: 'Language',
//             onTap: () {},
//           ),
//           SizedBox(height: 16),
//           _buildSettingsTile(
//             context,
//             icon: Icons.notifications,
//             title: 'Notifications',
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       child: Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         elevation: 4,
//         child: ListTile(
//           leading: Icon(icon, color: Theme.of(context).primaryColor),
//           title: Text(title, ),
//           trailing: Icon(Icons.arrow_forward_ios, ),
//           onTap: onTap,
//         ),
//       ),
//     );
//   }

//   Widget _buildExpandableTile(BuildContext context, {required IconData icon, required String title, required List<Widget> children}) {
//     return AnimatedSwitcher(
//       duration: Duration(milliseconds: 300),
//       child: Column(
//         key: ValueKey<bool>(_isExpanded),
//         children: [
//           ListTile(
//             leading: Icon(icon, color: Theme.of(context).primaryColor),
//             title: Text(title, style: TextStyle()),
//             trailing: IconButton(
//               icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more,),
//               onPressed: () {
//                 setState(() {
//                   _isExpanded = !_isExpanded;
//                 });
//               },
//             ),
//           ),
//           if (_isExpanded)
//             ...children.map((child) => Padding(
//               padding: const EdgeInsets.only(left: 16.0, top: 8.0),
//               child: child,
//             )),
//         ],
//       ),
//     );
//   }
// }


