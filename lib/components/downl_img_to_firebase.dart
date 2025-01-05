import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UploadImagePage extends StatefulWidget {
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Method to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Method to upload image to Firebase Storage
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      final ref = _storage.ref().child('uploaded_images/${DateTime.now().millisecondsSinceEpoch}.jpg'.tr());
      await ref.putFile(_selectedImage!);
      final imageUrl = await ref.getDownloadURL();
      print('Image uploaded successfully: $imageUrl'.tr());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully! URL: $imageUrl".tr())),
      );
    } catch (e) {
      print('Error uploading image: $e'.tr());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e".tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image').tr(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, width: 200, height: 200, fit: BoxFit.cover)
                : Text("No image selected").tr(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Select Image").tr(),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text("Upload Image").tr(),
            ),
          ],
        ),
      ),
    );
  }
}
