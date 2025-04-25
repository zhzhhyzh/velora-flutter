import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velora2/Jobs/create_job.dart';
import 'package:velora2/Services/global_dropdown.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';
import 'detail_page.dart';

class AllJobsScreen extends StatefulWidget {
  const AllJobsScreen({super.key});

  @override
  State<AllJobsScreen> createState() => _AllJobsScreenState();
}

class _AllJobsScreenState extends State<AllJobsScreen> {
  String? jobCatFilter;
  String? jobTypeFilter;
  String? minAcaFilter;
  String _searchQuery = '';
  String selectedTab = 'Explore';

  final user = FirebaseAuth.instance.currentUser;

  int _activeFilterCount() {
    int count = 0;
    if (jobCatFilter != null) count++;
    if (jobTypeFilter != null) count++;
    if (minAcaFilter != null) count++;
    return count;
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.black54,
      hintStyle: const TextStyle(color: Color(0xFFb9b9b9)),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.filter_list_rounded, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Filter Jobs', style: TextStyle(color: Colors.black)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildDropdown(
                  label: 'Job Category',
                  value: jobCatFilter,
                  items: GlobalDD.jobCategoryList,
                  onChanged: (val) => setState(() => jobCatFilter = val),
                ),
                _buildDropdown(
                  label: 'Job Type',
                  value: jobTypeFilter,
                  items: GlobalDD.jobTypeList,
                  onChanged: (val) => setState(() => jobTypeFilter = val),
                ),
                _buildDropdown(
                  label: 'Min Academic Level',
                  value: minAcaFilter,
                  items: GlobalDD.academicLists,
                  onChanged: (val) => setState(() => minAcaFilter = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  jobCatFilter = null;
                  jobTypeFilter = null;
                  minAcaFilter = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF689f77),
              ),
              child: const Text('Apply', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: items.contains(value) ? value : null,
        hint: Text("Select $label", style: TextStyle(color: Color(0xFFD9D9D9))),
        decoration: _dropdownDecoration(),
        dropdownColor: Colors.black87,
        iconEnabledColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Stream<QuerySnapshot> _getStream() {
    if (selectedTab == 'Applied') {
      return FirebaseFirestore.instance
          .collection('userjobs')
          .where('userEmail', isEqualTo: user?.email)
          .snapshots();
    } else if (selectedTab == 'Posted') {
      return FirebaseFirestore.instance
          .collection('jobs')
          .where('email', isEqualTo: user?.email)
          .snapshots();
    }
    return FirebaseFirestore.instance.collection('jobs').snapshots();
  }

  void _onJobTap(DocumentSnapshot job) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final jobEmail = job['email'];

    if (currentUser != null && currentUser.email == jobEmail) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
      );
    }
  }

  Widget _buildJobTile(Map<String, dynamic> data, DocumentSnapshot doc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _onJobTap(doc),
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
                  child:
                      data['jobImage'] != null
                          ? Image.memory(
                            base64Decode(data['jobImage']),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                const Icon(Icons.image_not_supported, color: Colors.grey),
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
                        (data['comName'] ?? 'COMPANY NAME').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['jobTitle'] ?? 'Job Title',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data['jobLocation'] ?? 'Job Location',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      data['jobCat'] ?? 'Job Category',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildJobCard(Map<String, dynamic> data, DocumentSnapshot job,{bool isExpired = false}) {
    final location = [
      data['country']?.toString(),
      data['state']?.toString(),
    ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _onJobTap(job),
        child: Container(
          decoration: BoxDecoration(
            color: isExpired ? Colors.red.shade100 : Colors.white,
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
                  child:
                      data['jobImage'] != null
                          ? Image.memory(
                            base64Decode(data['jobImage']),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
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
                        (data['comName'] ?? 'COMPANY NAME').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['jobTitle'] ?? 'Job Title',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location.isNotEmpty ? location : 'Job Location',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      data['jobCat'] ?? 'Job Category',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: 'Job Board'),
      body: Center(
        child: Column(
          children: [
            // 🔍 Search Bar with filter
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  suffixIcon: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.filter_list_rounded,
                          color: Colors.black,
                        ),
                        onPressed: _showFilterDialog,
                      ),
                      if (_activeFilterCount() > 0)
                        Positioned(
                          right: 4,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${_activeFilterCount()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
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
                onChanged:
                    (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    ['Applied', 'Explore', 'Posted'].map((tab) {
                      final isSelected = selectedTab == tab;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () => setState(() => selectedTab = tab),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isSelected ? Color(0xff689f77) : Colors.grey,
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

            // 🧾 Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Your Post",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CreateJob()),
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF689f77),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                      return const Center(child: Text("No jobs found."));
                    if (snapshot.hasError) {
                      return Center(child: Text("An error occurred: ${snapshot
                          .error}"));
                    }

                    final appliedDocs = snapshot.data!.docs;
                    final uniqueJobIds = <String>{};

                    // Collect unique job IDs
                    for (final doc in appliedDocs) {
                      final jobId = (doc.data() as Map<String,
                          dynamic>)['jobId'];
                      if (jobId != null) {
                        uniqueJobIds.add(jobId);
                      }
                    }

                    // Fetch job documents for unique job IDs
                    return FutureBuilder<List<DocumentSnapshot>>(
                      future: Future.wait(uniqueJobIds.map((jobId) {
                        return FirebaseFirestore.instance.collection('jobs')
                            .doc(jobId)
                            .get();
                      })),
                      builder: (context, jobSnapshots) {
                        if (jobSnapshots.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (jobSnapshots.hasError) {
                          return Center(child: Text(
                              "An error occurred: ${jobSnapshots.error}"));
                        }

                        final jobDocs = jobSnapshots.data!;
                        final filteredJobs = jobDocs.where((doc) {
                          if (!doc.exists) return false;
                          final data = doc.data() as Map<String, dynamic>;
                          final deadline = data['deadline'];
                          DateTime? deadlineDate;

                          if (deadline is Timestamp) {
                            deadlineDate = deadline.toDate();
                          } else if (deadline is String) {
                            deadlineDate = DateTime.tryParse(deadline);
                          }

                          final isExpired = deadlineDate != null &&
                              DateTime.now().isAfter(deadlineDate);

                          final matchesSearch = _searchQuery.isEmpty ||
                              (data['jobTitle'] ?? '').toString()
                                  .toLowerCase()
                                  .contains(_searchQuery);
                          final matchesCategory = jobCatFilter == null ||
                              jobCatFilter == data['jobCat'];
                          final matchesType = jobTypeFilter == null ||
                              jobTypeFilter == data['jobType'];
                          final matchesAca = minAcaFilter == null ||
                              minAcaFilter == data['minAca'];

                          return !isExpired && matchesSearch &&
                              matchesCategory && matchesType && matchesAca;
                        }).toList();

                        return ListView.builder(
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) {
                            final doc = filteredJobs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            // If tab is Applied, fetch job from jobs collection
                            if (selectedTab == 'Applied') {
                              final jobId =
                              (doc.data() as Map<String, dynamic>)['jobId'];

                              return FutureBuilder<DocumentSnapshot>(
                                future:
                                FirebaseFirestore.instance
                                    .collection('jobs')
                                    .doc(jobId)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {
                                    return const SizedBox(); // or an error widget
                                  }

                                  final jobDoc = snapshot.data!;
                                  final jobData =
                                  jobDoc.data() as Map<String, dynamic>;
                                  return _buildJobCard(jobData, jobDoc);
                                },
                              );
                            } else if(selectedTab == 'Explore'){
                              final data = doc.data() as Map<String, dynamic>;
                              return _buildJobCard(data, doc);
                            }
                            else {
                              final doc = filteredJobs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final deadline = data['deadline'];
                              DateTime? deadlineDate;

                              if (deadline is Timestamp) {
                                deadlineDate = deadline.toDate();
                              } else if (deadline is String) {
                                deadlineDate = DateTime.tryParse(deadline);
                              }

                              final isExpired = deadlineDate != null && DateTime.now().isAfter(deadlineDate);
                              return _buildJobCard(data, doc, isExpired: isExpired);
                            }
                          },
                        );
                      },
                    );
                  }),
            ),
    )],
        ),
      ),
    );
  }
}
