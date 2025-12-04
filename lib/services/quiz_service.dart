import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/quiz_model.dart';

class QuizService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Part 1: Data Fetching Methods (from old Repository) ---

  Stream<List<QuizModel>> watchFeaturedQuizzes(int level, {String? category}) {
    Query query = _db.collection('quizzes').where('level', isEqualTo: level);
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map(_mapQueryToQuizList);
  }

  Stream<List<QuizModel>> watchAllQuizzes({int? level, String? category}) {
    Query query = _db.collection('quizzes');
    if (level != null && level > 0) {
      query = query.where('level', isEqualTo: level);
    }
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map(_mapQueryToQuizList);
  }

  Stream<List<QuestionModel>> _getQuestionsForQuiz(String quizId) {
    return _db.collection('quizzes').doc(quizId).collection('questions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final optionsList = data['options'] as List<dynamic>? ?? [];
        final parsedOptions = optionsList.map((o) => QuestionOption.fromMap(o as Map<String, dynamic>)).toList();
        return QuestionModel(
          id: doc.id,
          questionText: data['text'] ?? data['title'] ?? 'Question sans texte',
          imageUri: data['imageUri'] ?? '',
          options: parsedOptions,
        );
      }).toList();
    });
  }

  List<QuizModel> _mapQueryToQuizList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final d = doc.data() as Map<String, dynamic>;
      return QuizModel(
        id: doc.id,
        title: d['title'] as String? ?? 'Untitled',
        description: d['description'] as String? ?? '',
        category: d['category'] as String? ?? '',
        level: (d['level'] as num?)?.toInt() ?? 1,
        xp: (d['xp'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  // --- Part 2: Active Quiz State Management (from old Provider) ---

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  int quizXp = 0;
  int? _selectedOptionIndex;
  bool _showFeedback = false;
  StreamSubscription? _questionSubscription;

  // Getters
  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get showFeedback => _showFeedback;
  bool get isFinished => _questions.isNotEmpty && _currentIndex >= _questions.length;
  QuestionModel? get currentQuestion => (isFinished || _questions.isEmpty) ? null : _questions[_currentIndex];

  // Methods
  void loadQuiz(String quizId, int xp) {
    _isLoading = true;
    _score = 0;
    _currentIndex = 0;
    quizXp = xp;
    _selectedOptionIndex = null;
    _showFeedback = false;
    _questionSubscription?.cancel();
    notifyListeners();

    _questionSubscription = _getQuestionsForQuiz(quizId).listen((questions) {
      _questions = questions;
      _isLoading = false;
      notifyListeners();
    });
  }

  void selectOption(int index) {
    if (_showFeedback) return;
    _selectedOptionIndex = index;
    notifyListeners();
  }

  Future<void> nextQuestion() async {
    if (_selectedOptionIndex == null || _showFeedback) return;

    final selectedOption = currentQuestion!.options[_selectedOptionIndex!];
    if (selectedOption.isCorrect) {
      _score++;
    }
    _showFeedback = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _currentIndex++;
    _selectedOptionIndex = null;
    _showFeedback = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _questionSubscription?.cancel();
    super.dispose();
  }
}
