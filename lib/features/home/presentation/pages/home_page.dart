import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/firestore_quiz_repository.dart';
import '../../domain/entities/quiz_entity.dart';
import '../widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;
  final _quizRepo = FirestoreQuizRepository();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: IndexedStack(
          index: _tabIndex,
          children: [
            _buildHomeTab(user?.name ?? 'Kid'),
            const Center(child: Text('Library')),
            const Center(child: Text('Quizzes')),
            const Center(child: Text('Profile')),
          ],
        ),
      ),
      bottomNavigationBar: EcoBottomNav(
        index: _tabIndex,
        onChanged: (i) => setState(() => _tabIndex = i),
      ),
    );
  }

  // ---------------- HOME TAB ----------------

  Widget _buildHomeTab(String name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 60, bottom: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section (old design)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildTopBar(name),
          ),
          const SizedBox(height: 25),

          // XP card (dynamic from Firestore user)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: _XPProgressCard(),
          ),
          const SizedBox(height: 30),

          // Featured categories title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Featured Categories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E272E),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Categories row (old horizontal chips style)
          const _CategoryGrid(),
          const SizedBox(height: 30),

          // Available quizzes title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Available Quizzes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E272E),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Quiz list from Firestore (styled like old _QuizCard)
          _buildQuizList(),
        ],
      ),
    );
  }

  // ---------------- TOP BAR (HEADER) ----------------

  Widget _buildTopBar(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Hello $name !',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E272E),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Nice to see you again',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF808e9b),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none,
            color: Color(0xFF1E272E),
            size: 28,
          ),
        ),
      ],
    );
  }

  // ---------------- QUIZ LIST (uses Firestore, filtered by user level) ----------------

  Widget _buildQuizList() {
    // Lire le niveau de l'utilisateur depuis AuthProvider
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final int userLevel = user?.level ?? 1; // niveau 1 par défaut

    return StreamBuilder<List<QuizEntity>>(
      stream: _quizRepo.watchFeaturedQuizzes(userLevel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Error loading quizzes',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final quizzes = snapshot.data ?? [];

        if (quizzes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Text(
              'No quizzes available yet.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            ),
          );
        }

        return Column(
          children: quizzes
              .map(
                (q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _QuizCard(quiz: q),
            ),
          )
              .toList(growable: false),
        );
      },
    );
  }
}

// ---------------- XP CARD (dynamic from Firestore user) ----------------

class _XPProgressCard extends StatelessWidget {
  const _XPProgressCard();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    final int currentXp = user?.xp ?? 0;
    final int currentLevel = user?.level ?? 1;

    // Exemple : 100 XP par niveau (tu peux ajuster)
    final int xpPerLevel = 100;
    final int levelStart = (currentLevel - 1) * xpPerLevel;
    final int nextLevelStart = currentLevel * xpPerLevel;

    final double progress = ((currentXp - levelStart) /
        (nextLevelStart - levelStart))
        .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C00),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.flash_on,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$currentXp XP Points',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E272E),
                  ),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level $currentLevel',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF808e9b),
                      ),
                    ),
                    Text(
                      'Level ${currentLevel + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF808e9b),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- CATEGORY GRID (old horizontal design) ----------------

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'icon': Icons.pets,
        'label': 'Animals',
        'color': const Color(0xFFE55A38)
      },
      {
        'icon': Icons.filter_hdr,
        'label': 'Seasons',
        'color': const Color(0xFF795548)
      },
      {
        'icon': Icons.eco,
        'label': 'Ecosystems',
        'color': const Color(0xFFF9A825)
      },
      {
        'icon': Icons.public,
        'label': 'Sky & Space',
        'color': const Color(0xFF03A9F4)
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryItem(
            icon: category['icon'] as IconData,
            label: category['label'] as String,
            color: category['color'] as Color,
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 35),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E272E),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ---------------- QUIZ CARD (styled like old one, data from QuizEntity) ----------------

class _QuizCard extends StatelessWidget {
  final QuizEntity quiz;

  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final Color imageColor = const Color(0xFFFFD700);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: imageColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.brightness_5,
                        color: imageColor,
                        size: 40,
                      ),
                    ),
                  ),
                  // Si plus tard tu ajoutes questionCount dans QuizEntity,
                  // tu peux réactiver ce badge.
                  /*
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${quiz.questionCount} Qs',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  */
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E272E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quiz.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF808e9b),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFD700),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Level ${quiz.level}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF808e9b),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.flare,
                          color: Color(0xFFFF8C00),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${quiz.xp} XP',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF808e9b),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: navigate to quiz details / questions
                },
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFFBDBDBD),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
