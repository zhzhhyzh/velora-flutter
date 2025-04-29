import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../Widgets/the_app_bar.dart';
import '../Widgets/bottom_nav_bar.dart';

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
  File? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.media);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadDesign() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all fields and select a file.')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.path.split('/').last}';
      final ref = FirebaseStorage.instance.ref().child('contest_entries/$fileName');
      await ref.putFile(_selectedFile!);
      final fileUrl = await ref.getDownloadURL();

      final entryRef = FirebaseFirestore.instance
          .collection('contests')
          .doc(widget.contestId)
          .collection('entries')
          .doc();

      await entryRef.set({
        'title': _titleController.text.trim(),
        'concept': _conceptController.text.trim(),
        'fileUrl': fileUrl,
        'createdBy': user.email,
        'createdAt': Timestamp.now(),
        'votes': [],
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Design uploaded successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _isUploading = false);
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
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
      backgroundColor: Colors.white,
      appBar: const TheAppBar(content: 'Upload Design'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isUploading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedFile != null
                      ? Image.file(_selectedFile!, fit: BoxFit.cover)
                      : const Icon(Icons.add_photo_alternate, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Design Title'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _conceptController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Design Concept'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
