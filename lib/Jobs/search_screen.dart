import 'package:flutter/material.dart';
import 'package:velora2/Jobs/create_job.dart';

import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';

class AllJobsScreen extends StatefulWidget {
  const AllJobsScreen({super.key});

  @override
  State<AllJobsScreen> createState() => _AllJobsScreenState();
}

class _AllJobsScreenState extends State<AllJobsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: 'Job Board'),
      body: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateJob()),
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xFF689f77)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        child: const Text(
          'Add Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
