import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/contest.dart';
import '../Services/LocalDatabase/contests.dart';
import '../Widgets/the_app_bar.dart';

class CreateContestPage extends StatefulWidget {
  const CreateContestPage({Key? key}) : super(key: key);

  @override
  _CreateContestPageState createState() => _CreateContestPageState();
}

class _CreateContestPageState extends State<CreateContestPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _base64CoverImage;
  bool _isUploading = false;

  final List<String> _categories = [
    'Web Design', 'Mobile Design', 'Fashion Design', 'Packaging Design',
    'Advertising Design', 'Graphic Design', 'Interior Design', 'Architecture Design',
    'Logo Design', 'Animation Design'
  ];

  Future<void> _pickAndCropImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Crop Image', lockAspectRatio: false),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (croppedFile == null) return;

    final bytes = await File(croppedFile.path).readAsBytes();
    setState(() {
      _base64CoverImage = base64Encode(bytes);
    });
  }

  Future<void> _createContest() async {
    if (!_formKey.currentState!.validate() ||
        _base64CoverImage == null ||
        _startDate == null ||
        _endDate == null ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      final id = FirebaseFirestore.instance.collection('contests').doc().id;

      final contest = Contest(
        id: id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        startDate: _startDate!,
        endDate: _endDate!,
        coverImagePath: _base64CoverImage!,
        createdBy: user.email!,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await FirebaseFirestore.instance.collection('contests').doc(id).set(contest.toMap());
      await LocalDatabase.insertContest(contest);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contest created successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create contest: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _pickEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select start date first.')));
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: "Create Contest", style: 2),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAndCropImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _base64CoverImage != null
                      ? Image.memory(base64Decode(_base64CoverImage!), fit: BoxFit.cover)
                      : const Icon(Icons.add_a_photo, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Contest Title", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextFormField(
                      controller: _titleController,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter Contest Title',
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
                  const Text("Contest Description", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter Contest Description',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select Category'),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickStartDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF689f77),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      child: Text(_startDate == null ? 'Start Date' : DateFormat.yMd().format(_startDate!), style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickEndDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF689f77),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      child: Text(_endDate == null ? 'End Date' : DateFormat.yMd().format(_endDate!), style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createContest,

                child: const Text('Create Contest', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF689f77),
                    minimumSize: const Size.fromHeight(50)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
