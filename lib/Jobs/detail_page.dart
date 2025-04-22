import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:velora2/Jobs/apply_job.dart';
import '../Jobs/create_job.dart';
import '../Widgets/the_app_bar.dart';

class JobDetailScreen extends StatelessWidget {
  final DocumentSnapshot job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final data = job.data() as Map<String, dynamic>;
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user?.email == data['email'];

    return Scaffold(
      appBar: TheAppBar(content: data['comName'] ?? 'Job Detail', style: 2),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child:
                      data['jobImage'] != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              base64Decode(data['jobImage']),
                              fit: BoxFit.cover,
                            ),
                          )
                          : const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['jobTitle'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 4),
                          Text(data['jobLocation'] ?? 'REMOTE'),
                          const SizedBox(width: 150),

                          IconButton(
                            icon: const Icon(Icons.view_in_ar),
                            onPressed: () {
                              // AR view or extra feature
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('JOB TYPE: ${data['jobType'] ?? ''}'),
                      Text(
                        'DATE POSTED: ${_formatTimestamp(data['createdAt'])}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Divider(thickness: 1),
            const Text(
              'Job Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _labeledText(
              label: 'Description:',
              content: data['jobDesc'] ?? '',
              labelColor: Colors.green,
              isMultiline: true,
            ),
            const SizedBox(height: 10),

            _labeledText(
              label: 'Minimum Academic:',
              content: data['minAca'] ?? '',
              labelColor: Colors.green,
            ),
            _labeledText(
              label: 'Minimum Working Experience:',
              content: '${data['minWork']}yrs',
              labelColor: Colors.green,
            ),
            _labeledText(
              label: 'Finding Applicant:',
              content: data['finApp'] ?? '',
              labelColor: Colors.green,
            ),
            _labeledText(
              label: 'Total Person Applied:',
              content: '${data['applicants']}+',
              labelColor: Colors.black87,
            ),
            _labeledText(
              label: 'Salary:',
              content: '\$${data['salary']}/month',
              labelColor: Colors.green,
              isBold: true,
            ),
          ],
        ),
      ),

      // 🚀 Bottom Action Buttons
      floatingActionButton:
          isOwner
              ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'edit',
                    backgroundColor: Color(0xff689f77),

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateJob(jobData: job),
                        ),
                      );
                    },
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    heroTag: 'delete',
                    backgroundColor: Colors.red,
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('jobs')
                          .doc(job.id)
                          .delete();
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.remove_circle, color: Colors.white),
                  ),
                ],
              )
              : FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (_)=>ApplyJobScreen(job: job)));
                },
                label: const Text(
                  "APPLY",
                  style: TextStyle(color: Colors.white),
                ),
                icon: const Icon(Icons.send, color: Colors.white),
                backgroundColor: const Color(0xFF689f77),
              ),
    );
  }

  static String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat.yMMMd().format(date);
  }

  Widget _labeledText({
    required String label,
    required String content,
    Color labelColor = Colors.black,
    bool isBold = false,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14),
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(fontWeight: FontWeight.bold, color: labelColor),
            ),
            TextSpan(
              text: content,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        maxLines: isMultiline ? null : 1,
        overflow: isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
      ),
    );
  }
}
