import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditNGOProfilePage extends StatefulWidget {
  final String userType;
  final Map<String, dynamic> userData;

  const EditNGOProfilePage({
    super.key,
    required this.userType,
    required this.userData,
  });

  @override
  _EditNGOProfilePageState createState() => _EditNGOProfilePageState();
}

class _EditNGOProfilePageState extends State<EditNGOProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _organizationNameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;

  List<String> _services = [];
  List<String> _projects = [];
  List<String> _testimonials = [];

  @override
  void initState() {
    super.initState();
    _organizationNameController =
        TextEditingController(text: widget.userData['organizationName']);
    _bioController = TextEditingController(text: widget.userData['bio']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _websiteController = TextEditingController(text: widget.userData['website']);
    _facebookController =
        TextEditingController(text: widget.userData['facebook']);
    _instagramController =
        TextEditingController(text: widget.userData['instagram']);

    _services = List<String>.from(widget.userData['services'] ?? []);
    _projects = List<String>.from(widget.userData['projects'] ?? []);
    _testimonials = List<String>.from(widget.userData['testimonials'] ?? []);
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore
            .collection('Users')
            .doc(widget.userData['email'])
            .update({
          'organizationName': _organizationNameController.text,
          'bio': _bioController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'website': _websiteController.text,
          'facebook': _facebookController.text,
          'instagram': _instagramController.text,
          'services': _services,
          'projects': _projects,
          'testimonials': _testimonials,
        });
        Navigator.pop(context, {
          'organizationName': _organizationNameController.text,
          'bio': _bioController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'website': _websiteController.text,
          'facebook': _facebookController.text,
          'instagram': _instagramController.text,
          'services': _services,
          'projects': _projects,
          'testimonials': _testimonials,
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    }
  }

  Widget _buildListEditor(String title, List<String> items, Function onAdd,
      Function(int) onRemove) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          return ListTile(
            title: Text(value),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onRemove(index),
            ),
          );
        }),
        TextButton.icon(
          onPressed: () async {
            final newValue = await _showInputDialog('Add $title');
            if (newValue != null) onAdd(newValue);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
        const Divider(),
      ],
    );
  }

  Future<String?> _showInputDialog(String title) async {
    String? inputValue;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            onChanged: (value) {
              inputValue = value;
            },
            decoration: const InputDecoration(hintText: 'Enter value'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, inputValue),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit NGO Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Organization Name
              TextFormField(
                controller: _organizationNameController,
                decoration: const InputDecoration(labelText: 'Organization Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Bio
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'About Us'),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const Divider(),

              // Contact Information
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(labelText: 'Website'),
              ),
              TextFormField(
                controller: _facebookController,
                decoration: const InputDecoration(labelText: 'Facebook'),
              ),
              TextFormField(
                controller: _instagramController,
                decoration: const InputDecoration(labelText: 'Instagram'),
              ),
              const Divider(),

              // Editable Sections
              _buildListEditor(
                'Services Offered',
                _services,
                (value) => setState(() => _services.add(value)),
                (index) => setState(() => _services.removeAt(index)),
              ),
              _buildListEditor(
                'Current Projects',
                _projects,
                (value) => setState(() => _projects.add(value)),
                (index) => setState(() => _projects.removeAt(index)),
              ),
              _buildListEditor(
                'Testimonials',
                _testimonials,
                (value) => setState(() => _testimonials.add(value)),
                (index) => setState(() => _testimonials.removeAt(index)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}