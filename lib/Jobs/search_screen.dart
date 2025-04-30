import 'package:flutter/material.dart';
import '../Services/global_dropdown.dart';
import 'applied_tab.dart';
import 'create_job.dart';
import 'explore_tab.dart';
import 'posted_tab.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';

class AllJobsScreen extends StatefulWidget {
  const AllJobsScreen({super.key});

  @override
  State<AllJobsScreen> createState() => _AllJobsScreenState();
}

class _AllJobsScreenState extends State<AllJobsScreen> {
  String _searchQuery = '';
  String? jobCatFilter;
  String? jobTypeFilter;
  String? minAcaFilter;
  String selectedTab = 'Explore';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: 'Job Board'),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          _buildTabButtons(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your Post",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateJob()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF689f77),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildTabContent()),

        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search jobs...',
          filled: true,
          fillColor: Colors.grey.shade200,
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black),
            onPressed: _showFilterDialog,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
      ),
    );
  }

  Widget _buildTabButtons() {
    final tabs = ['Applied','Explore', 'Posted'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.map((tab) {
          final isSelected = selectedTab == tab;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () => setState(() => selectedTab = tab),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? const Color(0xff689f77) : Colors.grey,
                ),
                child: Text(tab, style: const TextStyle(color: Colors.white)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    if (selectedTab == 'Explore') {
      return ExploreTab(
        searchQuery: _searchQuery,
        jobCatFilter: jobCatFilter,
        jobTypeFilter: jobTypeFilter,
        minAcaFilter: minAcaFilter,
      );
    } else if (selectedTab == 'Applied') {
      return AppliedTab(
        searchQuery: _searchQuery,
        jobCatFilter: jobCatFilter,
        jobTypeFilter: jobTypeFilter,
        minAcaFilter: minAcaFilter,
      );
    } else {
      return PostedTab(
        searchQuery: _searchQuery,
        jobCatFilter: jobCatFilter,
        jobTypeFilter: jobTypeFilter,
        minAcaFilter: minAcaFilter,
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.filter_list_rounded, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Filter Jobs', style: TextStyle(color: Colors.black)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildDropdown(
                  label: 'Job Category',
                  value: jobCatFilter,
                  items: GlobalDD.jobCategoryList,
                  onChanged: (val) => setState(() => jobCatFilter = val),
                ),
                _buildDropdown(
                  label: 'Job Type',
                  value: jobTypeFilter,
                  items: GlobalDD.jobTypeList,
                  onChanged: (val) => setState(() => jobTypeFilter = val),
                ),
                _buildDropdown(
                  label: 'Min Academic Level',
                  value: minAcaFilter,
                  items: GlobalDD.academicLists,
                  onChanged: (val) => setState(() => minAcaFilter = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  jobCatFilter = null;
                  jobTypeFilter = null;
                  minAcaFilter = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF689f77),
              ),
              child: const Text('Apply', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: items.contains(value) ? value : null,
        hint: Text("Select $label", style: TextStyle(color: Color(0xFFD9D9D9))),
        decoration: _dropdownDecoration(),
        dropdownColor: Colors.black87,
        iconEnabledColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        items:
        items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
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
}
