import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

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

  String? displayName;
  String? email;
  Uint8List? profileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          displayName = data?['displayName'];
          email = data?['email'];
          final base64Image = data?['profileImage'];
          if (base64Image != null) {
            profileImageBytes = decodeBase64Image(base64Image);
          }
        });
      }
    }
  }

  Uint8List decodeBase64Image(String base64String) {
    final RegExp regex = RegExp(r'data:image/[^;]+;base64,');
    base64String = base64String.replaceAll(regex, '');
    return base64.decode(base64String);
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.logout, color: Colors.black, size: 36),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ],
          ),
          content: const Text(
            'Do you want to Logout?',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                await _auth.signOut(); // Sign out
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => UserState()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF689f77),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 4),
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: 'User Profile'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (profileImageBytes != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: MemoryImage(profileImageBytes!),
              ),
            const SizedBox(height: 16),
            if (displayName != null)
              Text(
                displayName!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            if (email != null)
              Text(
                email!,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.lock, color: Color(0xFFFF0000)),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFFF0000),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
