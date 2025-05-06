import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String projectId;
  final String userId;
  final String userName;
  final String? userImage;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      userImage: data['userImage'],
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
} 