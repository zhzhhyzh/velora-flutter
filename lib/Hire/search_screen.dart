import 'package:flutter/material.dart';

import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';

class AllHiresScreen extends StatefulWidget {
  const AllHiresScreen({super.key});

  @override
  State<AllHiresScreen> createState() => _AllHiresScreenState();
}

class _AllHiresScreenState extends State<AllHiresScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        bottomNavigationBar: BottomNavBar(currentIndex: 2),
        backgroundColor: Colors.white,
        appBar: TheAppBar(content: 'Hire a Designer'),
        body: Center()
    );
  }
}
