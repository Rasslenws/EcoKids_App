import 'package:cloud_firestore/cloud_firestore.dart';

class LearnGameModel {
  final String id;
  final String title;
  final String description;
  final int level;
  final int xp;
  final String category;
  final String iconName;
  final String? imageUrl;
  final String? longDescription;

  LearnGameModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.xp,
    required this.category,
    required this.iconName,
    this.imageUrl,
    this.longDescription,
  });

  factory LearnGameModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LearnGameModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      level: data['level'] ?? 1,
      xp: data['xp'] ?? 0,
      category: data['category'] ?? 'Animals',
      iconName: data['iconName'] ?? 'animal_1',
      imageUrl: data['imageUrl'] as String?,          // NEW
      longDescription: data['longDescription'] as String?, // NEW
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'level': level,
      'xp': xp,
      'category': category,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'longDescription': longDescription,
    };
  }
}
