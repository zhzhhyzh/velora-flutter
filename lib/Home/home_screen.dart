import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velora2/Widgets/bottom_nav_bar.dart';
import 'package:velora2/Widgets/the_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: 'Explore'),
      body: Center()
    );
  }
}
