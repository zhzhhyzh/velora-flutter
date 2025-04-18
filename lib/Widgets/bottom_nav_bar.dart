import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velora2/Contest/search_screen.dart';
import 'package:velora2/Hire/search_screen.dart';
import 'package:velora2/Home/home_screen.dart';
import 'package:velora2/Jobs/search_screen.dart';
import 'package:velora2/Profile/detail_screen.dart';

class BottomNavBar extends StatelessWidget {
  int currentIndex = 0;

  BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: Colors.black54,
      backgroundColor: Color(0xFF689f77),
      buttonBackgroundColor: Colors.white,
      height: 50,
      index: currentIndex,
      items: [
        Icon(Icons.explore, size: 19, color: Color(0xFF689f77)),
        Icon(Icons.signal_cellular_alt_rounded, size: 19, color: Color(0xFF689f77)),
        Icon(Icons.person_search, size: 19, color: Color(0xFF689f77)),
        Icon(Icons.work, size: 19, color: Color(0xFF689f77)),
        Icon(Icons.face, size: 19, color: Color(0xFF689f77)),
      ],
      animationDuration: Duration(milliseconds: 300),
      animationCurve: Curves.bounceInOut,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AllContestsScreen()),
          );
        }
        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AllHiresScreen()),
          );
        }
        if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AllJobsScreen()),
          );
        }
        if (index == 4) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProfileScreen()),
          );
        }
      },
    );
  }
}
