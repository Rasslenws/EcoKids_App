class QuestionOption {
  final String id; // "A", "B", "C"...
  final String text;
  final bool isCorrect;

  QuestionOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  // Factory pour créer depuis la Map Firestore
  factory QuestionOption.fromMap(Map<String, dynamic> map) {
    return QuestionOption(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
    );
  }
}

class QuestionModel {
  final String id;
  final String questionText;
  final String imageUri; // New field
  final List<QuestionOption> options;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.imageUri,
    required this.options,
  });
}