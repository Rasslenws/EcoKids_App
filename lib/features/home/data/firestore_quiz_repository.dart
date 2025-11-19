import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/quiz_entity.dart';

class FirestoreQuizRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<QuizEntity>> watchFeaturedQuizzes(int level) {
    return _db
        .collection('quizzes')
        .where('level', isEqualTo: level)   // filtre par niveau
    // .orderBy('title')                // désactivé pour le test
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final d = doc.data();
      return QuizEntity(
        id: doc.id,
        title: d['title'] as String,
        description: d['description'] as String,
        category: d['category'] as String,
        level: d['level'] as int,
        xp: d['xp'] as int,
      );
    }).toList());
  }
}

