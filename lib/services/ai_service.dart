import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class AIService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;
  bool _isBusy = false; // Verrou pour éviter les appels simultanés

  AIService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    if (_isModelLoaded) return; // Évite le rechargement si déjà fait

    try {
      // Configuration des options pour la performance et la stabilité
      final options = InterpreterOptions();
      // options.threads = 4; // Décommentez si besoin de performance multi-cœurs

      _interpreter = await Interpreter.fromAsset('assets/model/model.tflite', options: options);

      final labelData = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelData
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.replaceAll(RegExp(r'^\d+\s*'), '').trim())
          .toList();

      _isModelLoaded = true;
      print("✅ Modèle chargé (Singleton) : ${_labels.length} classes.");
    } catch (e) {
      print("❌ Erreur chargement modèle : $e");
      _isModelLoaded = false;
    }
  }

  Future<String> identifyAnimal(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      // Tentative de rechargement si échec précédent
      await _loadModel();
      if (!_isModelLoaded) return "Erreur : Modèle non chargé.";
    }

    if (_isBusy) return "Analyse en cours... ⏳";
    _isBusy = true; // Verrouiller

    try {
      final imageData = await imageFile.readAsBytes();
      var image = img.decodeImage(imageData);
      if (image == null) throw Exception("Image invalide");

      // Rotation si nécessaire
      if (image.width > image.height) {
        image = img.copyRotate(image, angle: 90);
      }

      final resizedImage = img.copyResizeCropSquare(image, size: 224);

      // Normalisation [0, 1] pour Float32
      var input = List.generate(1, (i) =>
          List.generate(224, (y) =>
              List.generate(224, (x) =>
                  List.generate(3, (c) {
                    var pixel = resizedImage.getPixel(x, y);
                    if (c == 0) return pixel.r / 255.0;
                    if (c == 1) return pixel.g / 255.0;
                    return pixel.b / 255.0;
                  })
              )
          )
      );

      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      _interpreter!.run(input, output);

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
      _isBusy = false; // Déverrouiller quoi qu'il arrive
    }
  }

  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}