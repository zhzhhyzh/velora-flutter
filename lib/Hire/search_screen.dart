import 'package:flutter/material.dart';
import '../Services/global_dropdown.dart';
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
  final tabs = ['All Designer', ...GlobalDD.designCategoryList ]; //... make tabs a List<String> instead of List<Object>
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
    if (_selectedTabIndex >= 0 && _selectedTabIndex <= 9) {
      return FilteredTab(
        searchQuery: _searchQuery,
        designCategory: _designCatFilter,
      );
    } else {
      return const Center(child: Text('Invalid tab selected'));
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
                  SizedBox(width: 10),
                  Text('Filter Designers',style: TextStyle(color: Colors.black))
                ],
              ),
              SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 8),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: GlobalDD.designCategoryList.contains(_designCatFilter) ? _designCatFilter : null,
                  hint: Text('Designer Category', style: TextStyle(color: Color(0xFFD9D9D9))),
                  decoration: _dropdownDecoration(),
                  dropdownColor: Colors.black87,
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  items: 
                    GlobalDD.designCategoryList
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                  onChanged: (val) {
                    setState(() {
                      _designCatFilter = val;
                      _selectedTabIndex = tabs.indexOf(val ?? '');
                    });
                  },
                ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: (){
                setState(() {
                  _designCatFilter = null;
                });
                Navigator.pop(context);
              },
              child: Text('Clear', style: TextStyle(color: Colors.red))
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
                setState(() {});
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF689f77),
                ),
              child: const Text('Apply', style: TextStyle(color: Colors.white))
            )
          ],
        );
      }
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.black54,
      hintStyle: const TextStyle(color: Color(0xFFb9b9b9)),
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black)
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black),
      ),
      errorBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }
}
