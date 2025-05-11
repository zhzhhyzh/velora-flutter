import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../../Models/project_model.dart';
import '../../Models/comment_model.dart';
import 'explore_notification_handler.dart';
import 'explore_notification_settings.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ExploreNotificationHandler _notificationHandler = ExploreNotificationHandler();
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
      query = query.limit(50);
    }

    // Apply time frame filter
    if (timeFrame != null) {
      DateTime startDate;
      if (timeFrame == 'Custom Range' && customDateRange != null) {
        startDate = customDateRange.start.toUtc();
        final endDate = DateTime(
          customDateRange.end.year,
          customDateRange.end.month,
          customDateRange.end.day,
          23, 59, 59, 999
        ).toUtc();
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
                    .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      } else {
        DateTime now = DateTime.now();
        switch (timeFrame) {
          case 'Today':
            startDate = DateTime(now.year, now.month, now.day);
            break;
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

    // Apply sorting
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

    return query.snapshots().asyncMap((snapshot) async {
      try {
        final currentUserId = _auth.currentUser?.uid;
        final projects = await Future.wait(
          snapshot.docs.map((doc) async {
            final project = Project.fromFirestore(doc);
            
            // Get user details
            final userDoc = await _firestore.collection('users').doc(project.designerId).get();
            final userData = userDoc.data() ?? {};
            
            // Check if current user has liked the project
            bool isLiked = false;
            if (currentUserId != null) {
              final likeDoc = await _firestore
                  .collection('userLikes')
                  .doc('${currentUserId}_${project.id}')
                  .get();
              isLiked = likeDoc.exists;
            }
            
            // Add user details and like status to project
            return project.copyWith(
              designerName: userData['name'] ?? 'Unknown User',
              designerImage: userData['userImage'],
              isLiked: isLiked,
            );
          }),
        );
        
        // Apply search filtering if needed
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final searchLower = searchQuery.toLowerCase();
          return projects.where((project) {
            try {
              if (project.title.toLowerCase() == searchLower) {
                return true;
              }
              if (project.title.toLowerCase().contains(searchLower)) {
                return true;
              }
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
    print('📝 Starting addComment method'); // Basic log
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';
      print('👤 Current user ID: ${user.uid}'); // Basic log

      // Get user details (commenter)
      final userDetails = await getUserDetails(user.uid);
      print('🔍 Got user details: ${userDetails != null}'); // Basic log
      if (userDetails == null) throw 'User details not found';

      // Get project details for notification
      final projectDoc = await _firestore.collection(_projectsCollection).doc(projectId).get();
      print('📄 Got project document: ${projectDoc.exists}'); // Basic log
      final projectData = projectDoc.data();
      if (projectData == null) throw 'Project not found';

      // Get project creator's details
      final designerId = projectData['designerId'];
      print('🎨 Designer ID: $designerId'); // Basic log
      if (designerId == null) throw 'Project creator ID not found';

      final designerDetails = await getUserDetails(designerId);
      print('👥 Got designer details: ${designerDetails != null}'); // Basic log
      if (designerDetails == null) throw 'Project creator details not found';

      print('🔔 COMMENT NOTIFICATION DEBUG:');
      print('Commenter email: ${userDetails['email']}');
      print('Project creator email: ${designerDetails['email']}');

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
      print('💬 Comment added to database'); // Basic log

      // Increment comment count in project
      await _firestore.collection(_projectsCollection).doc(projectId).update({
        'commentCount': FieldValue.increment(1)
      });
      print('📊 Comment count updated'); // Basic log

      // Send notification to project creator
      if (designerDetails['email'] != null) {
        print('📧 Attempting to send notification to: ${designerDetails['email']}'); // Basic log
        try {
          // Check if user has enabled comment notifications
          final shouldSendNotification = await ExploreNotificationSettings.getCommentNotifications();
          if (shouldSendNotification) {
            await _notificationHandler.sendNotification(
              theEmail: designerDetails['email'],
              title: 'New Comment on Your Project',
              message: '${userDetails['name']} commented on your project "${projectData['title']}": $text',
            );
            print('✅ Comment notification sent to: ${designerDetails['email']}');
          } else {
            print('❌ Comment notifications disabled for user');
          }
        } catch (e) {
          print('❌ Error sending comment notification: $e');
        }
      } else {
        print('❌ Project creator email not found');
      }
    } catch (e) {
      print('❌ Error in addComment: $e');
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

        // Send notification for like
        final projectData = projectDoc.data();
        if (projectData != null) {
          final currentUserDetails = await getUserDetails(userId);
          if (currentUserDetails != null) {
            final designerId = projectData['designerId'];
            if (designerId != null) {
              final designerDetails = await getUserDetails(designerId);
              
              print('🔔 LIKE NOTIFICATION DEBUG:');
              print('Liker email: ${currentUserDetails['email']}');
              print('Project creator email: ${designerDetails?['email']}');
              
              if (designerDetails != null && designerDetails['email'] != null) {
                // Check if user has enabled like notifications
                final shouldSendNotification = await ExploreNotificationSettings.getLikeNotifications();
                if (shouldSendNotification) {
                  try {
                    await _notificationHandler.sendNotification(
                      theEmail: designerDetails['email'],
                      title: 'New Like',
                      message: '${currentUserDetails['name']} liked your project "${projectData['title']}"',
                    );
                    print('✅ Like notification sent to: ${designerDetails['email']}');
                  } catch (e) {
                    print('❌ Error sending like notification: $e');
                  }
                } else {
                  print('❌ Like notifications disabled for user');
                }
              } else {
                print('❌ Project creator email not found');
              }
            }
          }
        }
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
        'designerEmail': userDetails['email'],
      });

      // Get all followers
      final followersQuery = await _firestore
          .collection('userFollows')
          .where('targetUserId', isEqualTo: user.uid)
          .get();

      print('Found ${followersQuery.docs.length} followers'); // Debug log

      // Notify each follower
      for (var followerDoc in followersQuery.docs) {
        try {
          final followerData = followerDoc.data();
          final followerId = followerData['followerId'];
          
          print('Processing follower: $followerId'); // Debug log
          
          if (followerId != null) {
            final followerDetails = await getUserDetails(followerId);
            
            print('Follower details: ${followerDetails != null ? 'Found' : 'Not found'}'); // Debug log
            
            if (followerDetails != null && followerDetails['email'] != null) {
              print('Sending notification to: ${followerDetails['email']}'); // Debug log
              
              // Check if user has enabled project notifications
              final shouldSendNotification = await ExploreNotificationSettings.getProjectNotifications();
              if (shouldSendNotification) {
                await _notificationHandler.sendNotification(
                  theEmail: followerDetails['email'],
                  title: 'New Project from ${userDetails['name']}',
                  message: '${userDetails['name']} just posted a new project: $title',
                );
                print('Notification sent successfully'); // Debug log
              } else {
                print('❌ Project notifications disabled for user');
              }
            }
          }
        } catch (e) {
          print('Error sending notification to follower: $e'); // Debug log
          // Continue with next follower even if one fails
          continue;
        }
      }

      return docRef.id;
    } catch (e) {
      print('Error in uploadProject: $e'); // Debug log
      throw 'Failed to upload project: $e';
    }
  }

  Future<void> updateProject({
    required String projectId,
    required String title,
    required String description,
    required String category,
    required String imageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      // Get the project document
      final projectRef = _firestore.collection(_projectsCollection).doc(projectId);
      final projectDoc = await projectRef.get();

      if (!projectDoc.exists) {
        throw 'Project not found';
      }

      // Verify that the current user is the project owner
      final projectData = projectDoc.data();
      if (projectData == null || projectData['designerId'] != user.uid) {
        throw 'You do not have permission to edit this project';
      }

      // Update the project
      await projectRef.update({
        'title': title,
        'description': description,
        'category': category,
        'imageUrl': imageUrl,
        'title_lower': title.toLowerCase(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update project: $e';
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

  // Get all projects by a specific user
  Stream<List<Project>> getUserProjects(String userId) {
    return _firestore
        .collection(_projectsCollection)
        .where('designerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList();
    });
  }

  // Follow/Unfollow a user
  Future<void> toggleFollow(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw 'User not logged in';

    final userFollowsRef = _firestore
        .collection('userFollows')
        .doc('${currentUser.uid}_$targetUserId');

    final userDoc = await userFollowsRef.get();

    if (userDoc.exists) {
      // Unfollow
      await userFollowsRef.delete();
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.increment(-1)
      });
    } else {
      // Follow
      await userFollowsRef.set({
        'followerId': currentUser.uid,
        'targetUserId': targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.increment(1)
      });

      // Get both users' details
      final currentUserDetails = await getUserDetails(currentUser.uid);
      final targetUserDetails = await getUserDetails(targetUserId);
      
      print('🔔 FOLLOW NOTIFICATION DEBUG:');
      print('Current user (follower) email: ${currentUserDetails?['email']}');
      print('Target user (being followed) email: ${targetUserDetails?['email']}');
      
      if (currentUserDetails != null && targetUserDetails != null && targetUserDetails['email'] != null) {
        try {
          // Check if user has enabled follow notifications
          final shouldSendNotification = await ExploreNotificationSettings.getFollowNotifications();
          if (shouldSendNotification) {
            await _notificationHandler.sendNotification(
              theEmail: targetUserDetails['email'],
              title: 'New Follower',
              message: '${currentUserDetails['name']} started following you!',
            );
            print('✅ Follow notification sent to: ${targetUserDetails['email']}');
          } else {
            print('❌ Follow notifications disabled for user');
          }
        } catch (e) {
          print('❌ Error sending follow notification: $e');
        }
      } else {
        print('❌ Missing user details for notification');
      }
    }
  }

  // Check if current user is following a user
  Future<bool> isFollowing(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final doc = await _firestore
        .collection('userFollows')
        .doc('${currentUser.uid}_$targetUserId')
        .get();
    
    return doc.exists;
  }

  // Get follower count
  Future<int> getFollowerCount(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['followers'] ?? 0;
  }

  // Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      // Get the project document
      final projectRef = _firestore.collection(_projectsCollection).doc(projectId);
      final projectDoc = await projectRef.get();

      if (!projectDoc.exists) {
        throw 'Project not found';
      }

      // Verify that the current user is the project owner
      final projectData = projectDoc.data();
      if (projectData == null || projectData['designerId'] != user.uid) {
        throw 'You do not have permission to delete this project';
      }

      // Delete all comments associated with the project
      final commentsQuery = await _firestore
          .collection('comments')
          .where('projectId', isEqualTo: projectId)
          .get();
      
      for (var doc in commentsQuery.docs) {
        await doc.reference.delete();
      }

      // Delete all likes associated with the project
      final likesQuery = await _firestore
          .collection('userLikes')
          .where('projectId', isEqualTo: projectId)
          .get();
      
      for (var doc in likesQuery.docs) {
        await doc.reference.delete();
      }

      // Delete the project
      await projectRef.delete();
    } catch (e) {
      throw 'Failed to delete project: $e';
    }
  }
} 