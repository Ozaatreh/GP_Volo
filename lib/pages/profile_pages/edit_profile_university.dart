import 'package:flutter/material.dart';

class EditUniversityProfilePage extends StatefulWidget {
  final String userType;
  final Map<String, dynamic> userData;

  const EditUniversityProfilePage({
    super.key,
    required this.userType,
    required this.userData,
  });

  @override
  EditUniversityProfilePageState createState() =>
      EditUniversityProfilePageState();
}

class EditUniversityProfilePageState extends State<EditUniversityProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;

  List<String> departments = [];
  List<String> events = [];
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.userData['universityName']);
    _aboutController = TextEditingController(text: widget.userData['about']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _websiteController =
        TextEditingController(text: widget.userData['website']);
    departments = List<String>.from(widget.userData['departments'] ?? []);
    events = List<String>.from(widget.userData['events'] ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _departmentController.dispose();
    _eventController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'universityName': _nameController.text,
        'about': _aboutController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'website': _websiteController.text,
        'departments': departments,
        'events': events,
      };
      Navigator.pop(context, updatedData);
    }
  }

  void _addDepartment() {
    if (_departmentController.text.isNotEmpty) {
      setState(() {
        departments.add(_departmentController.text);
        _departmentController.clear();
      });
    }
  }

  void _addEvent() {
    if (_eventController.text.isNotEmpty) {
      setState(() {
        events.add(_eventController.text);
        _eventController.clear();
      });
    }
  }

  void _removeDepartment(int index) {
    setState(() {
      departments.removeAt(index);
    });
  }

  void _removeEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // University Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'University Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the university name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // About Section
              TextFormField(
                controller: _aboutController,
                decoration: const InputDecoration(
                  labelText: 'About',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Website
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // Departments
              const Text(
                'Departments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...departments.asMap().entries.map((entry) {
                final index = entry.key;
                final department = entry.value;
                return ListTile(
                  title: Text(department),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeDepartment(index),
                  ),
                );
              }),
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Add a Department',
                  suffixIcon: Icon(Icons.add),
                ),
                onSubmitted: (_) => _addDepartment(),
              ),
              const SizedBox(height: 16),

              // Events
              const Text(
                'Events',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...events.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                return ListTile(
                  title: Text(event),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeEvent(index),
                  ),
                );
              }),
              TextField(
                controller: _eventController,
                decoration: const InputDecoration(
                  labelText: 'Add an Event',
                  suffixIcon: Icon(Icons.add),
                ),
                onSubmitted: (_) => _addEvent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}