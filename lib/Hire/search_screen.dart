import 'package:flutter/material.dart';
import 'tab_filtered_designer.dart';

import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';

class AllHiresScreen extends StatefulWidget {
  const AllHiresScreen({super.key});

  @override
  State<AllHiresScreen> createState() => _AllHiresScreenState();
}

class _AllHiresScreenState extends State<AllHiresScreen> {
  String _searchQuery = '';
  String? _designCatFilter;
  int _selectedTabIndex = 0;

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
              _buildTabButtons(),
              Expanded(child: _buildTabContent())
            ],
          )
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


  Widget _buildTabButtons() {
    final tabs = ['All Designer', 'Web Design', 'Illustration', 'Animation', 'Branding', 'Print', 'Product Design'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index){
            return Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
                label: SizedBox(
                  width: 100,
                  height: 25,
                  child: Center(child: Text(tabs[index]),),
                ),
                selected: _selectedTabIndex == index,
              onSelected: (selected) {
                  setState(() {
                    _selectedTabIndex = index;
                    _designCatFilter = index == 0 ? null : tabs[index];
                  });
              },
              showCheckmark: false,
              selectedColor: Color(0xff689f77),
              backgroundColor: Colors.grey,
              labelStyle: TextStyle(
                color: Colors.white
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
              ),
            ),
            );
          }),
        ),
      )
    );
  }

  Widget _buildTabContent() {
    if (_selectedTabIndex >= 0 && _selectedTabIndex <= 6) {
      return FilteredTab(
        searchQuery: _searchQuery,
        designCategory: _designCatFilter,
      );
    } else {
      return const Center(child: Text('Invalid tab selected'));
    }
  }
}
