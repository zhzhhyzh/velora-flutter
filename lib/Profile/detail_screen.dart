import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';
import '../user_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        bottomNavigationBar: BottomNavBar(currentIndex: 4),
        backgroundColor: Colors.white,
        appBar: TheAppBar(content: 'User Profile'),
        body: ElevatedButton(
          onPressed: () {
            _auth.signOut();
            Navigator.canPop(context) ? Navigator.pop(context) : null;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UserState()),
            );
          },
          child: Text('Logout'),
        ),
    );
  }
}
