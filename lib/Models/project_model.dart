import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String title;
  final String description;
  final String designerId;
  final String designerName;
  final String? designerImage;
  final String category;
  final String imageUrl;
  final int views;
  final int likes;
  final int commentCount;
  final DateTime createdAt;
  final List<String> tags;
  final bool isLiked;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.designerId,
    required this.designerName,
    this.designerImage,
    required this.category,
    required this.imageUrl,
    required this.views,
    required this.likes,
    required this.commentCount,
    required this.createdAt,
    required this.tags,
    this.isLiked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'designerId': designerId,
      'designerName': designerName,
      'designerImage': designerImage,
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
      designerName: data['designerName'] ?? 'Unknown User',
      designerImage: data['designerImage'],
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      isLiked: data['isLiked'] ?? false,
    );
  }

  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? designerId,
    String? designerName,
    String? designerImage,
    String? category,
    String? imageUrl,
    int? views,
    int? likes,
    int? commentCount,
    DateTime? createdAt,
    List<String>? tags,
    bool? isLiked,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      designerId: designerId ?? this.designerId,
      designerName: designerName ?? this.designerName,
      designerImage: designerImage ?? this.designerImage,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      isLiked: isLiked ?? this.isLiked,
    );
  }
} 