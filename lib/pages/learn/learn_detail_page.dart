import 'package:flutter/material.dart';
import '../../models/learn_game_model.dart';

class LearnDetailPage extends StatelessWidget {
  static const String routeName = '/learn-detail';
  final LearnGameModel game;

  const LearnDetailPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final String description = game.longDescription ?? game.description;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          game.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE: network if imageUrl, otherwise a fallback icon
            Center(
              child: game.imageUrl != null && game.imageUrl!.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.network(
                  game.imageUrl!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 90,
                  color: Color(0xFFE55A38),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              game.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E272E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Level ${game.level}  •  +${game.xp} XP',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF808E9B),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Learn more',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF424242),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
