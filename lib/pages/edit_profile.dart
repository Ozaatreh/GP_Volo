import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final String userType;
  final Map<String, dynamic> userData;
  final String userId;

  const EditProfilePage({
    super.key,
    required this.userType,
    required this.userData,
    required this.userId,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _extraFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData['name'] ?? '';
    _phoneController.text = widget.userData['phone'] ?? '';
    _emailController.text = widget.userData['email'] ?? '';
    if (widget.userType == 'Ngo') {
      _extraFieldController.text = widget.userData['organizationName'] ?? '';
    } else if (widget.userType == 'University') {
      _extraFieldController.text = widget.userData['universityName'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    Map<String, dynamic> updatedData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
    };

    if (widget.userType == 'Ngo') {
      updatedData['organizationName'] = _extraFieldController.text.trim();
    } else if (widget.userType == 'University') {
      updatedData['universityName'] = _extraFieldController.text.trim();
    }

    try {
      await _firestore.collection('Users').doc(widget.userId).update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context, updatedData); // Return updated data to caller
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            if (widget.userType == 'Ngo' || widget.userType == 'University')
              TextField(
                controller: _extraFieldController,
                decoration: InputDecoration(
                  labelText: widget.userType == 'Ngo'
                      ? 'Organization Name'
                      : 'University Name',
                ),
              ),
          ],
        ),
      ),
    );
  }
}