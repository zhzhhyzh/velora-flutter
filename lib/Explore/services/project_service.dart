import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../../Models/project_model.dart';
import '../../Models/comment_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _projectsCollection = 'projects';
  final String _commentsCollection = 'comments';

  // Get all projects with optional filtering
  Stream<List<Project>> getProjects({
    String? category,
    String? sortBy,
    String? timeFrame,
    DateTimeRange? customDateRange,
    String? searchQuery,
  }) {
    Query query = _firestore.collection(_projectsCollection);

    // Apply category filter
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    // Apply search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final searchLower = searchQuery.toLowerCase();
      // Just limit, don't order here
      query = query.limit(50);
    }

    // Apply time frame filter
    if (timeFrame != null) {
      DateTime startDate;
      if (customDateRange != null) {
        startDate = customDateRange.start;
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
                    .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(customDateRange.end));
      } else {
        DateTime now = DateTime.now();
        switch (timeFrame) {
          case 'This Week':
            startDate = now.subtract(Duration(days: now.weekday - 1));
            break;
          case 'This Month':
            startDate = DateTime(now.year, now.month, 1);
            break;
          case 'This Year':
            startDate = DateTime(now.year, 1, 1);
            break;
          default:
            startDate = DateTime(1970);
        }
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
    }

    // Apply sorting (only one orderBy per field)
    switch (sortBy) {
      case 'Most Popular':
        query = query.orderBy('views', descending: true);
        break;
      case 'Most Liked':
        query = query.orderBy('likes', descending: true);
        break;
      case 'Most Recent':
      default:
        query = query.orderBy('createdAt', descending: true);
    }

    return query.snapshots().map((snapshot) {
      try {
        final projects = snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList();
        
        // If there's a search query, filter results to include exact matches and tag matches
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final searchLower = searchQuery.toLowerCase();
          return projects.where((project) {
            try {
              // Check for exact title match
              if (project.title.toLowerCase() == searchLower) {
                return true;
              }
              // Check for partial matches in title (any part of the title)
              if (project.title.toLowerCase().contains(searchLower)) {
                return true;
              }
              // Check for tag matches
              return project.tags.any((tag) => tag.toLowerCase().contains(searchLower));
            } catch (e) {
              print('Error filtering project: $e');
              return false;
            }
          }).toList();
        }
        
        return projects;
      } catch (e) {
        print('Error processing projects: $e');
        return [];
      }
    });
  }

  // Get comments for a project
  Stream<List<Comment>> getProjectComments(String projectId) {
    return _firestore
        .collection(_commentsCollection)
        .where('projectId', isEqualTo: projectId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
        });
  }

  // Add a comment to a project
  Future<void> addComment(String projectId, String text) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      // Get user details
      final userDetails = await getUserDetails(user.uid);
      if (userDetails == null) throw 'User details not found';

      // Create comment
      final comment = Comment(
        id: '',  // Firestore will generate this
        projectId: projectId,
        userId: user.uid,
        userName: userDetails['name'] ?? 'Unknown User',
        userImage: userDetails['userImage'],
        text: text,
        timestamp: DateTime.now(),
      );

      // Add comment to comments collection
      await _firestore.collection(_commentsCollection).add(comment.toMap());

      // Increment comment count in project
      await _firestore.collection(_projectsCollection).doc(projectId).update({
        'commentCount': FieldValue.increment(1)
      });
    } catch (e) {
      throw 'Failed to add comment: $e';
    }
  }

  // Delete a comment
  Future<void> deleteComment(String projectId, String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      // Get the comment to check ownership
      final commentDoc = await _firestore.collection(_commentsCollection).doc(commentId).get();
      if (!commentDoc.exists) throw 'Comment not found';
      
      final commentData = commentDoc.data() as Map<String, dynamic>;
      if (commentData['userId'] != user.uid) throw 'Not authorized to delete this comment';

      // Delete the comment
      await _firestore.collection(_commentsCollection).doc(commentId).delete();

      // Decrement comment count in project
      await _firestore.collection(_projectsCollection).doc(projectId).update({
        'commentCount': FieldValue.increment(-1)
      });
    } catch (e) {
      throw 'Failed to delete comment: $e';
    }
  }

  // Like a project
  Future<void> likeProject(String projectId, String userId) async {
    final projectRef = _firestore.collection(_projectsCollection).doc(projectId);
    final userLikesRef = _firestore.collection('userLikes').doc('${userId}_$projectId');

    await _firestore.runTransaction((transaction) async {
      final projectDoc = await transaction.get(projectRef);
      final userLikeDoc = await transaction.get(userLikesRef);

      if (!userLikeDoc.exists) {
        transaction.update(projectRef, {'likes': FieldValue.increment(1)});
        transaction.set(userLikesRef, {'liked': true, 'timestamp': FieldValue.serverTimestamp()});
      } else {
        transaction.update(projectRef, {'likes': FieldValue.increment(-1)});
        transaction.delete(userLikesRef);
      }
    });
  }

  // Increment view count
  Future<void> incrementViewCount(String projectId) async {
    await _firestore.collection(_projectsCollection).doc(projectId).update({
      'views': FieldValue.increment(1)
    });
  }

  // Check if user has liked a project
  Future<bool> hasUserLiked(String projectId, String userId) async {
    final doc = await _firestore.collection('userLikes').doc('${userId}_$projectId').get();
    return doc.exists;
  }

  // Get user details from users collection
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  // Get a single project by ID
  Future<Project> getProject(String projectId) async {
    try {
      final doc = await _firestore.collection(_projectsCollection).doc(projectId).get();
      if (!doc.exists) {
        throw Exception('Project not found');
      }
      return Project.fromFirestore(doc);
    } catch (e) {
      throw 'Failed to get project: $e';
    }
  }

  // Upload a new project
  Future<String> uploadProject({
    required String title,
    required String description,
    required String category,
    required File imageFile,
    List<String> tags = const [],
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      // Get user details
      final userDetails = await getUserDetails(user.uid);
      if (userDetails == null) throw 'User details not found';

      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Create project document
      final docRef = _firestore.collection(_projectsCollection).doc();
      final project = Project(
        id: docRef.id,
        title: title,
        description: description,
        designerId: user.uid,
        designerName: userDetails['name'] ?? 'Unknown User',
        category: category,
        imageUrl: base64Image,
        views: 0,
        likes: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
        tags: tags,
      );

      // Save project to Firestore with additional search fields
      await docRef.set({
        ...project.toMap(),
        'title_lower': title.toLowerCase(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Failed to upload project: $e';
    }
  }

  Stream<List<Project>> getTrendingProjects() {
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    
    return _firestore
        .collection('projects')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(threeDaysAgo))
        .where('views', isGreaterThan: 0)  // Only get projects with views > 0
        .orderBy('views', descending: true)  // Sort by views first
        .orderBy('createdAt', descending: true)  // Then by creation date
        .limit(10)  // Limit to 10 projects
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList();
        });
  }
} 