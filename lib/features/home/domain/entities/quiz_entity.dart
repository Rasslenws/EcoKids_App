class QuizEntity {
  final String id;
  final String title;
  final String description;
  final String category;
  final int level;
  final int xp;

  QuizEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.xp,
  });
}
