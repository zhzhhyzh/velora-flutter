import 'package:flutter/material.dart';

import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';

class AllHiresScreen extends StatefulWidget {
  const AllHiresScreen({super.key});

  @override
  State<AllHiresScreen> createState() => _AllHiresScreenState();
}

class _AllHiresScreenState extends State<AllHiresScreen> {
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        bottomNavigationBar: BottomNavBar(currentIndex: 2),
        backgroundColor: Colors.white,
        appBar: TheAppBar(content: 'Hire a Designer'),
        body: Center(
          child: Column(
            children: [
              _buildSearchAndFilterBar(),
              _buildTabContent(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,

              )
            ],
          ),
        )
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search designers...',
          filled: true,
          fillColor: Colors.grey.shade200,
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
      ),
    );
  }


  Widget _buildTabButtons() {}

  Widget _buildTabContent() {}






}
