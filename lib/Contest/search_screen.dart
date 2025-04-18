import 'package:flutter/material.dart';

import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';

class AllContestsScreen extends StatefulWidget {
  const AllContestsScreen({super.key});

  @override
  State<AllContestsScreen> createState() => _AllContestsScreenState();
}

class _AllContestsScreenState extends State<AllContestsScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        bottomNavigationBar: BottomNavBar(currentIndex: 1),
        backgroundColor: Colors.white,
        appBar: TheAppBar(content: 'Contest'),
        body: Center()
    );
  }
}
