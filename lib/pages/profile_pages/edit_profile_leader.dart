import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditLeaderProfilePage extends StatefulWidget {
  final String userType;
  final Map<String, dynamic> userData;

  const EditLeaderProfilePage({
    super.key,
    required this.userType,
    required this.userData,
  });

  @override
  State<EditLeaderProfilePage> createState() => _EditLeaderProfilePageState();
}

class _EditLeaderProfilePageState extends State<EditLeaderProfilePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  String defaultUsersImage ='assets/prf_pic.jpg';

  final TextEditingController achievementController = TextEditingController();
  final TextEditingController certificationController =
      TextEditingController();
       final TextEditingController bioController = TextEditingController(); // New controller for bio
  List<String> skills = [];
  List<String> achievements = [];
  List<String> certifications = [];
  final List<String> availableSkills = [
    'Leadership',
    'Team Management',
    'Event Planning',
    'Fundraising',
    'Public Speaking'
  ];

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
  
  // Ensure the fields are correctly parsed if they're not already in the correct format.
  skills = widget.userData['skills'] is List
      ? List<String>.from(widget.userData['skills'])
      : (widget.userData['skills'] as String?)?.split(',').map((e) => e.trim()).toList() ?? [];
  
  achievements = widget.userData['achievements'] is List
      ? List<String>.from(widget.userData['achievements'])
      : [];
  
  certifications = widget.userData['certifications'] is List
      ? List<String>.from(widget.userData['certifications'])
      : [];
  bioController.text = widget.userData['bio'] ?? ''; // Pre-fill the bio if available
  selectedUniversity = widget.userData['university'] ??
      (universitiesInJordan.isNotEmpty ? universitiesInJordan[0] : null);
}


  Future<void> _saveProfileChanges() async {
    try {
      String userId = widget.userData['email'];
      Map<String, dynamic> updatedData = {
        'skills': skills,
        'achievements': achievements,
        'certifications': certifications,
        'university': selectedUniversity,
        'linkedin': widget.userData['linkedin'] ?? '',
        'facebook': widget.userData['facebook'] ?? '',
        'instagram': widget.userData['instagram'] ?? '',
        'bio': bioController.text, 
      };

      await firestore.collection('Users').doc(userId).update(updatedData);

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
        title: const Text('Edit Leader Profile'),
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
                      :  AssetImage(defaultUsersImage)
                          as ImageProvider,
                  child: const Icon(Icons.camera_alt, size: 30
                  ),
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

             Text(
              'University:   ${widget.userData['university'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

             const SizedBox(height: 16),
            // University Dropdown
            // const Text(
            //   'University',
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 8),
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
           const SizedBox(height: 8),
            // Skills (bubbles, max 3)
            const Text(
              'Skills (Choose up to 3)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: availableSkills.map((skill) {
                final isSelected = skills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (skills.length < 3) skills.add(skill);
                      } else {
                        skills.remove(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const Divider(),
             const SizedBox(height: 8),
            // Achievements / Certifications
            // const Text(
            //   'Achievements & Certifications',
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 8),
            // _buildListSection('Achievements', achievements, achievementController),
            // _buildListSection('Certifications', certifications, certificationController),
            // const Divider(),

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
              'About Me',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bioController,
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

  Widget _buildListSection(
      String title, List<String> items, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => ListTile(
              title: Text(item),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    items.remove(item);
                  });
                },
              ),
            )),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: 'Add $title...'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    items.add(controller.text);
                    controller.clear();
                  });
                }
              },
            ),
          ],
        ),
      ],
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