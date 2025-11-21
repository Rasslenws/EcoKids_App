import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/learn_game_model.dart';

class LearnService {
  final _db = FirebaseFirestore.instance;

  Stream<List<LearnGameModel>> watchAllGames() {
    return _db
        .collection('learnGames')
        .orderBy('level')
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => LearnGameModel.fromDoc(d))
        .toList());
  }

  Stream<List<LearnGameModel>> watchNewestGames() {
    return _db
        .collection('learnGames')
        .orderBy('xp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => LearnGameModel.fromDoc(d))
        .toList());
  }

}
