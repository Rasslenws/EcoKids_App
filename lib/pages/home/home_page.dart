import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_model.dart';
import '../../services/auth_service.dart';
import '../../services/quiz_service.dart';
import '../../services/camera_service.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/quiz_card.dart';
import 'quizzes_page.dart';
import '../learn/learn_page.dart';
import '../home/display_picture_page.dart';
import '../profile/profile_page.dart'; // Import the ProfilePage

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: IndexedStack(
          index: _tabIndex,
          children: [
            _buildHomeTab(user?.name ?? 'Kid'),
            const LearnPage(),
            const QuizzesPage(),
            const ProfilePage(), // Now navigates to ProfilePage
          ],
        ),
      ),
      bottomNavigationBar: EcoBottomNav(
        index: _tabIndex < 2 ? _tabIndex : _tabIndex + 1, // Map tab index back to nav index
        onChanged: (i) async {
          if (i == 2) { // Camera button
            final cameraService = context.read<CameraService>();
            final imageFile = await cameraService.takePicture();
            if (imageFile != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DisplayPicturePage(imageFile: imageFile),
                ),
              );
            }
          } else {
            // Adjust nav index to tab index
            int newIndex = i > 2 ? i - 1 : i;
            setState(() => _tabIndex = newIndex);
          }
        },
      ),
    );
  }

  // ---------------- HOME TAB ----------------

  Widget _buildHomeTab(String name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20, bottom: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildTopBar(name),
          ),
          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: _XPProgressCard(),
          ),
          const SizedBox(height: 30),
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
          _buildCategoryGrid(),
          const SizedBox(height: 30),
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

  // ---------------- QUIZ LIST ----------------

  Widget _buildQuizList() {
    final auth = context.watch<AuthService>();
    final quizService = context.watch<QuizService>();
    final user = auth.currentUser;
    final int userLevel = user?.level ?? 1;

    return StreamBuilder<List<QuizModel>>(
      stream: quizService.watchFeaturedQuizzes(userLevel, category: _selectedCategory),
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
              'No quizzes available for this category.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            ),
          );
        }
        return Column(
          children: quizzes.map((q) => Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
            child: QuizCard(quiz: q),
          )).toList(growable: false),
        );
      },
    );
  }

  // ---------------- CATEGORY GRID ----------------

  Widget _buildCategoryGrid() {
    final categories = [
      {'icon': Icons.pets, 'label': 'Animals', 'color': const Color(0xFFE55A38)},
      {'icon': Icons.eco, 'label': 'Ecosystems', 'color': const Color(0xFFF9A825)},
      {'icon': Icons.recycling, 'label': 'Recycling', 'color': const Color(0xFF4CAF50)},
      {'icon': Icons.bolt, 'label': 'Energy', 'color': const Color(0xFF03A9F4)},
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
          final categoryLabel = category['label'] as String;
          final isSelected = _selectedCategory == categoryLabel;

          return _CategoryItem(
            icon: category['icon'] as IconData,
            label: categoryLabel,
            color: category['color'] as Color,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedCategory = null;
                } else {
                  _selectedCategory = categoryLabel;
                }
              });
            },
          );
        },
      ),
    );
  }
}

// ---------------- XP CARD ----------------

class _XPProgressCard extends StatelessWidget {
  const _XPProgressCard();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    final int currentXp = user?.xp ?? 0;
    final int currentLevel = user?.level ?? 1;
    final int xpPerLevel = 100;
    final int levelStart = (currentLevel - 1) * xpPerLevel;
    final int nextLevelStart = currentLevel * xpPerLevel;

    final double progress = (nextLevelStart == levelStart) ? 0.0 : ((currentXp - levelStart) / (nextLevelStart - levelStart)).clamp(0.0, 1.0);

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

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(35),
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isSelected ? 0.6 : 0.3),
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
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF1E272E),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}