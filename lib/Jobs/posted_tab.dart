import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Jobs/detail_page.dart';
import 'Widgets/job_card.dart';

class PostedTab extends StatelessWidget {
  final String searchQuery;
  final String? jobCatFilter;
  final String? jobTypeFilter;
  final String? minAcaFilter;

  const PostedTab({
    super.key,
    required this.searchQuery,
    required this.jobCatFilter,
    required this.jobTypeFilter,
    required this.minAcaFilter,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('email', isEqualTo: user?.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final jobs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final matchesSearch = searchQuery.isEmpty || (data['jobTitle'] ?? '').toLowerCase().contains(searchQuery);
          final matchesCategory = jobCatFilter == null || jobCatFilter == data['jobCat'];
          final matchesType = jobTypeFilter == null || jobTypeFilter == data['jobType'];
          final matchesAca = minAcaFilter == null || minAcaFilter == data['minAca'];
          return matchesSearch && matchesCategory && matchesType && matchesAca;
        }).toList();
        if (jobs.isEmpty)  return const Center(child: Text('No Posted jobs.'));

        return ListView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final doc = jobs[index];
            final data = doc.data() as Map<String, dynamic>;
            return Padding(padding: EdgeInsets.only(top: 8.0),child: JobCard(data: data, doc: doc));
          },
        );
      },
    );
  }
}
