import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velora2/Models/users.dart';

import '../Services/LocalDatabase/users.dart';
import '../Services/global_dropdown.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';
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
  final _usernameCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(); // optional if you want
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalusers();
    _fetchAndSyncCloudusers();
  }

  Future<void> _loadLocalusers() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final localUser = await LocalDatabase.getUserById(user.uid);
        if (localUser != null && mounted) {
          setState(() {
            _usernameCtrl.text = localUser.name;
            _emailCtrl.text = localUser.email;
            _phoneCtrl.text = localUser.phoneNumber;
            _positionCtrl.text = localUser.position;
            if (localUser.userImage != null) {
              profileImageBytes = base64Decode(localUser.userImage!);
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Local DB error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<void> _fetchAndSyncCloudusers() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return;

      final data = doc.data();
      if (data != null) {
        final userModel = UserModel(
          id: user.uid,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          position: data['position'] ?? '',
          userImage: data['userImage'], // base64
        );


        // Update UI
        setState(() {
          _usernameCtrl.text = userModel.name;
          _emailCtrl.text = userModel.email;
          _phoneCtrl.text = userModel.phoneNumber;
          _positionCtrl.text = userModel.position;
          if (userModel.userImage != null) {
            profileImageBytes = base64Decode(userModel.userImage!);
          }
          _isLoading = false;
        });

        // Sync to local DB
        await LocalDatabase.clearUsers();
        await LocalDatabase.insertUser(userModel);
      }
    } catch (e, st) {
      debugPrint('Error fetching users: $e\n$st');
      if (mounted) setState(() => _isLoading = false);
    }
  }



  Widget _textTitles({required String label}) {
    return  Text(
      label,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
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
  Future<void> _updateProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final oldEmail = user.email;
      await user.verifyBeforeUpdateEmail(_emailCtrl.text.trim());

      String? base64Image;
      if (imageFile != null) {
        final bytes = await imageFile!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      await _firestore.collection('users').doc(user.uid).update({
        'name': _usernameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'position': _positionCtrl.text.trim(),
        if (base64Image != null) 'userImage': base64Image,
      });


      final designersRef = _firestore.collection('designers');
      final existingDesignerQuery = await designersRef
          .where('email', isEqualTo: oldEmail)
          .limit(1)
          .get();

      if (existingDesignerQuery.docs.isNotEmpty) {
        final String designerId = existingDesignerQuery.docs.first.id;
        final DocumentReference designerDocRef = designersRef.doc(designerId);
        await designerDocRef.update({'email' : _emailCtrl.text.trim()});
      }
      else {ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ERRRRRRRRRRR')),
      );}


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // cancel
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // close dialog
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const UserState()),
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
    return InputDecoration(
      filled: true,
      fillColor: Colors.black54,
      hintStyle: const TextStyle(color: Color(0xFFb9b9b9)),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      errorBorder: const UnderlineInputBorder(
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
      body: SingleChildScrollView(
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
                            : (profileImageBytes != null ? MemoryImage(profileImageBytes!) : null) as ImageProvider?,
                        child: (imageFile == null && profileImageBytes == null)
                            ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.edit,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 20),
                  _textTitles(label: "Username"),
                  _textFormField(
                    valueKey: "username",
                    controller: _usernameCtrl,
                    enabled: true,
                    fct: () {},
                    maxLength: 100,
                    hint: "Enter Username",
                  ),
                  _textTitles(label: "Phone No."),
                  _textFormField(
                    valueKey: "hpno",
                    controller: _phoneCtrl,
                    enabled: true,
                    fct: () {},
                    maxLength: 100,
                    hint: "Enter Phone No.",
                  ),
                  _textTitles(label: "Email"),
                  _textFormField(
                    valueKey: "email",
                    controller: _emailCtrl,
                    enabled: true,
                    fct: () {},
                    maxLength: 100,
                    hint: "Enter Email",
                  ),
                  _textTitles(label: "Password"),
                  _textFormField(
                    valueKey: "password",
                    controller: _passwordCtrl,
                    enabled: true,
                    fct: () {},
                    maxLength: 100,
                    hint: "Enter Password",
                  ),
                  _textTitles(label: "Position"),
                  DropdownButtonFormField<String>(
                    value: _positionCtrl.text.isNotEmpty ? _positionCtrl.text : null,
                    decoration: _dropdownDecoration(),
                    hint: const Text(
                      "Select Position",
                      style: TextStyle(color: Color(0xFFD9D9D9)),
                    ),
                    items: GlobalDD.positions.map((String position) {
                      return DropdownMenuItem<String>(
                        value: position,
                        child: Text(position, style: const TextStyle(color: Colors.white)),
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
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text('Confirm Save'),
                      content: const Text('Do you want to save these changes?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF689F77)),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Save', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    _updateProfile();
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF689F77),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white,fontSize: 18)),
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
          )
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.black12,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

