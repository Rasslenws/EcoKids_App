import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  UserEntity? currentUser;
  bool isLoading = false;
  String? error;

  AuthProvider(this._repo);

  void listenToAuthChanges() {
    _repo.authStateChanges().listen((user) {
      currentUser = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();
      currentUser = await _repo.signIn(email: email, password: password);
      error = null;
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
    try {
      isLoading = true;
      notifyListeners();
      currentUser =
      await _repo.signUp(name: name, email: email, password: password);
      error = null;
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
    await _repo.signOut();
  }

  Future<void> sendReset(String email) => _repo.sendPasswordReset(email);
}
