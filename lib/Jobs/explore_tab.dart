import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Jobs/detail_page.dart';
import '../Services/LocalDatabase/jobs.dart';
import '../models/jobs.dart';
import 'Widgets/job_card.dart';

class ExploreTab extends StatefulWidget {
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
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  List<Map<String, dynamic>> _jobs = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalJobs();
    _fetchAndSyncCloudJobs();
  }

  Future<void> _loadLocalJobs() async {
    try {
      final localJobs = await LocalDatabase.getJobs();
      final jobMaps = localJobs.map((job) {
        return {
          'doc': null, // No Firestore DocumentSnapshot
          'data': {
            'jobTitle': job.jobTitle,
            'comName': job.comName,
            'jobLocation': job.jobLocation,
            'jobCat': job.jobCat,
            'jobImage': job.jobImage,
            'deadline': job.deadline?.toIso8601String(),
            'state': '', // Optional: if you want to simulate state/country
            'country': '',
          }
        };
      }).toList();

      if (mounted) {
        setState(() {
          _jobs = jobMaps;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Local DB error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAndSyncCloudJobs() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('jobs').get();
      final jobs = snapshot.docs.map((doc) {
        return {
          'doc': doc,
          'data': doc.data(),
        };
      }).toList();

      if (mounted) {
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e, st) {
      debugPrint('Error fetching jobs: $e\n$st');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _jobs.where((jobMap) {
      final data = jobMap['data'] as Map<String, dynamic>;
      final matchesSearch = widget.searchQuery.isEmpty || (data['jobTitle'] ?? '').toLowerCase().contains(widget.searchQuery.toLowerCase());
      final matchesCat = widget.jobCatFilter == null || widget.jobCatFilter == data['jobCat'];
      final matchesType = true; // Add if needed
      final matchesAca = true; // Add if needed
      return matchesSearch && matchesCat && matchesType && matchesAca;
    }).toList();


    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredJobs.isEmpty) {
      return const Center(child: Text('No jobs found.'));
    }

    return ListView.builder(
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final jobMap = filteredJobs[index];
        final data = jobMap['data'] as Map<String, dynamic>;
        final doc = jobMap['doc'] as DocumentSnapshot?;
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: JobCard(
            data: data,
            doc: doc,
            isExpired: data['deadline'] != null &&
                DateTime.tryParse(data['deadline']) != null &&
                DateTime.now().isAfter(DateTime.parse(data['deadline'])),
          ), // You need to build this factory constructor or helper
        );
      },
    );
  }
}
