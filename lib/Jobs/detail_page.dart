import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:velora2/Jobs/apply_job.dart';
import '../Jobs/create_job.dart';
import '../Services/ar_view_screen.dart';
import '../Services/global_methods.dart';
import '../Widgets/the_app_bar.dart';

class JobDetailScreen extends StatefulWidget {
  final DocumentSnapshot job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late Map<String, dynamic> data;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    data = widget.job.data() as Map<String, dynamic>;
  }

  Future<void> _checkPermissionsAndLaunchAR(BuildContext context) async {
    final imageBase64 = data['arImage'];
    if (imageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image available for overlay.")),
      );
      return;
    }

    final imageBytes = base64Decode(imageBase64);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PanoramaViewerScreen(imageBytes: imageBytes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = user?.email == data['email'];

    
    final DateTime now = DateTime.now();
    final DateTime? deadline = (data['deadlineTimestamp'] is Timestamp)
        ? (data['deadlineTimestamp'] as Timestamp).toDate()
        : (data['deadline'] is String ? DateTime.tryParse(data['deadline']) : null);

    final bool isExpired = deadline != null && now.isAfter(deadline);

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 18),
                                    const SizedBox(width: 4),
                                    Text(data['state'] ?? 'State'),
                                    Text(', '),
                                    Text(data['country'] ?? 'Country'),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 19.0),
                                  child: Text(data['jobLocation'] ?? 'REMOTE'),
                                ),
                              ],
                            ),
                          ),
                          (data['arImage'] != null && data['arImage'].toString().isNotEmpty)
                              ? IconButton(
                            icon: const Icon(Icons.view_in_ar),
                            onPressed: () => _checkPermissionsAndLaunchAR(context),
                          )
                              : const SizedBox.shrink()

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
              label: 'Salary:',
              content: '\$${data['salary']}/month',
              labelColor: Colors.green,
              isBold: true,
            ),
            _labeledText(
              label: 'Deadline:',
              content: GlobalMethod.formatDateWithSuperscript(
                (data['deadlineTimestamp'] is Timestamp)
                    ? (data['deadlineTimestamp'] as Timestamp).toDate()
                    : DateTime.tryParse(data['deadlineTimestamp'] ?? '') ??
                        DateTime.now(),
              ),

              labelColor: Colors.green,
              isBold: true,
            ),
          ],
        ),
      ),

      floatingActionButton:
          isOwner
              ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'edit',
                    backgroundColor: const Color(0xff689f77),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateJob(jobData: widget.job),
                        ),
                      );
                    },
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    heroTag: 'delete',
                    backgroundColor: Colors.red,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text("Confirm Deletion"),
                          content: const Text("Are you sure you want to delete this job post?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(ctx).pop(); // Close the dialog
                                await FirebaseFirestore.instance
                                    .collection('jobs')
                                    .doc(widget.job.id)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Deleted successfully!')),
                                );
                                Navigator.pop(context); // Return to previous screen
                              },
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },

                    child: const Icon(Icons.remove_circle, color: Colors.white),
                  ),
                ],
              )
              : (!isExpired
                  ? FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApplyJobScreen(job: widget.job),
                        ),
                      );
                    },
                    label: const Text(
                      "APPLY",
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: const Icon(Icons.send, color: Colors.white),
                    backgroundColor: const Color(0xFF689f77),
                  )
                  : null),
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
