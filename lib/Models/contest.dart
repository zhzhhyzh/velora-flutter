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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'coverImagePath': coverImagePath,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

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
    return Contest.fromMap(data);
  }
}
