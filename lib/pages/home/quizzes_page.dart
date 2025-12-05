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

  // Catégories correspondant à celles du Seeder
  final List<String> _categories = ['Animals', 'Ecosystems', 'Recycling', 'Energy'];
  final List<int> _levels = [1, 2, 3];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fond gris très doux
      appBar: AppBar(
        title: const Text(
          'Bibliothèque de Quiz',
          style: TextStyle(
            color: Color(0xFF1E272E),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Bouton pour effacer les filtres si un filtre est actif
          if (_selectedCategory != null || _selectedLevel != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.filter_alt_off_rounded, color: Color(0xFFFF8C00)),
                tooltip: 'Effacer les filtres',
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedLevel = null;
                  });
                },
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFiltersHeader(),
          const SizedBox(height: 10),
          Expanded(child: _buildQuizList()),
        ],
      ),
    );
  }

  Widget _buildFiltersHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Section Catégories ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.category_rounded, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Sujets',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                    selectedColor: const Color(0xFF007BFF).withOpacity(0.15),
                    checkmarkColor: const Color(0xFF007BFF),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF007BFF) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    backgroundColor: const Color(0xFFF0F2F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF007BFF) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    showCheckmark: isSelected, // Montrer le check seulement si sélectionné
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // --- Section Niveaux ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.signal_cellular_alt_rounded, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Difficulté',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _levels.map((level) {
                final isSelected = _selectedLevel == level;

                // Couleurs et labels dynamiques selon le niveau
                Color levelColor;
                String levelLabel;
                switch(level) {
                  case 1:
                    levelColor = Colors.green;
                    levelLabel = "Débutant";
                    break;
                  case 2:
                    levelColor = Colors.orange;
                    levelLabel = "Moyen";
                    break;
                  case 3:
                    levelColor = Colors.red;
                    levelLabel = "Expert";
                    break;
                  default:
                    levelColor = Colors.blue;
                    levelLabel = "Niv $level";
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: FilterChip(
                    avatar: isSelected ? null : CircleAvatar(
                      backgroundColor: levelColor.withOpacity(0.2),
                      radius: 8,
                      child: Text(
                          "$level",
                          style: TextStyle(fontSize: 10, color: levelColor, fontWeight: FontWeight.bold)
                      ),
                    ),
                    label: Text(levelLabel),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLevel = selected ? level : null;
                      });
                    },
                    selectedColor: levelColor.withOpacity(0.15),
                    checkmarkColor: levelColor,
                    labelStyle: TextStyle(
                      color: isSelected ? levelColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    backgroundColor: const Color(0xFFF0F2F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? levelColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  ),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 60, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Une erreur est survenue',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        final quizzes = snapshot.data ?? [];

        if (quizzes.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Aucun quiz trouvé !',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E272E)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Essaie de changer les filtres pour\nvoir plus de résultats.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[500], height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  if (_selectedCategory != null || _selectedLevel != null)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = null;
                          _selectedLevel = null;
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Tout effacer"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          itemCount: quizzes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return QuizCard(quiz: quizzes[index]);
          },
        );
      },
    );
  }
}