import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:velora2/Hire/Widgets/designer_card.dart';

class FilteredTab extends StatefulWidget {
  final String searchQuery;
  final String? designCategory;

  const FilteredTab({
    super.key,
    required this.searchQuery,
    required this.designCategory,
  });

  @override
  State<FilteredTab> createState() => _FilteredTabState();
}

class _FilteredTabState extends State<FilteredTab> {
  List<Map<String, dynamic>> _designers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDesigners();
  }

  Future<void> _fetchDesigners() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('designers').get();
      final designers = snapshot.docs.map((doc) {
        return {
          'doc': doc,
          'data': doc.data()
        };
      }).toList();

      if (mounted) {
        setState(() {
          _designers = designers;
          _isLoading = false;
        });
      }
    } catch (e, st) {
      debugPrint('Error fetching designers: $e\n$st');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDesigners = _designers.where((designer) {
      final data = designer['data'] as Map<String, dynamic>;
      final matchesCategory = widget.designCategory == null || widget.designCategory == data['category'];
      final matchesSearch = widget.searchQuery.isEmpty ||
          (data['name'] ?? '').toString().toLowerCase().contains(widget.searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    else if (filteredDesigners.isEmpty) {
      return const Center(child: Text('No designers found.'));
    }
    else {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: filteredDesigners.length,
        itemBuilder: (context, index) {
          final designer = filteredDesigners[index];
          return DesignerCard(data: designer['data'], doc: designer['doc']);
        },
      );
    }
  }
}
