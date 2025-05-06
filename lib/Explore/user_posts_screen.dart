import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../Models/project_model.dart';
import 'services/project_service.dart';
import 'project_details_screen.dart';

class UserPostsScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserPostsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> {
  final ProjectService _projectService = ProjectService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userDetails;
  bool _isFollowing = false;
  int _followerCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final details = await _projectService.getUserDetails(widget.userId);
    if (mounted) {
      setState(() {
        _userDetails = details;
        _isLoading = false;
      });
      _checkFollowStatus();
      _loadFollowerCount();
    }
  }

  Future<void> _checkFollowStatus() async {
    if (_auth.currentUser != null) {
      final isFollowing = await _projectService.isFollowing(widget.userId);
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
    }
  }

  Future<void> _loadFollowerCount() async {
    final count = await _projectService.getFollowerCount(widget.userId);
    if (mounted) {
      setState(() {
        _followerCount = count;
      });
    }
  }

  Future<void> _handleFollow() async {
    try {
      await _projectService.toggleFollow(widget.userId);
      await _checkFollowStatus();
      await _loadFollowerCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.userName}\'s Profile'),
        backgroundColor: const Color(0xFF689f77),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildUserProfile(),
          const Divider(height: 1),
          Expanded(
            child: _buildProjectsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF689f77),
                child: _userDetails != null && _userDetails!['userImage'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.memory(
                          base64Decode(_userDetails!['userImage']),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        (_userDetails?['name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userDetails?['name'] ?? 'Unknown User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userDetails?['position'] ?? 'No position specified',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_followerCount Followers',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_auth.currentUser?.uid != widget.userId)
                ElevatedButton(
                  onPressed: _handleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing ? Colors.grey : const Color(0xFF689f77),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(_isFollowing ? 'Following' : 'Follow'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    return StreamBuilder<List<Project>>(
      stream: _projectService.getUserProjects(widget.userId),
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
            child: Text(
              '${widget.userName} hasn\'t posted any projects yet.',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
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
  }
} 