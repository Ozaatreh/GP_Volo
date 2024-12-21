import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
class RewardCreationPage extends StatefulWidget {
  const RewardCreationPage({super.key});
  @override
  State<RewardCreationPage> createState() => _RewardCreationPageState();
}
class _RewardCreationPageState extends State<RewardCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _redeemLinkController = TextEditingController();
  File? _imageFile; // Holds the image file for the selected image
  List<Map<String, dynamic>> achievements = [];
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  @override
  void initState() {
    super.initState();
    _fetchAchievements();
  }
  Future<void> _fetchAchievements() async {
    final snapshot = await FirebaseFirestore.instance.collection('Achievements').get();
    setState(() {
      achievements = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'description': doc['description'],
          'imageUrl': doc['imageUrl'],
          'cost': doc['cost'],
          'redeemLink': doc['redeemLink'],
        };
      }).toList();
    });
  }
  Future<void> _addAchievement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final name = _nameController.text;
    final description = _descriptionController.text;
    final cost = int.tryParse(_costController.text) ?? 0;
    final redeemLink = _redeemLinkController.text;
    // You will need to upload the image to Firebase Storage and get the URL.
    // Assuming you have that URL in the `_imageFile` variable, replace it with the image URL.
    final imageUrl = _imageFile != null ? await _uploadImageToStorage(_imageFile!) : '';
    await FirebaseFirestore.instance.collection('Achievements').add({
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'cost': cost,
      'redeemLink': redeemLink,
    });
    _fetchAchievements(); // Refresh the achievements list
    _clearForm(); // Clear the form after adding
  }
  Future<String> _uploadImageToStorage(File image) async {
    // Implement image upload to Firebase Storage here and return the image URL.
    // Use the Firebase Storage package (firebase_storage) for uploading the image
    // and retrieving the URL to store in Firestore.
    return 'image_url'; // Replace this with the actual image URL.
  }
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Update the image file with the picked image
      });
    }
  }
  Future<void> _deleteAchievement(String achievementId) async {
    await FirebaseFirestore.instance.collection('Achievements').doc(achievementId).delete();
    _fetchAchievements(); // Refresh the achievements list after deletion
  }
  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _costController.clear();
    _redeemLinkController.clear();
    setState(() {
      _imageFile = null;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reward Creation Management',
          style: GoogleFonts.roboto(
            color: Theme.of(context).colorScheme.inversePrimary,
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Rewards',
              style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Reward Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reward name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: _imageFile == null
                          ? Icon(Icons.image, size: 50, color: Colors.blue)
                          : Image.file(
                              _imageFile!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Cost (Points)'),
                    validator: (value) {
                      if (value == null || value.isEmpty || int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _redeemLinkController,
                    decoration: InputDecoration(labelText: 'Redeem Link or Code'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a redeem link or code';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addAchievement,
                    child: Text('Add Reward'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: achievements.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: achievements.length,
                      itemBuilder: (context, index) {
                        final achievement = achievements[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Image.network(
                                  achievement['imageUrl'],
                                  width: 100,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        achievement['name'],
                                        style: GoogleFonts.roboto(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(achievement['description']),
                                      SizedBox(height: 8),
                                      Text('Cost: ${achievement['cost']} points'),
                                      SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          _deleteAchievement(achievement['id']);
                                        },
                                        child: Text('Delete Reward'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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