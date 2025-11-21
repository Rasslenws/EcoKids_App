class QuizModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int level;
  final int xp;
  final int quizzesPlayed;


  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.xp,
    required this.quizzesPlayed,
  });
}
