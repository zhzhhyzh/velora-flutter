import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:velora2/Hire/Widgets/designer_card.dart';

import '../Models/designers.dart';
import '../Services/LocalDatabase/designers.dart';

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
    // _fetchDesigners();
    _loadLocalDesigners();
    _fetchAndSyncCloudDesigners();
  }

  // Future<void> _fetchDesigners() async {
  //   try {
  //     final snapshot = await FirebaseFirestore.instance.collection('designers').get();
  //     final designers = snapshot.docs.map((doc) {
  //       return {
  //         'doc': doc,
  //         'data': doc.data()
  //       };
  //     }).toList();
  //
  //     if (mounted) {
  //       setState(() {
  //         _designers = designers;
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e, st) {
  //     debugPrint('Error fetching designers: $e\n$st');
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  Future<void> _loadLocalDesigners() async {
    try {
      final localDesigners = await LocalDatabase.getDesigners();
      final designerMaps = localDesigners.map((designer) {
        return {
          'doc': null,
          'data': {
            'name': designer.name,
            'category': designer.category,
            'contact': designer.contact,
            'country': designer.country,
            'desc': designer.desc,
            'designerId': designer.designerId,
            'email': designer.email,
            'profileImg': designer.profileImg,
            'rate': designer.rate,
            'slogan': designer.slogan,
            'state': designer.state,
          }
        };
      }).toList();

      if (mounted) {
        setState(() {
          _designers = designerMaps;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading local designers: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAndSyncCloudDesigners() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('designers').get();
      final designers = snapshot.docs.map((doc) {
        return {
          'doc': doc,
          'data': doc.data(),
        };
      }).toList();

      await _saveCloudDesignersLocally(designers);

      if (mounted) {
        setState(() {
          _designers = designers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching designers from Firestore: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCloudDesignersLocally(List<Map<String, dynamic>> cloudDesigners) async {
    try {
      final localDesigners = cloudDesigners.map((designerMap) {
        final data = designerMap['data'] as Map<String, dynamic>;

        // Generate unique ID if not present
        final id = designerMap['doc']?.id ?? 'designer_${DateTime.now().millisecondsSinceEpoch}';

        return DesignerModel(
          id: id,
          name: data['name'] ?? '',
          category: data['category'] ?? '',
          contact: data['contact'] ?? '',
          country: data['country'] ?? '',
          desc: data['desc'] ?? '',
          designerId: data['designerId'] ?? '',
          email: data['email'] ?? '',
          profileImg: data['profileImg'] ?? '',
          rate: data['rate'] ?? '',
          slogan: data['slogan'] ?? '',
          state: data['state'] ?? '',
        );
      }).toList();

      // Save designers to the local database
      for (var designer in localDesigners) {
        await LocalDatabase.insertDesigner(designer);
      }
    } catch (e) {
      debugPrint('Error saving cloud designers locally: $e');
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
