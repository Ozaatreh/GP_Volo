import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String message;
  final String? imageUrl;
  final int currentCount;
  final int targetCount;
  final int supervisorCount;
  final int maxSupervisors;
  final VoidCallback onVolunteerTap;
  final VoidCallback? onSupervisorTap;
  final bool isVolunteer;
  final bool isSupervisor;

  const PostCard({
    required this.username,
    required this.message,
    this.imageUrl,
    required this.currentCount,
    required this.targetCount,
    required this.supervisorCount,
    required this.maxSupervisors,
    required this.onVolunteerTap,
    this.onSupervisorTap,
    required this.isVolunteer,
    required this.isSupervisor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(username),
            IconButton(
              icon: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.inversePrimary),
              onPressed: () {
                // Report problem navigation logic
                Navigator.pushNamed(context, 'Contact_us_page');
              },
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(message),
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Image.network(imageUrl!, width: 100, height: 100),
              ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: supervisorCount / maxSupervisors,
              minHeight: 6,
              color: Colors.orange,
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            Text('$supervisorCount / $maxSupervisors (Supervisors)'),
            if (onSupervisorTap != null)
              ElevatedButton(
                onPressed: onSupervisorTap,
                child: Text(
                  isSupervisor ? "Cancel as Supervisor" : "Apply as Supervisor",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            Divider(),
            LinearProgressIndicator(
              value: currentCount / targetCount,
              minHeight: 6,
              color: Theme.of(context).colorScheme.inversePrimary,
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onVolunteerTap,
                  child: Text(
                    isVolunteer ? "Cancel" : "Apply",
                    style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
                Text('$currentCount / $targetCount (Volunteers)'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
