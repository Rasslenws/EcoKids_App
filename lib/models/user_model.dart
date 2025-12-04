class UserModel {
  final String id;
  final String name;
  final String email;
  final int xp;
  final int level;
  final int nbQuizPlayed; // Attribut essentiel

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.xp = 0,
    this.level = 1,
    this.nbQuizPlayed = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'xp': xp,
      'level': level,
      'nbQuizPlayed': nbQuizPlayed,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      nbQuizPlayed: map['nbQuizPlayed'] ?? 0,
    );
  }
}
