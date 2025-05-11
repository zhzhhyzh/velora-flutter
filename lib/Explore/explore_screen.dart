import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';
import '../Models/project_model.dart';
import 'services/project_service.dart';
import 'upload_project_screen.dart';
import 'project_details_screen.dart';
import 'search_screen.dart';
import 'dart:convert';
import 'user_posts_screen.dart';
import 'notification_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ProjectService _projectService = ProjectService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int _selectedCategory = 0;
  String _selectedSortBy = 'Most Recent';
  String _selectedTimeFrame = 'All Time';
  DateTimeRange? _customDateRange;
  
  final List<String> _categories = [
    'All',
    'UI/UX',
    'Illustration',
    'Branding',
    'Animation',
    'Typography',
    'Web Design',
    'Mobile'
  ];

  final List<String> _sortOptions = [
    'Most Recent',
    'Most Popular',
    'Most Liked'
  ];

  final List<String> _timeFrames = [
    'All Time',
    'This Week',
    'This Month',
    'This Year',
    'Custom Range'
  ];

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF689f77),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              background: Colors.white,
              onBackground: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedTimeFrame = 'Custom Range';
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Projects',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _sortOptions.map((option) {
                    final isSelected = _selectedSortBy == option;
                    return ChoiceChip(
                      label: Text(option),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() => _selectedSortBy = option);
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: const Color(0xFF689f77),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Time Frame',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timeFrames.map((timeFrame) {
                    final isSelected = _selectedTimeFrame == timeFrame;
                    return ChoiceChip(
                      label: Text(timeFrame),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (timeFrame == 'Custom Range') {
                          Navigator.pop(context);
                          _selectDateRange();
                        } else {
                          setDialogState(() {
                            _selectedTimeFrame = timeFrame;
                            _customDateRange = null;
                          });
                        }
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: const Color(0xFF689f77),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                if (_customDateRange != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_customDateRange!.start.toString().split(' ')[0]} to ${_customDateRange!.end.toString().split(' ')[0]}',
                    style: const TextStyle(
                      color: Color(0xFF689f77),
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // The values are already updated in the dialog state
                        // Just need to trigger a rebuild of the main screen
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF689f77),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UploadProjectScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF689f77),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategories(),
          _buildFilterButton(),
          Expanded(
            child: _buildProjectsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                'Search for inspiration...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == _categories.indexOf(category);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () => setState(() => _selectedCategory = _categories.indexOf(category)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? const Color(0xFF689f77) : Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Active Filters: ${_selectedSortBy}${_selectedTimeFrame != 'All Time' ? ', $_selectedTimeFrame' : ''}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          TextButton.icon(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list, color: Color(0xFF689f77)),
            label: const Text(
              'Filter',
              style: TextStyle(
                color: Color(0xFF689f77),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    return StreamBuilder<List<Project>>(
      stream: _projectService.getProjects(
        category: _categories[_selectedCategory],
        sortBy: _selectedSortBy,
        timeFrame: _selectedTimeFrame,
        customDateRange: _customDateRange,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final projects = snapshot.data ?? [];

        if (projects.isEmpty) {
          return const Center(
            child: Text('No projects found'),
          );
        }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
          itemCount: projects.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
              child: _buildProjectCard(projects[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    return FutureBuilder<bool>(
      future: _projectService.hasUserLiked(project.id, _auth.currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        final isLiked = snapshot.data ?? false;

        return FutureBuilder<Map<String, dynamic>?>(
          future: _projectService.getUserDetails(project.designerId),
          builder: (context, userSnapshot) {
            final designerDetails = userSnapshot.data;

            return GestureDetector(
              onTap: () async {
                await _projectService.incrementViewCount(project.id);
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectDetailsScreen(project: project),
                    ),
                  );
                }
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.memory(
                        base64Decode(project.imageUrl),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserPostsScreen(
                                        userId: project.designerId,
                                        userName: project.designerName,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: const Color(0xFF689f77),
                                      child: project.designerImage != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.memory(
                                                base64Decode(project.designerImage!),
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Text(
                                              project.designerName[0].toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'By ${project.designerName}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${project.likes}',
                                style: TextStyle(
                                  color: isLiked ? Colors.red : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.remove_red_eye,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${project.views}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.comment,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${project.commentCount}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
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
            );
          },
        );
      },
    );
  }
} 