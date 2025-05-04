import 'package:flutter/material.dart';
import 'project_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  int _selectedCategory = 0;
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

  // Filter state
  String _selectedSortBy = 'Most Recent';
  String _selectedTimeFrame = 'All Time';
  bool _showLikedOnly = false;
  final List<String> _sortOptions = [
    'Most Recent',
    'Most Popular',
    'Most Liked',
    'Most Viewed'
  ];
  final List<String> _timeFrames = [
    'All Time',
    'This Week',
    'This Month',
    'This Year'
  ];

  // Temporary state for likes and comments
  final Map<int, bool> _likedProjects = {};
  final Map<int, int> _commentCounts = {};

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
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
                        setState(() => _selectedSortBy = option);
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
                        setState(() => _selectedTimeFrame = timeFrame);
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
                Row(
                  children: [
                    Checkbox(
                      value: _showLikedOnly,
                      onChanged: (value) {
                        setState(() => _showLikedOnly = value ?? false);
                      },
                      activeColor: const Color(0xFF689f77),
                    ),
                    const Text(
                      'Show only liked projects',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Apply filters
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for inspiration...',
            filled: true,
            fillColor: Colors.grey.shade200,
            prefixIcon: const Icon(Icons.search, color: Colors.black),
            suffixIcon: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black),
              onPressed: _showFilterDialog,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildSearchSuggestions()
          : _buildSearchResults(),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trending Topics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTrendingTopic('UI Design Trends 2024'),
                _buildTrendingTopic('Minimalist Design'),
                _buildTrendingTopic('Color Palettes'),
                _buildTrendingTopic('Mobile App UI'),
                _buildTrendingTopic('Web Design'),
                _buildTrendingTopic('Typography'),
                _buildTrendingTopic('Branding'),
                _buildTrendingTopic('Animation'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Clear search history
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(
                    Icons.history,
                    color: Colors.grey,
                  ),
                  title: Text(
                    'Recent search ${index + 1}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      // TODO: Remove from history
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // Replace with actual search results
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildShotCard(index),
        );
      },
    );
  }

  Widget _buildTrendingTopic(String topic) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.trending_up,
            size: 16,
            color: Color(0xFF689f77),
          ),
          const SizedBox(width: 4),
          Text(
            topic,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildShotCard(int index) {
    final isLiked = _likedProjects[index] ?? false;
    final commentCount = _commentCounts[index] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsScreen(
              title: 'Project Title',
              designerName: 'Designer Name',
              description: 'This is a sample project description that explains what the project is about and its key features.',
              category: 'UI/UX',
              views: 2500,
              likes: 1200,
              comments: [
                'This is an amazing project!',
                'Great work on the design!',
                'Love the color scheme!',
                'Very inspiring work!',
                'The UI is so clean and modern!',
              ],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Title',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF689f77),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: const Text(
                          'Designer Name',
                          style: TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '2.5k',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _likedProjects[index] = !isLiked;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isLiked ? const Color(0xFF689f77) : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '1.2k',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => _buildCommentsDialog(index),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.comment_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Comment',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement share functionality
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.share_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              const Text(
                                'Share',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
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
  }

  Widget _buildCommentsDialog(int projectIndex) {
    return Dialog(
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
                  'Comments',
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
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with actual comments
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF689f77),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'User Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'This is a sample comment for the project.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '2 hours ago',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF689f77)),
                  onPressed: () {
                    // TODO: Implement comment submission
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 