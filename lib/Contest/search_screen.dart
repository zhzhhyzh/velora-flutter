import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/contest.dart';
import '../Services/LocalDatabase/contests.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';
import 'contest_detail.dart';
import 'create_contest.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Services/Notification/notification_service.dart';
import '../../Services/Notification/notification_handler.dart';
import '../Services/global_dropdown.dart';

class AllContestsScreen extends StatefulWidget {
  const AllContestsScreen({super.key});

  @override
  State<AllContestsScreen> createState() => _AllContestsScreenState();
}

class _AllContestsScreenState extends State<AllContestsScreen> {
  String selectedTab = 'On Going';
  String _searchQuery = '';
  String? _selectedCategory;

  List<Map<String, dynamic>> _contestMaps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();


    _loadLocalContests();
    _fetchCloudContests();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🟢 Post-frame callback started');
      _checkContestWinnerNotification();
    });
  }

  Future<void> _checkContestWinnerNotification() async {
    debugPrint('_checkContestWinnerNotification() invoked');
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final notificationHandler = NotificationHandler();

    final contestSnapshot = await FirebaseFirestore.instance
        .collection('contests')
        .where('endDate', isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .get();

    for (final contestDoc in contestSnapshot.docs) {
      final contestData = contestDoc.data();
      final contestId = contestDoc.id;
      final contestTitle = contestData['title'] as String? ?? 'Untitled Contest';
      final notified = contestData['winnerNotified'] as bool? ?? false;
      // This is the creator of the CONTEST
      final contestCreatorEmail = contestData['createdBy'] as String?;

      if (notified == true) {
        debugPrint('Contest "$contestTitle" (ID: $contestId) already notified.');
        continue;
      }

      debugPrint('Checking contest: "$contestTitle" (ID: $contestId)');

      final entriesSnapshot = await contestDoc.reference.collection('entries').get();

      Map<String, int> voteCounts = {};
      Map<String, String> entryCreatorEmails = {}; // Stores entryId -> email of the entry's creator

      for (final entryDoc in entriesSnapshot.docs) {
        final entryData = entryDoc.data();
        final entryId = entryDoc.id;

        debugPrint('Processing Entry ID: $entryId, Data: $entryData');

        final votes = (entryData['votes'] as List?)?.cast<String>() ?? [];
        voteCounts[entryId] = votes.length;

        // ---- MODIFIED LINE ----
        // The field name for the entry creator's email is 'createdBy'
        String? creatorEmail = entryData['createdBy'] as String?;
        // ---- END MODIFICATION ----

        debugPrint('For Entry ID: $entryId, Retrieved creatorEmail: $creatorEmail from field "createdBy"');

        entryCreatorEmails[entryId] = creatorEmail ?? '';
      }

      if (voteCounts.isEmpty) {
        debugPrint('No entries or votes for contest: "$contestTitle"');
        await contestDoc.reference.update({'winnerNotified': true, 'winnerEmail': null});
        continue;
      }

      // Find the entry with the most votes
      // Make sure there's at least one entry before calling reduce, or handle empty voteCounts
      final winningEntryId = voteCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      final actualWinnerEmail = entryCreatorEmails[winningEntryId] ?? '';

      debugPrint('Winning entry for "$contestTitle": $winningEntryId, Winner Email: $actualWinnerEmail');

      await contestDoc.reference.update({
        'winnerEmail': actualWinnerEmail.isNotEmpty ? actualWinnerEmail : null,
        'winnerNotified': true,
      });

      // Send notification to the actual winner (creator of the winning entry)
      if (actualWinnerEmail.isNotEmpty) {
        debugPrint('🏆 Sending WINNER notification to: $actualWinnerEmail for contest "$contestTitle"');
        await notificationHandler.sendNotification(
          theEmail: actualWinnerEmail,
          title: "🎉 You Won! 🎉",
          message: "Congratulations! Your entry won the '$contestTitle' contest!",
        );
      } else {
        debugPrint('Winner email is empty for contest "$contestTitle", winning entry ID: $winningEntryId. No winner notification sent.');
      }

      // Send notification to the contest creator (jas@gmail.com in this example)
      if (contestCreatorEmail != null && contestCreatorEmail.isNotEmpty) {
        if (contestCreatorEmail != actualWinnerEmail || actualWinnerEmail.isEmpty) {
          debugPrint('🔔 Sending CONTEST ENDED notification to contest creator: $contestCreatorEmail for contest "$contestTitle"');
          await notificationHandler.sendNotification(
            theEmail: contestCreatorEmail,
            title: "Contest '$contestTitle' Has Ended",
            message: "The contest '$contestTitle' has concluded. A winner has been determined.",
          );
        } else {
          debugPrint('Contest creator ($contestCreatorEmail) is also the winner for "$contestTitle". Skipping redundant "Contest Ended" notification.');
        }
      } else {
        debugPrint('Contest creator email is null or empty for contest "$contestTitle". No creator notification sent.');
      }

      // Now, send notifications to participants who didn't win

      // ADD THIS DEBUG PRINT:
      final participants = List<String>.from(contestData['participants'] as List? ?? []);
      // ---- KEY DEBUG PRINT #1 ----
      debugPrint('For contest "$contestTitle": Participants list from Firestore: $participants. Actual winner: $actualWinnerEmail');

      // Now, send notifications to participants who didn't win
      for (final participantEmail in participants) {
        // ---- KEY DEBUG PRINT #2 ----
        debugPrint('For contest "$contestTitle": Processing participant "$participantEmail" for non-winner_notification. IsNotEmpty: ${participantEmail.isNotEmpty}. IsActualWinner: ${participantEmail == actualWinnerEmail}');

        if (participantEmail.isNotEmpty && participantEmail != actualWinnerEmail) {
          // ---- KEY DEBUG PRINT #3 ----
          debugPrint('📩 For contest "$contestTitle": Attempting to send non-winner notification to: $participantEmail');
          await notificationHandler.sendNotification(
            theEmail: participantEmail,
            title: "Contest '$contestTitle' Ended",
            message: "The contest '$contestTitle' has ended. Thank you for participating!",
          );
          // Optional: Add a log to confirm the API call was made
          debugPrint('Notification API call completed for $participantEmail in contest "$contestTitle".');
        } else {
          if (participantEmail.isEmpty) {
            debugPrint('For contest "$contestTitle": Skipped participant "$participantEmail" because email string is empty.');
          }
          if (participantEmail == actualWinnerEmail) {
            debugPrint('For contest "$contestTitle": Skipped participant "$participantEmail" because they are the actual winner.');
          }
        }
      }
    }
    debugPrint('_checkContestWinnerNotification() finished.');
  }

  Future<void> _loadLocalContests() async {
    try {
      final localContests = await LocalDatabase.getContests();
      final localMaps = localContests.map((contest) => {
        'doc': null,
        'data': {
          'id': contest.id,
          'title': contest.title,
          'description': contest.description,
          'category': contest.category,
          'startDate': contest.startDate.toIso8601String(),
          'endDate': contest.endDate.toIso8601String(),
          'coverImagePath': contest.coverImagePath,
          'createdBy': contest.createdBy,
          'createdAt': contest.createdAt.toIso8601String(),
          'isActive': contest.isActive,
        }
      }).toList();

      if (mounted) {
        setState(() {
          _contestMaps = localMaps;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Local DB error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCloudContests() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('contests').get();
      final contestDocs = snapshot.docs;

      final contests = contestDocs.map((doc) {
        final data = doc.data();
        return {
          'doc': doc,
          'data': {
            ...data,
            'startDate': DateTime.fromMillisecondsSinceEpoch(data['startDate']).toIso8601String(),
            'endDate': DateTime.fromMillisecondsSinceEpoch(data['endDate']).toIso8601String(),
            'createdAt': DateTime.fromMillisecondsSinceEpoch(data['createdAt']).toIso8601String(),
          }
        };
      }).toList();

      await LocalDatabase.clearContests();
      for (final c in contests) {
        final Map<String, dynamic> d = c['data'] as Map<String, dynamic>;

        await LocalDatabase.insertContest(Contest(
          id: d['id'],
          title: d['title'],
          description: d['description'],
          category: d['category'],
          startDate: DateTime.parse(d['startDate']),
          endDate: DateTime.parse(d['endDate']),
          coverImagePath: d['coverImagePath'],
          createdBy: d['createdBy'],
          createdAt: DateTime.parse(d['createdAt']),
          isActive: d['isActive'] == true,
        ));
      }


      if (mounted) {
        setState(() {
          _contestMaps = contests;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching contests: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getFilteredContests() {
    final now = DateTime.now();

    return _contestMaps.where((contestMap) {
      final data = contestMap['data'] as Map<String, dynamic>;


      final title = (data['title'] ?? '').toLowerCase();
      final desc = (data['description'] ?? '').toLowerCase();
      final cat = data['category'];

      final start = DateTime.tryParse(data['startDate']);
      final end = DateTime.tryParse(data['endDate']);

      final matchesSearch = _searchQuery.isEmpty || title.contains(_searchQuery) || desc.contains(_searchQuery);
      final matchesCat = _selectedCategory == null || _selectedCategory == cat;

      if (!matchesSearch || !matchesCat || start == null || end == null) return false;

      if (selectedTab == 'Past') return end.isBefore(now);
      if (selectedTab == 'On Going') return start.isBefore(now) && end.isAfter(now);
      return start.isAfter(now);
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.filter_list_rounded, color: Colors.black),
            SizedBox(width: 8),
            // Ensure this title accurately reflects the categories being filtered
            Text('Filter Contest', style: TextStyle(color: Colors.black)),
          ],
        ),
        content: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade700,
            hintStyle: TextStyle(color: Colors.white, fontSize: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.red, width: 1)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
          ),
          value: _selectedCategory,
          hint: const Text('Select Design Category', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          dropdownColor: Colors.black,
          iconEnabledColor: Colors.grey.shade200,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          isExpanded: true,
          items: GlobalDD.designCategories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(
                category,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategory = val;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF689f77)),
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (end.isBefore(now)) return "Ended";
    if (start.isBefore(now) && end.isAfter(now)) {
      final daysLeft = end.difference(now).inDays;
      return "$daysLeft day${daysLeft != 1 ? 's' : ''} left";
    }
    return "Starts on ${DateFormat('dd MMM').format(start)}";
  }

  Widget _buildContestCard(Map<String, dynamic> contestMap) {
    final data = contestMap['data'] as Map<String, dynamic>;

    DateTime startDate = DateTime.tryParse(data['startDate']) ?? DateTime.now();
    DateTime endDate = DateTime.tryParse(data['endDate']) ?? DateTime.now();

    Widget imageWidget;
    try {
      imageWidget = data['coverImagePath'] != null && (data['coverImagePath'] as String).isNotEmpty
          ? Image.memory(base64Decode(data['coverImagePath']), fit: BoxFit.cover)
          : const Icon(Icons.image, color: Colors.grey);
    } catch (e) {
      imageWidget = const Icon(Icons.broken_image, color: Colors.grey);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () {
          final contest = Contest(
            id: data['id'],
            title: data['title'],
            description: data['description'],
            category: data['category'],
            startDate: startDate,
            endDate: endDate,
            coverImagePath: data['coverImagePath'],
            createdBy: data['createdBy'],
            createdAt: DateTime.tryParse(data['createdAt']) ?? DateTime.now(),
            isActive: data['isActive'] == true,
          );

          Navigator.push(context, MaterialPageRoute(builder: (_) => ContestDetailPage(contest: contest)));
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
                  color: const Color(0xFF689f77),
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
                        data['title'] ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['category']?.toString().toUpperCase() ?? '',
                              style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            width: 110,
                            height: 20,
                            margin: const EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF689f77),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusLabel(startDate, endDate),
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
