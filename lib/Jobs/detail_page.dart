import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'create_job.dart';

class JobDetailPage extends StatelessWidget {
  final DocumentSnapshot jobData;

  const JobDetailPage({Key? key, required this.jobData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && currentUser.email == jobData['email'];

    return Scaffold(
      appBar: AppBar(title: Text(jobData['jobTitle'] ?? 'Job Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company: ${jobData['comName'] ?? ''}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Description: ${jobData['jobDesc'] ?? ''}', style: TextStyle(fontSize: 16)),
            // Add more job details as needed
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isOwner) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateJob(jobData: jobData),
              ),
            );
          } else {
            // Implement your apply logic here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Applied to the job successfully!')),
            );
          }
        },
        label: Text(isOwner ? 'Edit Post' : 'Apply'),
        icon: Icon(isOwner ? Icons.edit : Icons.send),
      ),
    );
  }
}
