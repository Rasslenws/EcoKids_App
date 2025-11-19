import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_model.dart';
import '../../services/quiz_service.dart';
import '../../widgets/quiz_card.dart';

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  int? _selectedLevel;
  String? _selectedCategory;

  final List<String> _categories = ['Animaux', 'Écosystèmes', 'Recyclage', 'Énergie'];
  final List<int> _levels = [1, 2, 3];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text('Tous les Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildQuizList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtre par catégorie
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Catégories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Wrap(
              spacing: 8.0,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.8),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // Filtre par niveau
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Niveaux', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              children: _levels.map((level) {
                final isSelected = _selectedLevel == level;
                return ChoiceChip(
                  label: Text('Niveau $level'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedLevel = selected ? level : null;
                    });
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.8),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizList() {
    final quizService = context.watch<QuizService>();
    return StreamBuilder<List<QuizModel>>(
      stream: quizService.watchAllQuizzes(level: _selectedLevel, category: _selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        final quizzes = snapshot.data ?? [];
        if (quizzes.isEmpty) {
          return const Center(
            child: Text(
              'Aucun quiz trouvé pour ces filtres.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            return QuizCard(quiz: quizzes[index]);
          },
        );
      },
    );
  }
}
