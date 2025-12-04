import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? currentUser;
  bool isLoading = false;
  String? error;

  AuthService() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _auth.authStateChanges().asyncMap((fb.User? user) async {
      if (user == null) return null;
      final doc = await _db.collection('users').doc(user.uid).get();
      final data = doc.data();
      return UserModel(
        id: user.uid,
        name: data?['name'] ?? '',
        email: user.email ?? '',
        xp: data?['xp'] ?? 0,
        level: data?['level'] ?? 1,
        nbQuizPlayed: data?['nbQuizPlayed'] ?? 0,
      );
    }).listen((userModel) {
      currentUser = userModel;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      final data = doc.data() ?? {};
      currentUser = UserModel(
        id: cred.user!.uid,
        name: data['name'] ?? '',
        email: email,
        xp: data['xp'] ?? 0,
        level: data['level'] ?? 1,
        nbQuizPlayed: data['nbQuizPlayed'] ?? 0,
      );
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'xp': 0,
        'level': 1,
        'nbQuizPlayed': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      currentUser = UserModel(id: uid, name: name, email: email);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // Mise à jour de l'XP uniquement (si besoin hors quiz)
  Future<void> awardXp(int xp) async {
    if (currentUser == null || xp <= 0) return;
    try {
      await _db.collection('users').doc(currentUser!.id).update({'xp': FieldValue.increment(xp)});

      final newXp = currentUser!.xp + xp;
      final newLevel = (newXp / 100).floor() + 1;

      currentUser = UserModel(
        id: currentUser!.id,
        name: currentUser!.name,
        email: currentUser!.email,
        xp: newXp,
        level: newLevel,
        nbQuizPlayed: currentUser!.nbQuizPlayed,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to award XP: $e");
    }
  }

  // --- CORRECTION CLÉ ICI ---
  Future<void> saveQuizHistory({
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required int xpEarned,
  }) async {
    if (currentUser == null) return;

    try {
      // 1. Sauvegarder dans Firestore (Historique)
      await _db
          .collection('users')
          .doc(currentUser!.id)
          .collection('quiz_history')
          .add({
        'quizTitle': quizTitle,
        'score': score,
        'totalQuestions': totalQuestions,
        'xpEarned': xpEarned,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // 2. Incrémenter le compteur global dans Firestore
      await _db.collection('users').doc(currentUser!.id).update({
        'nbQuizPlayed': FieldValue.increment(1),
        // On met aussi à jour l'XP dans la base ici pour être sûr
        'xp': FieldValue.increment(xpEarned),
      });

      // 3. MISE À JOUR LOCALE (Pour l'affichage instantané)
      final newXp = currentUser!.xp + xpEarned;
      final newLevel = (newXp / 100).floor() + 1;
      final newNbQuiz = currentUser!.nbQuizPlayed + 1;

      currentUser = UserModel(
        id: currentUser!.id,
        name: currentUser!.name,
        email: currentUser!.email,
        xp: newXp,
        level: newLevel,
        nbQuizPlayed: newNbQuiz, // On force le +1 localement
      );

      // Notifier la ProfilePage que les données ont changé
      notifyListeners();

    } catch (e) {
      debugPrint("Failed to save quiz history: $e");
    }
  }
}
