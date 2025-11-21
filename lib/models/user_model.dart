class UserModel {
  final String id;
  final String name;
  final String email;
  final int xp;
  final int level;
  final quizzesPlayed;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.xp = 0,
    this.level = 1,
    this.quizzesPlayed,
  });
}
