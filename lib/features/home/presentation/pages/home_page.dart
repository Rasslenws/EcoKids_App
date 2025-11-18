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
            _buildHomeTab(user?.name ?? ''),
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

  // HOME TAB

  Widget _buildHomeTab(String name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(name),
          const SizedBox(height: 16),
          _buildXpCard(),
          const SizedBox(height: 24),
          const Text(
            'Featured Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildCategoriesRow(),
          const SizedBox(height: 24),
          const Text(
            'Available Quizzes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuizList(),
        ],
      ),
    );
  }

  Widget _buildTopBar(String name) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello $name !',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Nice to see you again',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.notifications_none,
            size: 20,
            color: Color(0xFFFFA726),
          ),
        ),
      ],
    );
  }

  Widget _buildXpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '280 XP Points',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.6, // 60%
              minHeight: 8,
              backgroundColor: Colors.white,
              color: Color(0xFFFFA726),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Level 2',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'Level 5',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow() {
    final cats = [
      ('Animals', Icons.pets),
      ('Seasons', Icons.wb_sunny_outlined),
      ('Ecosystems', Icons.forest_outlined),
      ('Sky & Space', Icons.public),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cats
          .map(
            (c) => Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                c.$2,
                color: const Color(0xFFFFA726),
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              c.$1,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          .toList(growable: false),
    );
  }

  Widget _buildQuizList() {
    return StreamBuilder<List<QuizEntity>>(
      stream: _quizRepo.watchFeaturedQuizzes(),
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Error loading quizzes',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final quizzes = snapshot.data ?? [];

        if (quizzes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
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

class _QuizCard extends StatelessWidget {
  final QuizEntity quiz;

  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
          ),
          // Replace with Image.asset if you have quiz icons:
          // child: Image.asset('assets/images/animal_quiz.png'),
          child: const Icon(
            Icons.pets,
            color: Color(0xFFFFA726),
          ),
        ),
        title: Text(
          quiz.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              quiz.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFFA726),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Level ${quiz.level}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFA726),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '+ ${quiz.xp} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFFBDBDBD),
        ),
        onTap: () {
          // TODO: navigate to quiz details / questions
        },
      ),
    );
  }
}
