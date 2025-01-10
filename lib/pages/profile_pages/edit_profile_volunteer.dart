import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditVolunteerProfilePage extends StatefulWidget {
  final String userType;
  final Map<String, dynamic> userData;

  const EditVolunteerProfilePage({
    super.key,
    required this.userType,
    required this.userData,
  });

  @override
  State<EditVolunteerProfilePage> createState() => _EditVolunteerProfilePageState();
}

class _EditVolunteerProfilePageState extends State<EditVolunteerProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _bioController = TextEditingController();
  final List<String> universitiesInJordan = [
    'non student',
    'University of Jordan',
    'Yarmouk University',
    'Jordan University of Science and Technology',
    'Al-Balqa\' Applied University',
    'German Jordanian University',
    'Hashemite University',
    'Princess Sumaya University for Technology',
    'Philadelphia University',
    'Applied Science Private University',
    'Middle East University',
    'American University of Madaba',
    'Al al-Bayt University',
    'Mutah University',
    'Tafila Technical University',
    'Al-Hussein Bin Talal University',
    'Zarqa University',
    'Al-Zaytoonah University of Jordan',
    'Al-Ahliyya Amman University',
    'Amman Arab University',
    'Irbid National University',
    'Petra University',
    'Jerash University',
    'Jadara University',
    'World Islamic Sciences and Education University',
    'National University College of Technology',
    'Jordan Academy for Maritime Studies',
    'Jordan Media Institute',
    'Royal Academy of Culinary Arts'
  ];
  String? selectedUniversity;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.userData['bio'] ?? '';
    selectedUniversity = widget.userData['university'] ??
        (universitiesInJordan.isNotEmpty ? universitiesInJordan[0] : null);
  }

  Future<void> _saveProfileChanges() async {
    try {
      String userId = widget.userData['email'];
      Map<String, dynamic> updatedData = {
        'university': selectedUniversity,
        'bio': _bioController.text,
        'linkedin': widget.userData['linkedin'] ?? '',
        'facebook': widget.userData['facebook'] ?? '',
        'instagram': widget.userData['instagram'] ?? '',
      };

      await _firestore.collection('Users').doc(userId).update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context, updatedData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Volunteer Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfileChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: () {}, // Placeholder for updating profile picture
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: widget.userData['profilePicture'] != null
                      ? NetworkImage(widget.userData['profilePicture'])
                      : const AssetImage('assets/photo_2024-11-02_19-33-14.jpg')
                          as ImageProvider,
                  child: const Icon(Icons.camera_alt, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Uneditable Info
            Text(
              'Username: ${widget.userData['username'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Email: ${widget.userData['email'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // University Dropdown
            Text(
              'University:   ${widget.userData['university'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // DropdownButton<String>(
            //   isExpanded: true,
            //   value: selectedUniversity,
            //   items: universitiesInJordan.map((university) {
            //     return DropdownMenuItem(
            //       value: university,
            //       child: Text(university),
            //     );
            //   }).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       selectedUniversity = value;
            //     });
            //   },
            // ),
            const Divider(),

            // Social Media Links
            const Text(
              'Social Media Links',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSocialLinkField(Icons.link_sharp, 'LinkedIn', 'linkedin'),
            _buildSocialLinkField(Icons.facebook, 'Facebook', 'facebook'),
            _buildSocialLinkField(Icons.camera_alt, 'Instagram', 'instagram'),
           
            // Bio TextField
            const SizedBox(height: 16),
            const Text(
              'Bio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write something about yourself...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinkField(IconData icon, String label, String fieldKey) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            decoration: InputDecoration(hintText: label),
            onChanged: (val) {
              setState(() {
                widget.userData[fieldKey] = val;
              });
            },
          ),
        ),
      ],
    );
  }
}