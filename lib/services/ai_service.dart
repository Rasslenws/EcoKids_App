import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Pour la fonction compute
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class AIService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;
  bool _isBusy = false;

  AIService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    if (_isModelLoaded) return;

    try {
      // Configuration basique
      final options = InterpreterOptions();
      // options.threads = 4; // Peut aider sur Android

      // Chargement du modèle
      _interpreter = await Interpreter.fromAsset('assets/model/model.tflite', options: options);

      // Chargement des labels
      final labelData = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelData
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.replaceAll(RegExp(r'^\d+\s*'), '').trim())
          .toList();

      _isModelLoaded = true;
      print("✅ Modèle chargé avec succès");
    } catch (e) {
      print("❌ Erreur chargement modèle : $e");
      _isModelLoaded = false;
    }
  }

  Future<String> identifyAnimal(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      await _loadModel();
      if (!_isModelLoaded) return "Erreur : Modèle non chargé.";
    }

    if (_isBusy) return "Analyse en cours...";
    _isBusy = true;

    try {
      // 1. Lire les bytes du fichier (rapide)
      final imageData = await imageFile.readAsBytes();

      // 2. PRÉTRAITEMENT LOURD -> On l'envoie dans un Isolate (thread séparé)
      // On passe les données brutes à la fonction statique _preprocessImage
      final List<List<List<List<double>>>> input = await compute(_preprocessImage, imageData);

      // 3. Préparer la sortie
      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      // 4. Inférence (rapide sur ce type de modèle)
      _interpreter!.run(input, output);

      // 5. Analyse des résultats
      List<double> scores = List<double>.from(output[0]);
      double maxScore = 0;
      int maxIndex = -1;

      for (int i = 0; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          maxIndex = i;
        }
      }

      if (maxIndex != -1 && maxScore > 0.60) {
        String animal = _labels[maxIndex];
        if (animal.toLowerCase().contains("rien") ||
            animal.toLowerCase().contains("empty")) {
          return "Aucun animal détecté 🍃";
        }
        return "C'est un $animal ! 🎉";
      } else {
        return "Je ne suis pas sûr... 🤔";
      }

    } catch (e) {
      print("Erreur analyse : $e");
      return "Erreur technique";
    } finally {
      _isBusy = false;
    }
  }

  // --- FONCTION STATIQUE ISOLÉE ---
  // Cette fonction tourne dans un autre thread. Elle ne doit pas accéder aux variables de la classe.
  static List<List<List<List<double>>>> _preprocessImage(Uint8List imageData) {
    // A. Décodage
    var image = img.decodeImage(imageData);
    if (image == null) throw Exception("Image invalide");

    // B. Rotation (si l'image est plus large que haute, on suppose qu'elle est couchée)
    if (image.width > image.height) {
      image = img.copyRotate(image, angle: 90);
    }

    // C. Crop carré
    final resizedImage = img.copyResizeCropSquare(image, size: 224);

    // D. Conversion pixel par pixel (C'est ça qui est lent !)
    var input = List.generate(1, (i) =>
        List.generate(224, (y) =>
            List.generate(224, (x) =>
                List.generate(3, (c) {
                  var pixel = resizedImage.getPixel(x, y);
                  // Normalisation 0 à 1
                  if (c == 0) return pixel.r / 255.0;
                  if (c == 1) return pixel.g / 255.0;
                  return pixel.b / 255.0;
                })
            )
        )
    );

    return input;
  }

  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}