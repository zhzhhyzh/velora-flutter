import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/contest.dart';
import '../Widgets/the_app_bar.dart';
import '../Widgets/bottom_nav_bar.dart';
import 'upload_design.dart';

class ContestDetailPage extends StatefulWidget {
  final Contest contest;

  const ContestDetailPage({super.key, required this.contest});

  @override
  State<ContestDetailPage> createState() => _ContestDetailPageState();
}

class _ContestDetailPageState extends State<ContestDetailPage> {
  late String contestId;
  late String userEmail;
  List<Map<String, dynamic>> entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    contestId = widget.contest.id;
    userEmail = widget.contest.createdBy; // Later you may get user email differently
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('contests')
          .doc(contestId)
          .collection('entries')
          .get();

      final data = snapshot.docs.map((doc) {
        final entry = doc.data();
        entry['id'] = doc.id;
        return entry;
      }).toList();

      data.sort((a, b) => (b['votes']?.length ?? 0).compareTo(a['votes']?.length ?? 0));

      setState(() {
        entries = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching entries: $e');
    }
  }

  Future<void> _voteEntry(String entryId, bool hasVoted) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final entryRef = FirebaseFirestore.instance
        .collection('contests')
        .doc(contestId)
        .collection('entries')
        .doc(entryId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(entryRef);
      if (!snapshot.exists) return;

      final votes = List<String>.from(snapshot['votes'] ?? []);
      if (hasVoted) {
        votes.remove(user.email);
      } else {
        votes.add(user.email!);
      }

      transaction.update(entryRef, {'votes': votes});
    });

    await _fetchEntries();
  }

  bool _hasUserVoted(Map<String, dynamic> entry) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final votes = List<String>.from(entry['votes'] ?? []);
    return votes.contains(user.email);
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    final postDate = entry['createdAt'] != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(
      (entry['createdAt'] as Timestamp).toDate(),
    )
        : 'Unknown date';

    final hasVoted = _hasUserVoted(entry);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            entry['fileUrl'] != null
                ? ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                entry['fileUrl'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry['title'] ?? 'Untitled',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Posted on: $postDate',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(entry['concept'] ?? ''),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(entry['votes'] as List?)?.length ?? 0} Votes',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () => _voteEntry(entry['id'], hasVoted),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasVoted ? Colors.red : const Color(0xFF689f77),
                        ),
                        child: Text(hasVoted ? 'Unvote' : 'Vote'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: widget.contest.title),
      body: Column(
        children: [
          // Contest Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.contest.coverImagePath.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.contest.coverImagePath,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : const SizedBox(),
                const SizedBox(height: 12),
                Text(
                  widget.contest.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('dd MMM').format(widget.contest.startDate)} - ${DateFormat('dd MMM yyyy').format(widget.contest.endDate)}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UploadDesignPage(contestId: contestId)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF689f77),
                  ),
                  child: const Text('Upload Your Design', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _fetchEntries,
              child: entries.isEmpty
                  ? const Center(child: Text('No entries found.'))
                  : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) => _buildEntryCard(entries[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
