import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/global_dropdown.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';
import '../Services/local_database.dart';
import '../user_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? imageFile;
  Uint8List? profileImageBytes;
  bool _isLoadingLocal = true;

  final _usernameCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
    _fetchAndUpdateFirebaseUser();
  }

  Future<void> _loadLocalUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final localData = await LocalDatabase.getData(
        tableName: 'user_profile',
        id: user.uid,
      );
      if (localData != null) {
        setState(() {
          _usernameCtrl.text = localData['name'] ?? '';
          _emailCtrl.text = localData['email'] ?? '';
          _phoneCtrl.text = localData['phoneNumber'] ?? '';
          _positionCtrl.text = localData['position'] ?? '';
          if (localData['userImage'] != null) {
            profileImageBytes = base64Decode(localData['userImage']);
          }
          _isLoadingLocal = false;
        });
      } else {
        _isLoadingLocal = false;
      }
    }
  }

  Future<void> _fetchAndUpdateFirebaseUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _usernameCtrl.text = data?['name'] ?? '';
          _emailCtrl.text = data?['email'] ?? '';
          _phoneCtrl.text = data?['phoneNumber'] ?? '';
          _positionCtrl.text = data?['position'] ?? '';
          if (data?['userImage'] != null) {
            profileImageBytes = base64Decode(data!['userImage']);
          }
        });

        await LocalDatabase.saveData(
          tableName: 'user_profile',
          id: user.uid,
          data: {
            'name': _usernameCtrl.text.trim(),
            'email': _emailCtrl.text.trim(),
            'phoneNumber': _phoneCtrl.text.trim(),
            'position': _positionCtrl.text.trim(),
            'userImage': data?['userImage'],
          },
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      String? base64Image;
      if (imageFile != null) {
        final bytes = await imageFile!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final updatedData = {
        'name': _usernameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'position': _positionCtrl.text.trim(),
        if (base64Image != null) 'userImage': base64Image,
      };

      await _firestore.collection('users').doc(user.uid).update(updatedData);

      await LocalDatabase.saveData(
        tableName: 'user_profile',
        id: user.uid,
        data: updatedData,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UserState()));
  }

  void _showImagePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
            onPressed: () => _pickImage(ImageSource.camera),
          ),
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(sourcePath: pickedFile.path);
      if (croppedFile != null) {
        setState(() {
          imageFile = File(croppedFile.path);
        });
      }
    }
    Navigator.pop(context);
  }

  InputDecoration _dropdownDecoration() {
    return const InputDecoration(
      filled: true,
      fillColor: Colors.black54,
      hintStyle: TextStyle(color: Color(0xFFb9b9b9)),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _positionCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 4),
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: 'User Profile'),
      body: _isLoadingLocal
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: CircleAvatar(
                      radius: size.width * 0.15,
                      backgroundColor: const Color(0xFF689F77),
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : (profileImageBytes != null
                          ? MemoryImage(profileImageBytes!)
                          : null) as ImageProvider?,
                      child: (imageFile == null && profileImageBytes == null)
                          ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildFormFields(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF689F77),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textTitles(label: "Username"),
        _textFormField(valueKey: "username", controller: _usernameCtrl, enabled: true, fct: () {}, maxLength: 100, hint: "Enter Username"),
        _textTitles(label: "Phone No."),
        _textFormField(valueKey: "hpno", controller: _phoneCtrl, enabled: true, fct: () {}, maxLength: 100, hint: "Enter Phone No."),
        _textTitles(label: "Email"),
        _textFormField(valueKey: "email", controller: _emailCtrl, enabled: true, fct: () {}, maxLength: 100, hint: "Enter Email"),
        _textTitles(label: "Password"),
        _textFormField(valueKey: "password", controller: _passwordCtrl, enabled: true, fct: () {}, maxLength: 100, hint: "Enter Password"),
        _textTitles(label: "Position"),
        DropdownButtonFormField<String>(
          value: _positionCtrl.text.isNotEmpty ? _positionCtrl.text : null,
          decoration: _dropdownDecoration(),
          hint: const Text("Select Position", style: TextStyle(color: Color(0xFFD9D9D9))),
          items: GlobalDD.positions.map((String position) {
            return DropdownMenuItem<String>(
              value: position,
              child: Text(position, style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
          dropdownColor: Colors.white,
          iconEnabledColor: Colors.black,
          style: const TextStyle(color: Colors.black),
          onChanged: (String? value) {
            setState(() {
              _positionCtrl.text = value ?? '';
            });
          },
        ),
      ],
    );
  }

  Widget _textTitles({required String label}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        validator: (value) => value!.isEmpty ? 'Value is missing' : null,
        controller: controller,
        enabled: enabled,
        key: ValueKey(valueKey),
        style: const TextStyle(color: Colors.white),
        maxLength: maxLength,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFb9b9b9)),
          filled: true,
          fillColor: Colors.black54,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
