import 'package:flutter/material.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/the_app_bar.dart';
import 'upload_project_screen.dart';
import 'project_details_screen.dart';
import 'search_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
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

  // Temporary state for likes and comments
  final Map<int, bool> _likedProjects = {};
  final Map<int, int> _commentCounts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: 'Explore'),
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
          Expanded(
            child: _buildShotsGrid(),
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

  Widget _buildShotsGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // Replace with actual data count
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildShotCard(index),
        );
      },
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