/*

 This database store posts that user published in the app

 
 */

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';



class FirestoreDatabase {

// current user logged
 User ? user = FirebaseAuth.instance.currentUser;

// post collection from the firebase
final CollectionReference post = FirebaseFirestore.instance.collection('Posts');

final CollectionReference userinfo = FirebaseFirestore.instance.collection('Users');

final CollectionReference notifications = FirebaseFirestore.instance.collection('Notifications');
// image
final FirebaseStorage storage = FirebaseStorage.instance;

// add post method
Future addPost(String messages ,
 {String? imageUrl,
  int leaderMaxCount = 7,
  int targetCount = 30 ,
  DateTime? eventDate,  } ) async{
   // Retrieve username from user's profile document
      String? username = await getUsername(user!.email!);
      String? userType = await getUserType(user!.email!);
  return post.add(
    {  'Username': username ?? "Asalyy",
       'UserEmail' : user!.email ,
       'UserType' : userType ?? "unknown" ,
       'PostMessage' : messages ,
       'ImageUrl': imageUrl, // Add image URL here
       'TimeStamp' : Timestamp.now(),
       'EventDate': eventDate != null ? Timestamp.fromDate(eventDate) : null,
       'CurrentCount': 0, // Initialize current count as 0
       'TargetCount': targetCount, // Set target count, default 100
       'AppliedUsers': [], // Initialize an empty list to track applied users
       'Leaders': [], // Initialize an empty list for leaders
       'LeaderCount': 0, // Initialize leader count to 0
       'LeaderMaxCount': leaderMaxCount,
       'status': 'upcoming',
    }
  );

}

void updateEventStatus() async {
  final now = DateTime.now();
  final posts = await FirebaseFirestore.instance.collection('Posts').get();

  for (var doc in posts.docs) {
    DateTime eventDate = (doc['EventDate'] as Timestamp).toDate();
    String status = doc['status'] ?? "upcoming";

    if (eventDate.isBefore(now) && status != "completed") {
      await doc.reference.update({'status': 'completed'});
    } else if (eventDate.isAtSameMomentAs(now) && status != "in_progress") {
      await doc.reference.update({'status': 'in_progress'});
    }
  }
}

  // Method to send notifications
  Future<void> sendNotification({
    required String message,
    required String postId,
    required String userEmail,
    required String notificationType, // "apply", "cancel", "apply_leader", etc.
  }) async {
    await notifications.add({
      'Message': message,
      'PostId': postId,
      'UserEmail': userEmail,
      'NotificationType': notificationType,
      'TimeStamp': Timestamp.now(),
      'Seen': false, // This could be used to track if the user has seen the notification
    });

    // You can also implement push notifications using Firebase Cloud Messaging if needed
  }
Stream<QuerySnapshot> getNgoUserPostsStream(String userEmail) {
  return FirebaseFirestore.instance
      .collection('Posts')
      .where('UserEmail', isEqualTo: userEmail) // Filter by user email
      .where('status', isEqualTo: 'upcoming') //Fetch only upcoming events
      .snapshots();
}

Future<String?> getUsername(String userId) async {
  final userDoc = await userinfo.doc(userId).get();
  final data = userDoc.data() as Map<String, dynamic>?; // Cast to Map
  return data?['username'];
}

Future<String?> getUserType(String userType) async {
  final userDoc2 = await userinfo.doc(userType).get();
  final data2 = userDoc2.data() as Map<String, dynamic>?; // Cast to Map
  return data2?['userType'];
}

Future<void> applyToEvent(String postId ,DateTime eventDate) async {
  final postRef = post.doc(postId);
  final postSnapshot = await postRef.get();
  
  if (postSnapshot.exists) {
    final data = postSnapshot.data() as Map<String, dynamic>;
    List<dynamic> appliedUsers = data['AppliedUsers'] ?? [];
    int currentCount = data['CurrentCount'] ?? 0;
    int maxCount = data['TargetCount'] ?? 0;
    if (!appliedUsers.contains(user!.email) && currentCount < maxCount) {
      appliedUsers.add(user!.email);
      await postRef.update({
        'AppliedUsers': appliedUsers,
        'CurrentCount': currentCount + 1,
      });
      // Send notification to user
        await sendNotification(
          message: '${user!.email} applied to your event.',
          postId: postId,
          userEmail: data['UserEmail'],
          notificationType: 'apply',
        );
      //  CustomNotificationState().scheduleEventNotifications(eventDate);

      print("Volunteer successfully applied and notifications scheduled.");
    }
  }
}

Future<void> cancelApplication(String postId) async {
  final postRef = post.doc(postId);
  final postSnapshot = await postRef.get();
  
  if (postSnapshot.exists) {
    final data = postSnapshot.data() as Map<String, dynamic>;
    List<dynamic> appliedUsers = data['AppliedUsers'] ?? [];
    int currentCount = data['CurrentCount'] ?? 0;

    if (appliedUsers.contains(user!.email)) {
      appliedUsers.remove(user!.email);
      await postRef.update({
        'AppliedUsers': appliedUsers,
        'CurrentCount': currentCount - 1,
      });
       // Send notification to user
        await sendNotification(
          message: '${user!.email} canceled their application for your event.',
          postId: postId,
          userEmail: data['UserEmail'],
          notificationType: 'cancel',
        );
    }
  }
}

Future<void> updateEventCount(String postId, int newCount) async {
    try {
      await post.doc(postId).update({'CurrentCount': newCount});
    } catch (e) {
      // print("Error updating event count: $e");
    }
  }

// leader apply
Future<void> applyAsLeader(String postId, DateTime eventDate) async {
  // First, check if the user has already applied to another event on the same date
  bool alreadyApplied = await hasAppliedOnSameDate(eventDate);

  if (alreadyApplied) {
    // If the user has already applied on this date, show a message or handle as needed
    print("You have already applied to an event on this date.");
    return; // Prevent applying
  }

  // If no conflicts, proceed to apply as a leader
  final postRef = post.doc(postId);
  final postSnapshot = await postRef.get();

  if (postSnapshot.exists) {
    final data = postSnapshot.data() as Map<String, dynamic>;
    List<dynamic> leaders = data['Leaders'] ?? [];
    int leaderCount = data['LeaderCount'] ?? 0;
    int maxLeaders = 5; // Example max leaders

    if (!leaders.contains(user!.email) && leaderCount < maxLeaders) {
      leaders.add(user!.email);
      // Store the event date when the leader applies
      await postRef.update({
        'Leaders': leaders,
        'LeaderCount': leaderCount + 1,
        'LeaderEventDate': eventDate, // Store the event date
      });
      // Send notification to user
        await sendNotification(
          message: '${user!.email} applied as a leader for your event.',
          postId: postId,
          userEmail: data['UserEmail'],
          notificationType: 'apply_leader',
        );
        // Schedule notifications for the leader
      // CustomNotificationState().scheduleEventNotifications(eventDate);

      print("Leader successfully applied and notifications scheduled.");
    }
  }
}

 
// leader cancel apply
Future<void> cancelLeaderApplication(String postId) async {
  final postRef = post.doc(postId);
  final postSnapshot = await postRef.get();

  if (postSnapshot.exists) {
    final data = postSnapshot.data() as Map<String, dynamic>;
    List<dynamic> leaders = data['Leaders'] ?? [];
    int leaderCount = data['LeaderCount'] ?? 0;

    if (leaders.contains(user!.email)) {
      leaders.remove(user!.email);
      await postRef.update({
        'Leaders': leaders,
        'LeaderCount': leaderCount - 1,
      });
      // Send notification to user
        await sendNotification(
          message: '${user!.email} Leader has canceled their application for your event.',
          postId: postId,
          userEmail: data['UserEmail'],
          notificationType: 'cancel',
        );
    }
  }
}

// Method to retrieve notifications for current user
  Stream<QuerySnapshot> getUserNotifications(String userEmail) {
    return notifications
        .where('UserEmail', isEqualTo: userEmail)
        .orderBy('TimeStamp', descending: true)
        .snapshots();
  }

Future<void> updateLeaderCount(String postId, int newCount) async {
  try {
    await post.doc(postId).update({'LeaderCount': newCount});
  } catch (e) {
    // print("Error updating leader count: $e");
  }
}
 
 Future<bool> hasAppliedOnSameDate(DateTime eventDate) async {
  // Get all posts where the user has applied
  final userPostsSnapshot = await post
      .where('AppliedUsers', arrayContains: user!.email)
      .get();

  // Check each post's event date
  for (var doc in userPostsSnapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime existingEventDate = (data['EventDate'] as Timestamp).toDate();

    // If any event has the same date, return true
    if (existingEventDate.year == eventDate.year &&
        existingEventDate.month == eventDate.month &&
        existingEventDate.day == eventDate.day) {
      return true; // Already applied on this date
    }
  }

  return false; // No application on this date
}

// Method to upload image to Firebase Storage
Future<String?> uploadImage(File imageFile) async {
  try {
    final ref = storage.ref().child('post_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(imageFile);
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    return null;
  }
}

// Method to delete a post by document ID
Future<void> deletePost(String postId) async {
  try {
    await post.doc(postId).delete();
  } catch (e) {
    // print("Error deleting post: $e");
  }
}

Stream<QuerySnapshot> getPostStream(String currentUserEmail) {
  return FirebaseFirestore.instance
      .collection('Posts')
      .where('UserEmail', isNotEqualTo: currentUserEmail) // Avoid showing posts of the current user
      .snapshots();
}

// read post from database
Stream <QuerySnapshot> getAllPostStream(){
  final postsStream = FirebaseFirestore.instance.
  collection('Posts').
  orderBy('TimeStamp',descending: true).
  snapshots();
  return postsStream ;
}
}
