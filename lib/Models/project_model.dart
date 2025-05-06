import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String title;
  final String description;
  final String designerId;
  final String designerName;
  final String category;
  final String imageUrl;
  final int views;
  final int likes;
  final int commentCount;  // Instead of storing comments array, we'll just store the count
  final DateTime createdAt;
  final List<String> tags;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.designerId,
    required this.designerName,
    required this.category,
    required this.imageUrl,
    required this.views,
    required this.likes,
    required this.commentCount,
    required this.createdAt,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'designerId': designerId,
      'designerName': designerName,
      'category': category,
      'imageUrl': imageUrl,
      'views': views,
      'likes': likes,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
    };
  }

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      designerId: data['designerId'] ?? '',
      designerName: data['designerName'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
} 