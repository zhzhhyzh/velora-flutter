import 'package:cloud_firestore/cloud_firestore.dart';

class Contest {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final String coverImagePath;
  final String createdBy; // user's email
  final DateTime createdAt;
  final bool isActive;

  Contest({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.coverImagePath,
    required this.createdBy,
    required this.createdAt,
    required this.isActive,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'coverImagePath': coverImagePath,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive ? 1 : 0,
  };


  factory Contest.fromMap(Map<String, dynamic> map) {
    return Contest(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      coverImagePath: map['coverImagePath'],
      createdBy: map['createdBy'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isActive: map['isActive'],
    );
  }

  factory Contest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Contest(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      category: data['category'],
      startDate: DateTime.fromMillisecondsSinceEpoch(data['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(data['endDate']),
      coverImagePath: data['coverImagePath'],
      createdBy: data['createdBy'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
      isActive: data['isActive'] ?? true,
    );
  }

}
