
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Volunteer Rating',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: PostSelectionPage(),
//     );
//   }
// }


class PostSelectionPage extends StatefulWidget {
  @override
  State<PostSelectionPage> createState() => _PostSelectionPageState();
}

class _PostSelectionPageState extends State<PostSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Post'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Posts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }


          final posts = snapshot.data!.docs;


          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                title: Text(post['PostMessage']),
                // subtitle: Text(post['description']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VolunteerRatingPage(postId: post.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class VolunteerRatingPage extends StatefulWidget {
  final String postId;


  VolunteerRatingPage({required this.postId});


  @override
  _VolunteerRatingPageState createState() => _VolunteerRatingPageState();
}


class _VolunteerRatingPageState extends State<VolunteerRatingPage> {
  final Map<String, double> _ratings = {};
  final Map<String, String> _comments = {};


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Volunteers'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Volunteers')
            .where('postId', isEqualTo: widget.postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }


          final volunteers = snapshot.data!.docs;


          return ListView.builder(
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              final volunteer = volunteers[index];
              final volunteerName = volunteer['name'];


              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        volunteerName,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: List.generate(5, (i) {
                          return IconButton(
                            icon: Icon(
                              i < (_ratings[volunteer.id] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              setState(() {
                                _ratings[volunteer.id] = i + 1.0;
                              });
                            },
                          );
                        }),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Leave a comment...',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _comments[volunteer.id] = value;
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitRatings,
        child: Icon(Icons.send),
      ),
    );
  }


  void _submitRatings() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;


    try {
      for (var entry in _ratings.entries) {
        String volunteerId = entry.key;
        double rating = entry.value;
        String comment = _comments[volunteerId] ?? '';


        await firestore.collection('volunteerRatings').add({
          'volunteerId': volunteerId,
          'postId': widget.postId,
          'rating': rating,
          'comment': comment,
          'ratedBy': 'leader_id', // Replace with actual leader ID
          'timestamp': Timestamp.now(),
        });
      }
      _showMessage('Ratings submitted successfully!');
    } catch (e) {
      _showMessage('Error: $e');
    }
  }


  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}



