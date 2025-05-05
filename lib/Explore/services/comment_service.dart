import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get comments stream for a specific project
  Stream<List<Comment>> getCommentsStream(String projectId) {
    return _firestore
        .collection('comments')
        .where('projectId', isEqualTo: projectId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final comments = await Future.wait(
        snapshot.docs.map((doc) async {
          final commentData = doc.data();
          final userDoc = await _firestore
              .collection('users')
              .doc(commentData['userId'])
              .get();
          
          final userData = userDoc.data() ?? {};
          return Comment(
            id: doc.id,
            projectId: commentData['projectId'],
            userId: commentData['userId'],
            userName: userData['name'] ?? 'Anonymous',
            userImage: userData['userImage'],
            text: commentData['text'],
            timestamp: (commentData['timestamp'] as Timestamp).toDate(),
          );
        }),
      );
      return comments;
    });
  }

  // Add a new comment
  Future<void> addComment({
    required String projectId,
    required String userId,
    required String text,
  }) async {
    final batch = _firestore.batch();
    
    // Create the comment document
    final commentRef = _firestore.collection('comments').doc();
    final comment = {
      'projectId': projectId,
      'userId': userId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };
    
    batch.set(commentRef, comment);

    // Increment the project's comment count
    final projectRef = _firestore.collection('projects').doc(projectId);
    batch.update(projectRef, {
      'commentCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // Delete a comment
  Future<void> deleteComment({
    required String commentId,
    required String projectId,
    required String userId,
  }) async {
    final commentDoc = await _firestore.collection('comments').doc(commentId).get();
    
    if (!commentDoc.exists) {
      throw Exception('Comment not found');
    }
    
    final commentData = commentDoc.data() as Map<String, dynamic>;
    if (commentData['userId'] != userId) {
      throw Exception('Not authorized to delete this comment');
    }

    final batch = _firestore.batch();
    
    // Delete the comment
    batch.delete(_firestore.collection('comments').doc(commentId));
    
    // Decrement the project's comment count
    final projectRef = _firestore.collection('projects').doc(projectId);
    batch.update(projectRef, {
      'commentCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }
} 