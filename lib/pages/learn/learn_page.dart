import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/learn_game_model.dart';
import '../../services/auth_service.dart';
import '../../services/learn_service.dart';
import 'learn_detail_page.dart';

class LearnPage extends StatefulWidget {
  static const String routeName = '/learn';

  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F8F8),
        title: const Text(
          'LearnGames',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),

      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLearnTab(user?.level ?? 1),
            _buildFavoritesTab(),
            _buildRewardsTab(),
          ],
        ),
      ),
    );
  }

  // -------- TAB 1: Learn (list of games) --------

  Widget _buildLearnTab(int userLevel) {
    final learnService = context.watch<LearnService>();

    return StreamBuilder<List<LearnGameModel>>(
      stream: learnService.watchAllGames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading games',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }
        final games = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: games.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildHeader(games.length);
            }
            final game = games[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LearnGameCard(game: game),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count Games',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: const [
              Text(
                'Newest',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.swap_vert,
                size: 18,
                color: Color(0xFF2196F3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------- TAB 2: Favorites (placeholder) --------

  Widget _buildFavoritesTab() {
    return const Center(
      child: Text(
        'No favorites yet',
        style: TextStyle(color: Color(0xFF9E9E9E)),
      ),
    );
  }

  // -------- TAB 3: Rewards (placeholder) --------

  Widget _buildRewardsTab() {
    return const Center(
      child: Text(
        'No rewards yet',
        style: TextStyle(color: Color(0xFF9E9E9E)),
      ),
    );
  }
}

class _LearnGameCard extends StatelessWidget {
  final LearnGameModel game;

  const _LearnGameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    // same category style map as QuizCard
    const categoryStyles = {
      'Animals': {'icon': Icons.pets, 'color': Color(0xFFE55A38)},
      'Ecosystems': {'icon': Icons.eco, 'color': Color(0xFFF9A825)},
      'Recycling': {'icon': Icons.recycling, 'color': Color(0xFF4CAF50)},
      'Energy': {'icon': Icons.bolt, 'color': Color(0xFF03A9F4)},
      'default': {'icon': Icons.question_mark, 'color': Colors.grey},
    };

    final style = categoryStyles[game.category] ?? categoryStyles['default']!;
    final Color iconColor = style['color'] as Color;
    final IconData iconData = style['icon'] as IconData;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LearnDetailPage(game: game),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.04),
            ),
          ],
        ),
        child: Row(
          children: [
            // icon box with dynamic color/icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.description,
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
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Level ${game.level}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.bolt,
                        size: 14,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${game.xp} XP',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFBDBDBD),
            ),
          ],
        ),
      ),
    );
  }
}
