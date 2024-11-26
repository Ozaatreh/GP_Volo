import 'package:flutter/material.dart';
import 'dart:convert'; // For encoding JSON
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:url_launcher/url_launcher.dart'; // For launching the URL


void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ContactUsPage(),
    );
  }
}


class ContactUsPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();


  // Function to send email using EmailJS
  Future<void> sendEmail({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    const serviceId = "service_cgn74sv";
    const templateId = "template_7zudo4f";
    const userId = "SsMk8ta65lDlhUvzQ";


    try {
      final response = await http.post(
        Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'name': name,
            'email': email,
            'phone': phone,
            'message': message,
          },
        }),
      );


      if (response.statusCode == 200) {
        _showDialog(
          title: "Success",
          message: "Your report has been sent successfully!",
          context: _formKey.currentContext!,
        );
      } else {
        _showDialog(
          title: "Error",
          message: "Failed to send your report. Please try again.",
          context: _formKey.currentContext!,
        );
      }
    } catch (error) {
      _showDialog(
        title: "Error",
        message:
            "An error occurred. Please check your connection and try again.",
        context: _formKey.currentContext!,
      );
    }
  }


  // Function to show dialogs
  void _showDialog({
    required String title,
    required String message,
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us & Report'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get in Touch',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ContactInfoRow(
                  icon: Icons.location_on, text: 'Amman . Tabarbour'),
              ContactInfoRow(icon: Icons.email, text: 'appvolunter@gmail.com'),
              ContactInfoRow(icon: Icons.phone, text: '0785434449'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialIcon(
                    icon: Icons.facebook,
                    onPressed: () {
                      _launchFacebook();
                    },
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Report',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: 'Name',
                      controller: _nameController,
                    ),
                    CustomTextField(
                      labelText: 'Email',
                      controller: _emailController,
                    ),
                    CustomTextField(
                      labelText: 'Phone',
                      controller: _phoneController,
                    ),
                    CustomTextField(
                      labelText: 'Message',
                      controller: _messageController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          sendEmail(
                            name: _nameController.text,
                            email: _emailController.text,
                            phone: _phoneController.text,
                            message: _messageController.text,
                          );
                        }
                      },
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


  // Function to launch Facebook page
  void _launchFacebook() async {
    const url =
        'https://www.facebook.com/profile.php?id=100024702259144'; // Replace with your Facebook page URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}


class ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;


  const ContactInfoRow({required this.icon, required this.text});


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}


class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final int maxLines;


  const CustomTextField({
    required this.labelText,
    this.controller,
    this.maxLines = 1,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }
}


class SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;


  const SocialIcon({required this.icon, required this.onPressed});


  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.teal),
      onPressed: onPressed, // Use the onPressed function
    );
  }
}



