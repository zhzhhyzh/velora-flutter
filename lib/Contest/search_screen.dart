import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:velora2/models/contest.dart';
import 'package:velora2/Services/local_database.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';
import 'create_contest.dart';

class AllContestsScreen extends StatefulWidget {
  const AllContestsScreen({super.key});

  @override
  State<AllContestsScreen> createState() => _AllContestsScreenState();
}

class _AllContestsScreenState extends State<AllContestsScreen> {
  String selectedTab = 'On Going'; // default
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
    final contests = await LocalDatabase.getContests();
    setState(() {
      _contests = contests;
      _isLoading = false;
    });
  }

  Future<void> _fetchCloudContests() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('contests').get();
      final contests = snapshot.docs.map((doc) => Contest.fromFirestore(doc)).toList();
      await LocalDatabase.clearContests();
      for (final contest in contests) {
        await LocalDatabase.insertContest(contest);
      }
      setState(() {
        _contests = contests;
      });
    } catch (e) {
      print('Error fetching contests: $e');
    }
  }

  bool _isPast(Contest contest) {
    final now = DateTime.now();
    return contest.endDate.isBefore(now);
  }

  bool _isOnGoing(Contest contest) {
    final now = DateTime.now();
    return contest.startDate.isBefore(now) && contest.endDate.isAfter(now);
  }

  bool _isUpcoming(Contest contest) {
    final now = DateTime.now();
    return contest.startDate.isAfter(now);
  }

  List<Contest> _getFilteredContests() {
    return _contests.where((contest) {
      if (_searchQuery.isNotEmpty &&
          !(contest.title.toLowerCase().contains(_searchQuery) ||
              contest.description.toLowerCase().contains(_searchQuery))) {
        return false;
      }
      if (_selectedCategory != null && contest.category != _selectedCategory) {
        return false;
      }
      if (selectedTab == 'Past') {
        return _isPast(contest);
      } else if (selectedTab == 'On Going') {
        return _isOnGoing(contest);
      } else {
        return _isUpcoming(contest);
      }
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Category'),
          content: DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: const Text('Select Category'),
            items: _categories.map((cat) => DropdownMenuItem(
              value: cat,
              child: Text(cat),
            )).toList(),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF689f77),
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContestCard(Contest contest) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        // onTap: () {
        //   // TODO: Navigate to Contest Detail Page
        // },
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
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: contest.coverImagePath.isNotEmpty
                      ? Image.network(
                    contest.coverImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                  )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contest.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contest.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

    return  Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: 'Contest'),
      body: Column(
        children: [
          // 🔍 Search Bar with filter
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
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // Tabs: Past / On Going / Upcoming
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      child: Text(
                        tab,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Contest header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Available Contests",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateContestPage()),
                    );
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

          // Contest List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _fetchCloudContests,
              child: contests.isEmpty
                  ? const Center(child: Text('No Contests Found'))
                  : ListView.builder(
                itemCount: contests.length,
                itemBuilder: (context, index) => _buildContestCard(contests[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
