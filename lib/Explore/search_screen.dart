import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../Models/project_model.dart';
import 'services/project_service.dart';
import '../Services/localdatabase/explore_search_history.dart';
import 'project_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProjectService _projectService = ProjectService();
  final ExploreSearchHistory _searchHistoryDb = ExploreSearchHistory();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  String _selectedSortBy = 'Most Recent';
  String _selectedTimeFrame = 'All Time';
  DateTimeRange? _customDateRange;
  int _selectedCategory = 0;
  bool _isSearching = false;
  List<String> _recentSearches = [];
  
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

  final List<String> _trendingTopics = [
    'UI Design Trends 2024',
    'Minimalist Design',
    'Color Palettes',
    'Mobile App UI',
    'Web Design',
    'Typography',
    'Branding',
    'Animation',
    'Design Systems',
    'User Experience'
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

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final searches = await _searchHistoryDb.getRecentSearches();
    setState(() {
      _recentSearches = searches;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                      'Filter Results',
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
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final isSelected = _selectedCategory == index;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() => _selectedCategory = index);
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
                        // Trigger rebuild with new filter values
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

  void _onSearchSubmitted(String value) async {
    if (value.trim().isNotEmpty) {
      await _searchHistoryDb.addSearchQuery(value.trim());
      await _loadRecentSearches();
    }
    setState(() {
      _searchQuery = value;
      _isSearching = true;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _isSearching = value.isNotEmpty;
    });
  }

  Future<void> _clearSearchHistory() async {
    await _searchHistoryDb.clearSearchHistory();
    setState(() {
      _recentSearches = [];
    });
  }

  Future<void> _removeSearchQuery(String query) async {
    await _searchHistoryDb.removeSearchQuery(query);
    await _loadRecentSearches();
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for inspiration...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
            ),
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.filter_list, color: Color(0xFF689f77)),
              onPressed: _showFilterDialog,
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingTopics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Trending Projects',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        StreamBuilder<List<Project>>(
          stream: _projectService.getTrendingProjects(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading trending projects'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final projects = snapshot.data!;
            if (projects.isEmpty) {
              return const Center(child: Text('No trending projects found'));
            }

            return SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        _searchController.text = project.title;
                        _onSearchSubmitted(project.title);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              project.title,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${project.views} views)',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_recentSearches.isNotEmpty)
                TextButton(
                  onPressed: _clearSearchHistory,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: Color(0xFF689f77),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_recentSearches.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No recent searches',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(_recentSearches[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                  onPressed: () => _removeSearchQuery(_recentSearches[index]),
                ),
                onTap: () {
                  _searchController.text = _recentSearches[index];
                  _onSearchSubmitted(_recentSearches[index]);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendingTopics(),
          const Divider(height: 32),
          _buildRecentSearches(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchBar(),
      ),
      body: _isSearching
          ? Column(
              children: [
                if (_searchQuery.isNotEmpty || _selectedCategory != 0 || _selectedTimeFrame != 'All Time')
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Active Filters: ${_selectedCategory != 0 ? _categories[_selectedCategory] : ''}${_selectedSortBy != 'Most Recent' ? ', $_selectedSortBy' : ''}${_selectedTimeFrame != 'All Time' ? ', $_selectedTimeFrame' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = 0;
                              _selectedSortBy = 'Most Recent';
                              _selectedTimeFrame = 'All Time';
                              _customDateRange = null;
                              _searchController.clear();
                              _isSearching = false;
                            });
                          },
                          child: const Text(
                    'Clear All',
                    style: TextStyle(
                              color: Color(0xFF689f77),
                              fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
                  ),
                Expanded(
                  child: _buildSearchResults(),
                ),
              ],
            )
          : _buildSearchSuggestions(),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Project>>(
      stream: _projectService.getProjects(
        category: _selectedCategory == 0 ? null : _categories[_selectedCategory],
        sortBy: _selectedSortBy,
        timeFrame: _selectedTimeFrame,
        customDateRange: _customDateRange,
        searchQuery: _searchQuery,
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No projects found'
                      : 'No results for "$_searchQuery"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
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
                              CircleAvatar(
                        radius: 12,
                                backgroundColor: const Color(0xFF689f77),
                                child: designerDetails != null && designerDetails!['userImage'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(
                                          base64Decode(designerDetails!['userImage']),
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Text(
                                        (designerDetails?['name'] ?? 'U')[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                                child: Text(
                                  'By ${designerDetails?['name'] ?? 'Unknown User'}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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