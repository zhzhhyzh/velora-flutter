import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../Services/email_sender.dart';
import '../Services/Notification/notification_handler.dart';
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

  Widget _textTitles({required String label}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  Widget _textFormField({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Value is missing';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: const TextStyle(color: Colors.white),
          maxLines: valueKey == 'JobDescription' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFFb9b9b9)),
            filled: true,
            fillColor: Colors.black54,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate() || _resumeBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields and attach a PDF resume.'),
        ),
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
      final emailSender = EmailSender();
      final notificationHandler = NotificationHandler();

      final recruiterEmail = jobData['email'];

      try {
        await emailSender.sendEmail(
          toEmail: recruiterEmail,
          toName: 'Recruiter',
          subject: 'New Job Application - ${jobData['jobTitle']}',
          htmlContent: '''
<p>Dear Recruiter,</p>
<p>New application for the position of ${jobData['jobTitle']} at ${jobData['comName']}.</p>
<p><strong>Name:</strong> ${_nameController.text}<br>
<strong>Phone:</strong> ${_phoneController.text}<br>
<strong>Email:</strong> ${_emailController.text}<br>
<strong>Portfolio:</strong> ${_portfolioController.text}<br>
<strong>Message:</strong> ${_messageController.text}</p>
<p>Regards,<br>${_nameController.text}</p>
''',
          attachmentName: _resumeFile!.name,
          attachmentBase64: fileBase64,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not send email: $e')));
      }



      final notificationMessage = '''
${_nameController.text} applied for "${jobData['jobTitle']}" at ${jobData['comName']}.
Phone: ${_phoneController.text}
Email: ${_emailController.text}
''';

      try {
        await notificationHandler.sendNotification(
          theEmail: recruiterEmail,
          title: 'New Job Application',
          message: notificationMessage,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send notifications: $e')),
        );
      }


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildField(String label,
      TextEditingController controller, {
        bool required = true,
        TextInputType? keyboardType,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            validator:
            required
                ? (value) =>
            value == null || value.isEmpty ? 'Required' : null
                : null,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
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
                      Text(
                        jobData['jobTitle'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          Text(jobData['jobLocation'] ?? 'Remote'),
                        ],
                      ),
                      Text('JOB TYPE: ${jobData['jobType']}'),
                      Text(
                        'DATE POSTED: ${_formatTimestamp(
                            jobData['createdAt'])}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textTitles(label: 'Name'),
                  _textFormField(valueKey: "name",
                      controller: _nameController,
                      enabled: true,
                      fct: () {},
                      maxLength: 100,
                      hint: "Enter Name"),
                  _textTitles(label: 'Phone No.'),
                  _textFormField(valueKey: "hpno",
                      controller: _phoneController,
                      enabled: true,
                      fct: () {},
                      maxLength: 20,
                      hint: "Enter Phone No."),

                  _textTitles(label: 'Email'),
                  _textFormField(valueKey: "email",
                      controller: _emailController,
                      enabled: true,
                      fct: () {},
                      maxLength: 100,
                      hint: "Enter Email"),
                  _textTitles(label: 'Portfolio Link'),
                  _textFormField(valueKey: "link",
                      controller: _portfolioController,
                      enabled: true,
                      fct: () {},
                      maxLength: 100,
                      hint: "Enter Portfolio Link"),


                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Upload Resume (PDF)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton(
                    onPressed: _pickResume,
                    child: Text(
                      _resumeFile != null
                          ? 'Resume selected'
                          : 'Choose PDF Resume',
                    ),
                  ),
                  if (_resumeFile != null)
                    Text(
                      _resumeFile!.name,
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  const SizedBox(height: 16),
                  _textTitles(label: 'Message'),
                  _textFormField(valueKey: "opmsg",
                      controller: _messageController,
                      enabled: true,
                      fct: () {},
                      maxLength: 1000,
                      hint: "Enter Message"),


                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                if (_formKey.currentState!.validate()) {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text("Confirm Submission"),
                          content: const Text(
                              "Are you sure you want to submit your application?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF689f77),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                                _submitApplication(); // Proceed with submission
                              },
                              child: const Text("Confirm",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF689f77),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child:
              _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'SUBMIT',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
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
