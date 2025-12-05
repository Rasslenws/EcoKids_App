import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/quiz_service.dart';
import '../../services/auth_service.dart';

class QuizPage extends StatelessWidget {
  static const routeName = '/quiz';
  final String quizId;
  final String quizTitle;
  final int quizXp;

  const QuizPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.quizXp,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizService()..loadQuiz(quizId, quizXp),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<QuizService>(
            builder: (context, quizService, child) {
              if (quizService.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (quizService.questions.isEmpty) {
                return _buildErrorState(context);
              }
              if (quizService.isFinished) {
                return _buildResultScreen(context, quizService);
              }
              return _buildQuizContent(context, quizService);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, QuizService quizService) {
    final question = quizService.currentQuestion!;
    final totalQuestions = quizService.questions.length;
    final currentQuestionIndex = quizService.currentIndex + 1;
    final double progress = currentQuestionIndex / totalQuestions;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF0276A1)),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFEAF8FC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      backgroundColor: const Color(0xFFF0F0F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0276A1)),
                    ),
                  ),
                  Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFEAF8FC), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFF0276A1), size: 16),
                    const SizedBox(width: 4),
                    Text("${quizService.quizXp} XP", style: const TextStyle(color: Color(0xFF0276A1), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // --- IMAGE ---
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE04A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: question.imageUri.isNotEmpty
                        ? Image.network(
                      question.imageUri,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.white54));
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    )
                        : Image.asset('assets/images/ecokids_logo.png', fit: BoxFit.contain),
                  ),
                ),

                const SizedBox(height: 20),
                Text("Question $currentQuestionIndex of $totalQuestions", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
                ),
                const SizedBox(height: 24),

                // --- OPTIONS ---
                ...List.generate(question.options.length, (index) {
                  final opt = question.options[index];
                  final isSelected = quizService.selectedOptionIndex == index;
                  bool isCorrect = false;
                  bool isIncorrect = false;

                  if (quizService.showFeedback) {
                    if (opt.isCorrect) {
                      isCorrect = true;
                    } else if (isSelected) {
                      isIncorrect = true;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OptionCard(
                      letter: opt.id,
                      text: opt.text,
                      isSelected: isSelected,
                      isCorrect: isCorrect,
                      isIncorrect: isIncorrect,
                      onTap: () => quizService.selectOption(index),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // --- NEXT BUTTON ---
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0276A1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                disabledBackgroundColor: Colors.grey[300],
              ),
              onPressed: (quizService.selectedOptionIndex == null || quizService.showFeedback)
                  ? null
                  : () => quizService.nextQuestion(),
              child: quizService.showFeedback
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                  : const Text("Next question", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return const Center(child: Text("Loading error"));
  }

  // --- MAJOR CORRECTION IN THIS WIDGET ---
  Widget _buildResultScreen(BuildContext context, QuizService quizService) {
    final authService = context.read<AuthService>();
    final score = quizService.score;
    final total = quizService.questions.length;
    final totalXp = quizService.quizXp;
    final earnedXp = (total > 0) ? (score / total * totalXp).round() : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎉 Quiz Complete! 🎉',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0276A1)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8FC),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$score / $total',
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF0276A1)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Correct answers', style: TextStyle(fontSize: 18, color: Colors.black54)),
            const SizedBox(height: 32),
            Text(
              '+$earnedXp XP',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFF8C00)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0276A1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  // 1. Save EVERYTHING (XP + History + Number of quizzes)
                  // Note: the saveQuizHistory method already handles XP and nbQuizPlayed
                  await authService.saveQuizHistory(
                    quizTitle: quizTitle, // Use the title passed to the widget
                    score: score,
                    totalQuestions: total,
                    xpEarned: earnedXp,
                  );

                  // 2. Exit the screen
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Back to home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String letter;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final VoidCallback onTap;

  const _OptionCard({
    required this.letter,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isIncorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey.shade200;
    Color iconColor = Colors.transparent;
    IconData? iconData;

    if (isCorrect) {
      borderColor = Colors.green;
      iconColor = Colors.green;
      iconData = Icons.check_circle;
    } else if (isIncorrect) {
      borderColor = Colors.red;
      iconColor = Colors.red;
      iconData = Icons.cancel;
    } else if (isSelected) {
      borderColor = const Color(0xFF0276A1);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isCorrect || isIncorrect ? 2 : 1.5),
          boxShadow: [
            if (isSelected || isCorrect || isIncorrect)
              BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.withOpacity(0.1) : isIncorrect ? Colors.red.withOpacity(0.1) : const Color(0xFFEAF8FC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    color: isCorrect ? Colors.green : isIncorrect ? Colors.red : const Color(0xFF0276A1),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
            ),
            if (iconData != null)
              Padding(padding: const EdgeInsets.only(right: 16), child: Icon(iconData, color: iconColor, size: 24))
            else if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0276A1), border: Border.all(color: Colors.transparent, width: 2)),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
