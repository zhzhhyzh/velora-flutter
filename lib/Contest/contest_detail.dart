import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/contest.dart';
import '../Widgets/the_app_bar.dart';
import '../Widgets/bottom_nav_bar.dart';
import 'design_detail.dart';
import 'upload_design.dart';

class ContestDetailPage extends StatefulWidget {
  final Contest contest;

  const ContestDetailPage({super.key, required this.contest});

  @override
  State<ContestDetailPage> createState() => _ContestDetailPageState();
}

class _ContestDetailPageState extends State<ContestDetailPage> {
  late String contestId;
  List<Map<String, dynamic>> entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    contestId = widget.contest.id;
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

  bool get isOnGoing {
    final now = DateTime.now();
    return widget.contest.startDate.isBefore(now) && widget.contest.endDate.isAfter(now);
  }

  bool _hasUserVoted(Map<String, dynamic> entry) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final votes = List<String>.from(entry['votes'] ?? []);
    return votes.contains(user.email);
  }

  Widget _buildEntryCard(Map<String, dynamic> entry, int index) {
    final postDate = entry['createdAt'] != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format((entry['createdAt'] as Timestamp).toDate())
        : 'Unknown date';

    final hasVoted = _hasUserVoted(entry);

    Uint8List? imageBytes;
    if (entry['coverImage'] != null) {
      try {
        imageBytes = base64Decode(entry['coverImage']);
      } catch (_) {}
    }

    final votesCount = (entry['votes'] as List?)?.length ?? 0;
    final topLabel = switch (index) {
      0 => 'Top 1',
      1 => 'Top 2',
      2 => 'Top 3',
      _ => null,
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DesignDetailPage(
              designData: entry
                ..['contestId'] = contestId
                ..['startDate'] = widget.contest.startDate
                ..['endDate'] = widget.contest.endDate,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageBytes != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.memory(
                    imageBytes,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (topLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          topLabel,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    Text(
                      entry['title'] ?? 'Untitled',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Posted on: $postDate',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$votesCount Vote${votesCount == 1 ? '' : 's'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: isOnGoing ? () => _voteEntry(entry['id'], hasVoted) : null,
                          icon: Icon(hasVoted ? Icons.how_to_vote : Icons.how_to_vote_outlined),
                          label: Text(hasVoted ? 'Unvote' : 'Vote'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOnGoing
                                ? (hasVoted ? Colors.red : const Color(0xFF689f77))
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
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
    return Scaffold(
      appBar: TheAppBar(content: widget.contest.title,style: 2),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.contest.coverImagePath.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(widget.contest.coverImagePath),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(widget.contest.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('dd MMM yyyy').format(widget.contest.startDate)} - ${DateFormat('dd MMM yyyy').format(widget.contest.endDate)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child:
                    ElevatedButton(
                      onPressed: isOnGoing
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UploadDesignPage(contestId: contestId)),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF689f77),
                      ),
                      child: const Text('Upload Your Design', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const Divider(thickness: 1, height: 32),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('contests')
                .doc(contestId)
                .collection('entries')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              final data = snapshot.data!.docs.map((doc) {
                final entry = doc.data() as Map<String, dynamic>;
                entry['id'] = doc.id;
                return entry;
              }).toList();

              data.sort((a, b) => (b['votes']?.length ?? 0).compareTo(a['votes']?.length ?? 0));

              if (data.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text('No entries found.')));
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildEntryCard(data[index], index),
                  childCount: data.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
