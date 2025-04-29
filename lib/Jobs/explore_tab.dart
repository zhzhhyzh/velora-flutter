import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Jobs/detail_page.dart';
import 'Widgets/job_card.dart';

class ExploreTab extends StatelessWidget {
  final String searchQuery;
  final String? jobCatFilter;
  final String? jobTypeFilter;
  final String? minAcaFilter;

  const ExploreTab({
    super.key,
    required this.searchQuery,
    required this.jobCatFilter,
    required this.jobTypeFilter,
    required this.minAcaFilter,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
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

        if (jobs.isEmpty) return const Center(child: Text('No jobs found.'));

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
