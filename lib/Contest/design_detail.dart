import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';

class DesignDetailPage extends StatefulWidget {
  final Map<String, dynamic> designData;

  const DesignDetailPage({super.key, required this.designData});

  @override
  State<DesignDetailPage> createState() => _DesignDetailPageState();
}

class _DesignDetailPageState extends State<DesignDetailPage> {
  late List<String> images;
  int _currentIndex = 0;
  late String contestId;
  late String entryId;
  late bool isOnGoing;
  String currentUserEmail = '';
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    images = List<String>.from(widget.designData['images'] ?? []);
    contestId = widget.designData['contestId'] ?? '';
    entryId = widget.designData['id'];

    final start = widget.designData['startDate'] as DateTime;
    final end = widget.designData['endDate'] as DateTime;
    final now = DateTime.now();
    isOnGoing = now.isAfter(start) && now.isBefore(end);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserEmail = user.email!;
    }
  }

  Future<void> _toggleVote(List<dynamic> votes) async {
    final ref = FirebaseFirestore.instance
        .collection('contests')
        .doc(contestId)
        .collection('entries')
        .doc(entryId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final List currentVotes = List.from(snap['votes'] ?? []);

      if (currentVotes.contains(currentUserEmail)) {
        currentVotes.remove(currentUserEmail);
      } else {
        currentVotes.add(currentUserEmail);
      }

      tx.update(ref, {'votes': currentVotes});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: "Design Detail", style: 2),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('contests')
            .doc(contestId)
            .collection('entries')
            .doc(entryId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final title = data['title'] ?? '';
          final concept = data['concept'] ?? '';
          final email = data['createdBy'] ?? '';
          final List votes = data['votes'] ?? [];
          final voteCount = votes.length;
          final hasVoted = votes.contains(currentUserEmail);

          return Column(
            children: [
              if (images.isNotEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        width: 200,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
              else
                const Expanded(child: Center(child: Text("No images available"))),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text("Image ${_currentIndex + 1} of ${images.length}", style: const TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(height: 10),
                    Text("Uploader: $email", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Concept:", style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(concept),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.how_to_vote, color: Colors.green),
                            const SizedBox(width: 6),
                            Text("$voteCount vote${voteCount == 1 ? '' : 's'}"),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: isOnGoing ? () => _toggleVote(votes) : null,
                          icon: Icon(hasVoted ? Icons.how_to_vote : Icons.how_to_vote_outlined),
                          label: Text(hasVoted ? "Unvote" : "Vote"),
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
          );
        },
      ),
    );
  }
}
