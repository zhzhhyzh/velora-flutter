import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widgets/the_app_bar.dart';

class UploadDesignPage extends StatefulWidget {
  final String contestId;

  const UploadDesignPage({super.key, required this.contestId});

  @override
  State<UploadDesignPage> createState() => _UploadDesignPageState();
}

class _UploadDesignPageState extends State<UploadDesignPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _conceptController = TextEditingController();
  List<XFile> _imageFiles = [];
  bool _isUploading = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _imageFiles = images;
      });
    }
  }

  Future<void> addUserToContestParticipants(String contestId, String userEmail) async {
    if (userEmail.isEmpty || contestId.isEmpty) {
      print('User email or Contest ID is empty, cannot add participant.');
      return;
    }
    try {
      final contestRef = FirebaseFirestore.instance.collection('contests').doc(contestId);
      await contestRef.update({
        'participants': FieldValue.arrayUnion([userEmail])
      });
      print('User $userEmail successfully added/ensured in participants list for contest $contestId');
    } catch (e) {
      print('Error adding user $userEmail to participants for contest $contestId: $e');
      // Consider how to handle this error more robustly if needed
    }
  }

  Future<void> _uploadDesign() async {
    if (!_formKey.currentState!.validate() || _imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and select images.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in or email not available.')),
        );
        setState(() => _isUploading = false); // Reset loading state
        return; // Return early
      }
      final String currentUserEmail = user.email!; // Store the email

      final docRef = FirebaseFirestore.instance
          .collection('contests')
          .doc(widget.contestId)
          .collection('entries')
          .doc();

      List<String> imageBase64 = [];
      for (var img in _imageFiles) {
        final bytes = await File(img.path).readAsBytes();
        imageBase64.add(base64Encode(bytes));
      }

      // Prepare entry data
      Map<String, dynamic> entryData = {
        'title': _titleController.text.trim(),
        'concept': _conceptController.text.trim(),
        'createdBy': currentUserEmail, // Use the stored email
        'createdAt': Timestamp.now(),
        'votes': [],
        'images': imageBase64,
        'coverImage': imageBase64.isNotEmpty ? imageBase64.first : null,
        'id': docRef.id,
        'contestId': widget.contestId,
      };

      await docRef.set(entryData);
      print('Design uploaded successfully by $currentUserEmail for contest ${widget.contestId}');
      await addUserToContestParticipants(widget.contestId, currentUserEmail);


      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Design uploaded successfully!')));
      if (mounted) { // Check if the widget is still in the tree
        Navigator.pop(context);
      }
    } catch (e) {
      print('Upload failed: $e'); // Print full error to console for debugging
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: ${e.toString()}')));
    } finally {
      if (mounted) { // Check if the widget is still in the tree
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _conceptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: "Upload Design", style: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isUploading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageFiles.isNotEmpty
                      ? ListView(
                    scrollDirection: Axis.horizontal,
                    children: _imageFiles
                        .map((img) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(File(img.path), width: 100, fit: BoxFit.cover),
                    ))
                        .toList(),
                  )
                      : const Center(child: Icon(Icons.add_photo_alternate, size: 50)),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Design Title", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter design title',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Design Concept", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextFormField(
                      controller: _conceptController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter design concept',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _uploadDesign,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color(0xFF689f77),
                ),
                child: const Text('Upload Design', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
