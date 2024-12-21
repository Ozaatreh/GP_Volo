import 'package:flutter/material.dart';

class StatusUtils {
  static Color getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return const Color(0xFF4CAF50); // Green 
      case 'in_progress':
        return const Color(0xFFFF9800); // Orange
      case 'completed':
        return const Color.fromARGB(255, 255, 0, 0); // Blue
      default:
        return Colors.grey[400]!; // Light Grey
    }
  }

  static void showStatusDialog(BuildContext context, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Event Status"),
          content: Text("The current status of this event is: $status"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

class StatusDot extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const StatusDot({required this.onTap, required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 12.0,
        height: 12.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}