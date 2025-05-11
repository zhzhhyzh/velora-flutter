import 'dart:async';

import 'package:flutter/material.dart';
import 'package:velora2/Hire/edit_desinger_form.dart';
import '../Services/global_dropdown.dart';
import '../Services/global_methods.dart';
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
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  String? countryFilter;
  String? stateFilter;
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

              Padding(
                padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Designer List',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterOrEditDesigner())
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF689f77),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                          ),
                      ),
                      child: Text(
                        'Be a designer',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    )
                  ]
                ),
              ),

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
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for designers...',
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _isSearching = false;
              });
            },
          ): IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black),
            onPressed: _showFilterDialog,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
            _isSearching = value.isNotEmpty;
          });
        } ,
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
        country : countryFilter,
        state : stateFilter
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
                  Text('Filter Designers',style: TextStyle(color: Colors.black, fontSize: 16))
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: countryFilter,
                    hint: Text("Select Country", style: TextStyle(color: Color(0xFFD9D9D9))),
                    decoration: _dropdownDecoration(),
                    dropdownColor: Colors.black87,
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    items: GlobalDD.countries.map(
                            (item) => DropdownMenuItem(value: item, child: Text(item))
                    ).toList(),
                    onChanged: (val) => setState(() {
                      countryFilter = val!;
                      stateFilter = null;
                    }),
                  ),
                ),
                countryFilter == ''
                    ? GestureDetector(
                  onTap: () {
                    GlobalMethod.showErrorDialog(
                      error: "Please select country first",
                      ctx: context,
                    );
                  },
                  child: InputDecorator(
                    decoration: _dropdownDecoration(),
                    child: Text(
                      "Select State",
                      style: TextStyle(color: Color(0xFFD9D9D9)),
                    ),
                  ),
                )
                    : DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: stateFilter,
                  hint: Text("Select State", style: TextStyle(color: Color(0xFFD9D9D9))),
                  decoration: _dropdownDecoration(),
                  dropdownColor: Colors.black87,
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  items: (GlobalDD.states[countryFilter] ?? [])
                      .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (val) => setState(() => stateFilter = val),
                ),
              ],
            )
          ),
          actions: [
            TextButton(
              onPressed: (){
                setState(() {
                  countryFilter = null;
                  stateFilter = null;
                });
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
