import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Widgets/the_app_bar.dart';

class ApplyJobScreen extends StatefulWidget {
  final DocumentSnapshot job;

  const ApplyJobScreen({super.key, required this.job});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _messageController = TextEditingController();

  XFile? _resumeFile;
  Uint8List? _resumeBytes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _emailController.text = user?.email ?? '';
  }

  Future<void> _pickResume() async {
    try {
      final XTypeGroup typeGroup = XTypeGroup(
        label: 'PDF',
        extensions: ['pdf'],
      );
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _resumeFile = file;
          _resumeBytes = bytes;
        });
        print('Selected: ${file.name}');
      } else {
        print('No file selected');
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }


  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate() || _resumeBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and attach a PDF resume.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final jobData = widget.job.data() as Map<String, dynamic>;

      final fileBase64 = base64Encode(_resumeBytes!);

      await FirebaseFirestore.instance.collection('userjobs').add({
        'userId': user?.uid,
        'userEmail': _emailController.text,
        'userName': _nameController.text,
        'userPhone': _phoneController.text,
        'portfolio': _portfolioController.text,
        'message': _messageController.text,
        'resume': fileBase64,
        'jobId': jobData['jobId'],
        'jobTitle': jobData['jobTitle'],
        'jobCompany': jobData['comName'],
        'recruiterEmail': jobData['email'],
        'appliedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool required = true, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            validator: required
                ? (value) => value == null || value.isEmpty ? 'Required' : null
                : null,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              hintText: 'Enter your ${label.toLowerCase()}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobData = widget.job.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: TheAppBar(content: jobData['comName'] ?? 'Apply Job', style: 2),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                if (jobData['jobImage'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(jobData['jobImage']),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jobData['jobTitle'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          Text(jobData['jobLocation'] ?? 'Remote'),
                        ],
                      ),
                      Text('JOB TYPE: ${jobData['jobType']}'),
                      Text('DATE POSTED: ${_formatTimestamp(jobData['createdAt'])}'),
                    ],
                  ),
                )
              ],
            ),
            const Divider(height: 30, thickness: 1),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildField('Name', _nameController),
                  _buildField('Phone No.', _phoneController, keyboardType: TextInputType.phone),
                  _buildField('Email', _emailController, required: true, keyboardType: TextInputType.emailAddress),
                  _buildField('Portfolio Link', _portfolioController, required: false, keyboardType: TextInputType.url),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Upload Resume (PDF)', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton(
                    onPressed: _pickResume,
                    child: Text(
                      _resumeFile != null ? 'Resume selected' : 'Choose PDF Resume',
                    ),
                  ),
                  if (_resumeFile != null)
                    Text(
                      _resumeFile!.name,
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  const SizedBox(height: 16),
                  _buildField('Optional Message', _messageController, required: false),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF689f77),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SUBMIT', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat.yMMMd().format(timestamp.toDate());
  }
}
