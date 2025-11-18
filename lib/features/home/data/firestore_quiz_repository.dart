import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/quiz_entity.dart';

class FirestoreQuizRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<QuizEntity>> watchFeaturedQuizzes() {
    return _db
        .collection('quizzes')
        .orderBy('level')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final d = doc.data();
      return QuizEntity(
        id: doc.id,
        title: d['title'],
        description: d['description'],
        category: d['category'],
        level: d['level'],
        xp: d['xp'],
      );
    }).toList());
  }
}
