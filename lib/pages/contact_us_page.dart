import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:url_launcher/url_launcher.dart'; // For launching URLs




class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}


class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();


  Future<void> sendEmail() async {
    const serviceId = "service_uv9c4n6";
    const templateId = "template_m8c4b6d";
    const userId = "SsMk8ta65lDlhUvzQ";


    try {
      final response = await http.post(
        Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'name': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'message': _messageController.text,
          },
        }),
      );
            print("Response Status Code: ${response.statusCode}");
            print("Response Body: ${response.body}");


      if (response.statusCode == 200) {
        _showDialog("Success".tr(), "Your report has been sent successfully!".tr());
      } else {
        _showDialog("Error".tr(), "Failed to send your report. Please try again.".tr());
      }
       
    } 
    catch (error) {
             _showDialog("Error".tr(), "Network error: Please check your internet connection.".tr());
            print("Error: $error");
      }
  }


  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK".tr()),
          ),
        ],
      ),
    );
  }


  void _launchFacebook() async {
    const url = 'https://www.facebook.com/profile.php?id=100024702259144';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Contact Us & Report').tr(),
        backgroundColor: Theme.of(context).colorScheme.surface,

        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get in Touch'.tr(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w200),
              ).tr(),
              SizedBox(height: 8),
              ContactInfoRow(
                icon: Icons.location_on,
                text: 'Amman'.tr(),
              ),
              ContactInfoRow(
                icon: Icons.email,
                text: 'appvolunter@gmail.com',
              ),
              // Icon(Icons.facebook, color: const Color.fromARGB(255, 10, 106, 217),size: 20,),
              ContactInfoRow(
                icon: Icons.phone,
                text: '0785434449',
              ),
              // Padding(
                // padding: const EdgeInsets.only(right: 33),
                // child: IconButton(

                //  icon:
                  Icon(Icons.facebook, color: const Color.fromARGB(255, 10, 106, 217),size: 20,),
                //  onPressed: _launchFacebook,
                //              ),
              // ),

              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   // mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     SocialIcon(
              //       icon: Icons.facebook,
              //       onPressed: _launchFacebook,
              //     ),
              //   ],
              // ),
              SizedBox(height: 20),
              Text(
                'Report'.tr(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: 'Name'.tr(),
                      controller: _nameController,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText:  'Email'.tr(),
                        border: OutlineInputBorder(),
                      ),
                      
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email'.tr();
                        } else if (!value.endsWith('@gmail.com')) {
                          return 'Please enter a valid Gmail address'.tr();
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Phone'.tr(),
                      controller: _phoneController,
                    ),
                    CustomTextField(
                      labelText: 'Message'.tr(),
                      controller: _messageController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          sendEmail();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:Theme.of(context).colorScheme.primary,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text('Submit'.tr() , style: TextStyle(color:Theme.of(context).colorScheme.inversePrimary, ),),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        Icon(icon, color: const Color.fromARGB(255, 21, 21, 21), size: 18,),
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
            return '${'Please enter'.tr()} $labelText';
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
      icon: Icon(icon, color: const Color.fromARGB(255, 10, 106, 217),size: 20,),
      onPressed: onPressed,
    );
  }
}



