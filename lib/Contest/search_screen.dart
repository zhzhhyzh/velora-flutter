import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/contest.dart';
import '../Services/local_database.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';
import 'contest_detail.dart';
import 'create_contest.dart';

class AllContestsScreen extends StatefulWidget {
  const AllContestsScreen({super.key});

  @override
  State<AllContestsScreen> createState() => _AllContestsScreenState();
}

class _AllContestsScreenState extends State<AllContestsScreen> {
  String selectedTab = 'On Going';
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = [
    'Web Design', 'Mobile Design', 'Fashion Design', 'Packaging Design',
    'Advertising Design', 'Graphic Design', 'Interior Design', 'Architecture Design',
    'Logo Design', 'Animation Design'
  ];

  List<Contest> _contests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalContests();
    _fetchCloudContests();
  }

  Future<void> _loadLocalContests() async {
    try {
      final contests = await LocalDatabase.getContests();
      if (mounted) {
        setState(() {
          _contests = contests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Local DB error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCloudContests() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('contests').get();
      final contests = snapshot.docs.map((doc) => Contest.fromFirestore(doc)).toList();
      print("Fetched ${contests.length} contests from Firebase");

      await LocalDatabase.clearContests();
      for (final contest in contests) {
        await LocalDatabase.insertContest(contest);
      }

      if (mounted) {
        setState(() {
          _contests = contests;
          _isLoading = false;
        });
      }
    } catch (e, st) {
      print('Error fetching contests: $e');
      print('Stacktrace: $st');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isPast(Contest contest) => contest.endDate.isBefore(DateTime.now());
  bool _isOnGoing(Contest contest) => contest.startDate.isBefore(DateTime.now()) && contest.endDate.isAfter(DateTime.now());
  bool _isUpcoming(Contest contest) => contest.startDate.isAfter(DateTime.now());

  List<Contest> _getFilteredContests() {
    return _contests.where((contest) {
      if (_searchQuery.isNotEmpty &&
          !(contest.title.toLowerCase().contains(_searchQuery) ||
              contest.description.toLowerCase().contains(_searchQuery))) return false;
      if (_selectedCategory != null && contest.category != _selectedCategory) return false;
      if (selectedTab == 'Past') return _isPast(contest);
      if (selectedTab == 'On Going') return _isOnGoing(contest);
      return _isUpcoming(contest);
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filter by Category'),
        content: DropdownButtonFormField<String>(
          value: _selectedCategory,
          hint: const Text('Select Category'),
          items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedCategory = null);
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF689f77)),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(Contest contest) {
    final now = DateTime.now();
    if (_isPast(contest)) {
      return "Ended";
    } else if (_isOnGoing(contest)) {
      final daysLeft = contest.endDate.difference(now).inDays;
      return "$daysLeft day${daysLeft != 1 ? 's' : ''} left";
    } else {
      return "Starts on ${DateFormat('dd MMM').format(contest.startDate)}";
    }
  }


  Widget _buildContestCard(Contest contest) {
    Widget imageWidget;
    try {
      imageWidget = contest.coverImagePath.isNotEmpty
          ? Image.memory(
        base64Decode(contest.coverImagePath),
        fit: BoxFit.cover,
      )
          : const Icon(Icons.image, color: Colors.grey);
    } catch (e) {
      imageWidget = const Icon(Icons.broken_image, color: Colors.grey);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ContestDetailPage(contest: contest),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF689f77),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageWidget,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contest.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contest.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            width: 110,
                            height: 20,
                            margin: const EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color(0xFF689f77),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusLabel(contest),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contests = _getFilteredContests();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: 'Contest'),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
      body: Column(
        children: [
          // Search bar with filter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search contests...',
                filled: true,
                fillColor: Colors.grey.shade200,
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                suffixIcon: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list_rounded, color: Colors.black),
                      onPressed: _showFilterDialog,
                    ),
                    if (_selectedCategory != null)
                      Positioned(
                        right: 4,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                  ],
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // Tab buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: ['Past', 'On Going', 'Upcoming'].map((tab) {
                final isSelected = selectedTab == tab;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () => setState(() => selectedTab = tab),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? const Color(0xFF689f77) : Colors.grey,
                      ),
                      child: Text(tab, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Header + Create Contest
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Available Contests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateContestPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF689f77),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Create Contest', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // List view
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _fetchCloudContests,
              child: contests.isEmpty
                  ? const Center(child: Text('No Contests Found'))
                  : ListView.builder(
                itemCount: contests.length,
                itemBuilder: (_, i) => _buildContestCard(contests[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
