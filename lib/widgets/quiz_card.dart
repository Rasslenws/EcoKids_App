import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../pages/quiz/quiz_page.dart';

class QuizCard extends StatelessWidget {
  final QuizModel quiz;

  const QuizCard({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    // This map can be expanded or moved to a central theme/config file
    const categoryStyles = {
      'Animals': {'icon': Icons.pets, 'color': Color(0xFFE55A38)},
      'Ecosystems': {'icon': Icons.eco, 'color': Color(0xFFF9A825)},
      'Recycling': {'icon': Icons.recycling, 'color': Color(0xFF4CAF50)},
      'Energy': {'icon': Icons.bolt, 'color': Color(0xFF03A9F4)},
      'default': {'icon': Icons.question_mark, 'color': Colors.grey},
    };

    final style = categoryStyles[quiz.category] ?? categoryStyles['default']!;
    final Color iconColor = style['color'] as Color;
    final IconData iconData = style['icon'] as IconData;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    quiz.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 4),
                      Text('Level ${quiz.level}'),
                      const SizedBox(width: 12),
                      const Icon(Icons.flare, color: Color(0xFFFF8C00), size: 16),
                      const SizedBox(width: 4),
                      Text('+${quiz.xp} XP'),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  QuizPage.routeName,
                  arguments: {
                    'quizId': quiz.id,
                    'quizTitle': quiz.title,
                    'quizXp': quiz.xp,
                  },
                );
              },
              child: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
