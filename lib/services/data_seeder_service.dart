import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';

class DataSeederService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Lancez cette méthode UNE SEULE FOIS dans main.dart
  Future<void> seedDatabase() async {
    print("🌱 Starting MASSIVE database seeding...");

    final categories = ['Animals', 'Ecosystems', 'Recycling', 'Energy']; // Catégories en Anglais
    final levels = [1, 2, 3];
    final quizzesPerLevel = 3; // 3 Quiz par niveau

    int globalQuizCounter = 0;

    // Boucle sur chaque Catégorie
    for (var category in categories) {
      // Boucle sur chaque Niveau (1, 2, 3)
      for (var level in levels) {
        // Création de 3 Quiz pour ce niveau
        for (var i = 1; i <= quizzesPerLevel; i++) {

          // ID unique: ex: quiz_ani_1_1 (on garde l'id technique simple)
          final String quizId = 'quiz_${category.toLowerCase().substring(0, 3)}_${level}_$i';
          final String title = _getQuizTitle(category, level, i);

          // Génération des 5 questions spécifiques
          // On passe 'i' (quizIndex) pour aider à mixer
          final List<QuestionModel> questions = _generateQuestions(category, level, i);

          // 1. Création du document Quiz
          await _db.collection('quizzes').doc(quizId).set({
            'title': title,
            'description': 'Level $level - Series $i: Test your knowledge about $category!',
            'category': category,
            'level': level,
            'xp': 50 * level, // Plus le niveau est haut, plus on gagne d'XP
          });

          // 2. Ajout des 5 questions en sous-collection
          var batch = _db.batch();
          for (var q in questions) {
            var qRef = _db.collection('quizzes').doc(quizId).collection('questions').doc(q.id);
            batch.set(qRef, {
              'text': q.questionText,
              'imageUri': q.imageUri,
              'options': q.options.map((o) => {
                'id': o.id,
                'text': o.text,
                'isCorrect': o.isCorrect,
              }).toList(),
            });
          }
          await batch.commit();

          globalQuizCounter++;
          print("✅ Quiz added: $category (Lvl $level - #$i)");
        }
      }
    }

    print("🎉 DONE! $globalQuizCounter quizzes created successfully.");
  }

  String _getQuizTitle(String category, int level, int index) {
    // Titres dynamiques en anglais
    if (level == 1) return 'Beginner $category #$index';
    if (level == 2) return 'Explorer $category #$index';
    return 'Expert $category #$index';
  }

  // --- GÉNÉRATEUR DE QUESTIONS ---
  List<QuestionModel> _generateQuestions(String category, int level, int quizIndex) {
    // On génère 5 questions basées sur la catégorie et le niveau
    List<QuestionModel> questions = [];
    int baseId = (level * 100) + (quizIndex * 10); // ID unique fictif pour les questions

    for (int q = 1; q <= 5; q++) {
      // On passe 'quizIndex' pour ajouter de la variété
      questions.add(_createSpecificQuestion(category, level, baseId + q, q, quizIndex));
    }
    return questions;
  }

  QuestionModel _createSpecificQuestion(String category, int level, int idSuffix, int qIndex, int quizIndex) {
    String id = '${category.substring(0, 2)}_$idSuffix';

    // Logique pour varier le contenu selon la catégorie
    switch (category) {
      case 'Animals':
        return _getAnimalQuestion(level, qIndex, id, quizIndex);
      case 'Recycling':
        return _getRecyclageQuestion(level, qIndex, id, quizIndex);
      case 'Energy':
        return _getEnergieQuestion(level, qIndex, id, quizIndex);
      case 'Ecosystems':
        return _getEcosystemeQuestion(level, qIndex, id, quizIndex);
      default:
        return _q(id, 'Generic Question', 'https://cdn-icons-png.flaticon.com/512/3069/3069172.png', []);
    }
  }

  // --- CONTENU : ANIMAUX (EN) ---
  QuestionModel _getAnimalQuestion(int level, int index, String id, int quizIndex) {
    // URLs réelles (exemples statiques pour la démo)
    final images = [
      'https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=500', // Lion
      'https://images.unsplash.com/photo-1501706362039-c06b2d715385?w=500', // Zebra
      'https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?w=500', // Elephant
      'https://images.unsplash.com/photo-1547721064-da6cfb341d50?w=500', // Giraffe
      'https://images.unsplash.com/photo-1540573133985-87b6da6d54a9?w=500', // Monkey
    ];

    // MIXAGE : On utilise le niveau et le numéro du quiz pour décaler l'index
    // Ex: Niveau 1, Quiz 1 -> Index 0 (Lion)
    // Ex: Niveau 2, Quiz 1 -> Index 1 (Zèbre)
    int mixedIndex = (index - 1 + level + quizIndex) % images.length;
    String imgUrl = images[mixedIndex];

    if (level == 1) {
      final subjects = ['Lion', 'Zebra', 'Elephant', 'Giraffe', 'Monkey'];
      final subject = subjects[mixedIndex];
      return _q(id, 'What animal is this?', imgUrl, [
        _o('A', subject, true),
        _o('B', 'A cat', false),
        _o('C', 'A dog', false),
      ]);
    } else if (level == 2) {
      return _q(id, 'What does this animal eat (Carnivore/Herbivore)?', imgUrl, [
        _o('A', 'Meat', mixedIndex % 2 == 0),
        _o('B', 'Plants', mixedIndex % 2 != 0),
        _o('C', 'Candy', false),
      ]);
    } else {
      return _q(id, 'Where does this animal mainly live?', imgUrl, [
        _o('A', 'In the savanna', true),
        _o('B', 'At the North Pole', false),
        _o('C', 'In the ocean', false),
      ]);
    }
  }

  // --- CONTENU : RECYCLAGE (EN) ---
  QuestionModel _getRecyclageQuestion(int level, int index, String id, int quizIndex) {
    final images = [
      'https://images.unsplash.com/photo-1595278069441-2cf29f8005a4?w=500', // Plastic bottle
      'https://images.unsplash.com/photo-1585842823793-1765c92c8969?w=500', // Paper
      'https://images.unsplash.com/photo-1562077977-9a04f25b2061?w=500', // Apple core (compost)
      'https://images.unsplash.com/photo-1610344270420-b49e8a0026e6?w=500', // Can
      'https://images.unsplash.com/photo-1533241249767-3617c0934096?w=500', // Glass
    ];

    // MIXAGE
    int mixedIndex = (index - 1 + level + quizIndex) % images.length;
    String imgUrl = images[mixedIndex];

    if (level == 1) {
      final wastes = ['Plastic bottle', 'Newspaper', 'Apple', 'Soda can', 'Glass jar'];
      final waste = wastes[mixedIndex];
      return _q(id, 'Which bin does this waste go into: $waste?', imgUrl, [
        _o('A', 'Recycling Bin', true),
        _o('B', 'On the ground', false),
        _o('C', 'In nature', false),
      ]);
    } else {
      return _q(id, 'How long does it take for this waste to decompose?', imgUrl, [
        _o('A', '100 years', true),
        _o('B', '2 days', false),
        _o('C', 'Never', false),
      ]);
    }
  }

  // --- CONTENU : ÉNERGIE (EN) ---
  QuestionModel _getEnergieQuestion(int level, int index, String id, int quizIndex) {
    // Images génériques énergie
    final images = [
      'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=500', // Solar
      'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=500', // Wind
      'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?w=500', // Lightbulb
      'https://images.unsplash.com/photo-1521618755572-156ae0cdd74d?w=500', // Plug
      'https://images.unsplash.com/photo-1544724569-5f546fd6dd2d?w=500', // Dam (hydro)
    ];

    // MIXAGE
    int mixedIndex = (index - 1 + level + quizIndex) % images.length;
    String imgUrl = images[mixedIndex];

    if (level == 1) {
      return _q(id, 'Where does this energy come from (Sun/Wind)?', imgUrl, [
        _o('A', 'Renewable', true),
        _o('B', 'Polluting', false),
        _o('C', 'Magic', false),
      ]);
    } else {
      return _q(id, 'How can we save energy here?', imgUrl, [
        _o('A', 'Turn off the light', true),
        _o('B', 'Leave everything on', false),
        _o('C', 'Keep the fridge open', false),
      ]);
    }
  }

  // --- CONTENU : ÉCOSYSTÈMES (EN) ---
  QuestionModel _getEcosystemeQuestion(int level, int index, String id, int quizIndex) {
    final images = [
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500', // Forest
      'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500', // Nature
      'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?w=500', // Beach
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=500', // Mountain
      'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=500', // Forest 2
    ];

    // MIXAGE
    int mixedIndex = (index - 1 + level + quizIndex) % images.length;
    String imgUrl = images[mixedIndex];

    return _q(id, 'Which element is essential for this ecosystem?', imgUrl, [
      _o('A', 'Water', true),
      _o('B', 'Plastic', false),
      _o('C', 'Noise', false),
    ]);
  }

  // --- HELPERS ---
  QuestionModel _q(String id, String text, String img, List<QuestionOption> opts) {
    return QuestionModel(
        id: id,
        questionText: text,
        imageUri: img,
        options: opts.isEmpty ? [ // Options par défaut si vide
          _o('A', 'Yes', true),
          _o('B', 'No', false),
        ] : opts
    );
  }

  QuestionOption _o(String id, String text, bool correct) {
    return QuestionOption(id: id, text: text, isCorrect: correct);
  }
}