import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizHistoryPage extends StatefulWidget {
  static const routeName = '/quiz-history';
  
  const QuizHistoryPage({super.key});

  @override
  State<QuizHistoryPage> createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allQuizzes = [];
  bool _isLoading = true;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  DocumentSnapshot? _lastDocument;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreQuizzes();
      }
    }
  }

  Future<void> _loadQuizHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      Query query = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('quiz_history')
          .orderBy('completedAt', descending: true)
          .limit(_pageSize);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      final List<Map<String, dynamic>> quizzes = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        quizzes.add({
          'id': doc.id,
          'title': data['quizTitle'] ?? 'Quiz',
          'score': data['score'] ?? 0,
          'totalQuestions': data['totalQuestions'] ?? 0,
          'xpEarned': data['xpEarned'] ?? 0,
          'completedAt': data['completedAt'] as Timestamp?,
        });
      }

      setState(() {
        _allQuizzes = quizzes;
        _isLoading = false;
        _hasMore = snapshot.docs.length == _pageSize;
      });
    } catch (e) {
      debugPrint('Error loading quiz history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreQuizzes() async {
    if (_lastDocument == null || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('quiz_history')
          .orderBy('completedAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      final List<Map<String, dynamic>> moreQuizzes = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        moreQuizzes.add({
          'id': doc.id,
          'title': data['quizTitle'] ?? 'Quiz',
          'score': data['score'] ?? 0,
          'totalQuestions': data['totalQuestions'] ?? 0,
          'xpEarned': data['xpEarned'] ?? 0,
          'completedAt': data['completedAt'] as Timestamp?,
        });
      }

      setState(() {
        _allQuizzes.addAll(moreQuizzes);
        _hasMore = snapshot.docs.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Error loading more quizzes: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text(
          'Quiz History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allQuizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No quiz history yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete some quizzes to see your history!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Stats Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total Completed',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_allQuizzes.length}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Quizzes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Quiz List
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: _allQuizzes.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _allQuizzes.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return _buildQuizHistoryCard(_allQuizzes[index], index);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildQuizHistoryCard(Map<String, dynamic> quiz, int index) {
    final completedAt = quiz['completedAt'] as Timestamp?;
    final date = completedAt != null
        ? _formatDate(completedAt.toDate())
        : 'Unknown date';
    
    final score = quiz['score'] as int;
    final total = quiz['totalQuestions'] as int;
    final percentage = total > 0 ? (score / total * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '#${_allQuizzes.length - index}',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz['title'] ?? 'Quiz',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(percentage).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    color: _getScoreColor(percentage),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatChip(
                icon: Icons.check_circle,
                label: 'Score',
                value: '$score/$total',
                color: const Color(0xFF2196F3),
              ),
              _buildStatChip(
                icon: Icons.stars,
                label: 'XP Earned',
                value: '+${quiz['xpEarned']}',
                color: const Color(0xFFFF9800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) {
      return const Color(0xFF4CAF50);
    } else if (percentage >= 60) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFFF44336);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
