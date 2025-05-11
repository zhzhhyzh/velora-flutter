import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../Models/project_model.dart';
import '../Models/comment_model.dart';
import 'services/project_service.dart';
import 'services/comment_service.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'edit_project_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final ProjectService _projectService = ProjectService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;
  Map<String, dynamic>? _designerDetails;
  final CommentService _commentService = CommentService();
  bool _isPostingComment = false;
  Project? _currentProject;
  bool _isFollowing = false;
  int _followerCount = 0;

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
    _checkIfLiked();
    _loadDesignerDetails();
  }

  Future<void> _loadDesignerDetails() async {
    final details = await _projectService.getUserDetails(widget.project.designerId);
    if (mounted) {
      setState(() {
        _designerDetails = details;
      });
      _checkFollowStatus();
      _loadFollowerCount();
    }
  }

  Future<void> _checkIfLiked() async {
    if (_auth.currentUser != null) {
      final hasLiked = await _projectService.hasUserLiked(
        _currentProject!.id,
        _auth.currentUser!.uid,
      );
      if (mounted) {
        setState(() {
          _isLiked = hasLiked;
        });
      }
    }
  }

  Future<void> _checkFollowStatus() async {
    if (_auth.currentUser != null) {
      final isFollowing = await _projectService.isFollowing(widget.project.designerId);
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
    }
  }

  Future<void> _loadFollowerCount() async {
    final count = await _projectService.getFollowerCount(widget.project.designerId);
    if (mounted) {
      setState(() {
        _followerCount = count;
      });
    }
  }

  Future<void> _handleFollow() async {
    try {
      await _projectService.toggleFollow(widget.project.designerId);
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
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _refreshProjectData() async {
    try {
      final updatedProject = await _projectService.getProject(_currentProject!.id);
      if (mounted) {
        setState(() {
          _currentProject = updatedProject;
          _isLiked = false; // Reset liked state to be updated by _checkIfLiked
        });
        await _checkIfLiked(); // Update liked state with new data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing project data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    setState(() => _isPostingComment = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Must be logged in to comment');
      }

      await _projectService.addComment(
        _currentProject!.id,
        _commentController.text.trim(),
      );

      _commentController.clear();
      
      // Refresh project data after posting comment
      await _refreshProjectData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment posted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting comment: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPostingComment = false);
      }
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Must be logged in to delete comments');
      }

      await _commentService.deleteComment(
        commentId: comment.id,
        projectId: _currentProject!.id,
        userId: user.uid,
      );

      // Refresh project data after deleting comment
      await _refreshProjectData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting comment: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentProject == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshProjectData,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProjectInfo(),
                        const SizedBox(height: 24),
                        _buildDescription(),
                        const SizedBox(height: 24),
                        _buildComments(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCommentInput(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _currentProject!.title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (_auth.currentUser?.uid == _currentProject!.designerId) ...[
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProjectScreen(project: _currentProject!),
                ),
              );
              if (result == true) {
                _refreshProjectData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: () async {
            try {
              final directory = await getTemporaryDirectory();
              final file = File('${directory.path}/project_image.jpg');
              await file.writeAsBytes(base64Decode(_currentProject!.imageUrl));
              
              await Share.shareXFiles(
                [XFile(file.path)],
                text: 'Check out this amazing project in our app!\n\n'
                    'Title : ${_currentProject!.title}\n'
                    'Description : ${_currentProject!.description}\n\n'
                    'By :  ${_currentProject!.designerName}\n'
                    'Category: ${_currentProject!.category}\n\n'
                    'Download our app to view more creative projects and connect with talented designers!',
              );

              // Clean up the temporary file after sharing
              await file.delete();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error sharing: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _projectService.deleteProject(_currentProject!.id);
        if (mounted) {
          Navigator.pop(context); // Return to previous screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting project: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildProjectInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(_currentProject!.imageUrl),
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageView(
                          imageUrl: _currentProject!.imageUrl,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF689f77),
              child: _designerDetails != null && _designerDetails!['userImage'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      base64Decode(_designerDetails!['userImage']),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    (_designerDetails?['name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _designerDetails?['name'] ?? 'Unknown User',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _designerDetails?['position'] ?? _currentProject!.category,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
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
            if (_auth.currentUser?.uid != widget.project.designerId)
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
        const SizedBox(height: 16),
        Text(
          _currentProject!.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                if (_auth.currentUser != null) {
                  await _projectService.likeProject(
                    _currentProject!.id,
                    _auth.currentUser!.uid,
                  );
                  await _refreshProjectData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please login to like projects'),
                    ),
                  );
                }
              },
              icon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.red : Colors.grey,
              ),
            ),
            Text(
              '${_currentProject!.likes}',
              style: TextStyle(
                color: _isLiked ? Colors.red : Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.remove_red_eye, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${_currentProject!.views}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.comment, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${_currentProject!.commentCount}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                  const Text(
                    'Description',
                    style: TextStyle(
            fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
          _currentProject!.description,
          style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
      ],
    );
  }

  Widget _buildComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Comment>>(
          stream: _commentService.getCommentsStream(_currentProject!.id),
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

            final comments = snapshot.data ?? [];

            if (comments.isEmpty) {
              return const Center(
                child: Text(
                  'No comments yet. Be the first to comment!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final isCommentOwner = _auth.currentUser?.uid == comment.userId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF689f77),
                        child: comment.userImage != null && comment.userImage!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                base64Decode(comment.userImage!),
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              (comment.userName.isNotEmpty ? comment.userName[0] : 'U').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  comment.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                if (isCommentOwner)
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 16),
                                    onPressed: () => _deleteComment(comment),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment.text,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
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
                                  ),
                                ),
                              ),
          const SizedBox(width: 8),
          _isPostingComment
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF689f77)),
                  onPressed: _postComment,
                            ),
                          ],
                        ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(
                base64Decode(imageUrl),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              ),
            ),
          ],
      ),
    );
  }
} 