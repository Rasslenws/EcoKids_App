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
        quizzesPlayed: data?['quizzesPlayed'] ?? 0,
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
        quizzesPlayed: data['quizzesPlayed'] ?? 0,
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
        'quizzesPlayed': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      currentUser = UserModel(id: uid, name: name, email: email, quizzesPlayed: 0,);
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

  Future<void> awardXp(int xp) async {
    if (currentUser == null || xp <= 0) return;
    try {
      await _db.collection('users').doc(currentUser!.id).update({'xp': FieldValue.increment(xp)});

      final newXp = currentUser!.xp + xp;
      final newLevel = (newXp / 100).floor() + 1;
      final newNbrQuizzes = currentUser!.quizzesPlayed + 1;

      currentUser = UserModel(
        id: currentUser!.id,
        name: currentUser!.name,
        email: currentUser!.email,
        xp: newXp,
        level: newLevel,
        quizzesPlayed: newNbrQuizzes,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to award XP: $e");
    }
  }


}
