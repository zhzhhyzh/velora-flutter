import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Jobs/detail_page.dart';
import 'Widgets/job_card.dart';

class AppliedTab extends StatelessWidget {
  final String searchQuery;
  final String? jobCatFilter;
  final String? jobTypeFilter;
  final String? minAcaFilter;

  const AppliedTab({
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
          .collection('userjobs')
          .where('userEmail', isEqualTo: user?.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final jobIds = snapshot.data!.docs.map((doc) => (doc.data() as Map<String, dynamic>)['jobId']).toSet();

        if (jobIds.isEmpty) return const Center(child: Text('No applied jobs.'));

        return FutureBuilder<List<DocumentSnapshot>>(
          future: Future.wait(jobIds.map((id) => FirebaseFirestore.instance.collection('jobs').doc(id).get())),
          builder: (context, jobSnapshot) {
            if (!jobSnapshot.hasData) return const Center(child: CircularProgressIndicator());

            final jobs = jobSnapshot.data!.where((doc) {
              if (!doc.exists) return false;
              final data = doc.data() as Map<String, dynamic>;
              final matchesSearch = searchQuery.isEmpty || (data['jobTitle'] ?? '').toLowerCase().contains(searchQuery);
              final matchesCategory = jobCatFilter == null || jobCatFilter == data['jobCat'];
              final matchesType = jobTypeFilter == null || jobTypeFilter == data['jobType'];
              final matchesAca = minAcaFilter == null || minAcaFilter == data['minAca'];
              return matchesSearch && matchesCategory && matchesType && matchesAca;
            }).toList();

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
      },
    );
  }
}
