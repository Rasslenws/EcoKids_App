import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<UserEntity?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((fb.User? user) async {
      if (user == null) return null;
      final doc = await _db.collection('users').doc(user.uid).get();
      final data = doc.data();
      return UserEntity(
        id: user.uid,
        name: data?['name'] ?? '',
        email: user.email ?? '',
        xp: data?['xp'] ?? 0,
        level: data?['level'] ?? 1,
      );
    });
  }

  @override
  Future<UserEntity> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'xp': 0,
      'level': 1,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return UserEntity(id: uid, name: name, email: email);
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    return UserEntity(
      id: uid,
      name: data['name'] ?? '',
      email: email,
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
    );
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}
