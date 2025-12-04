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
      print("✅ Model loaded successfully");
    } catch (e) {
      print("❌ Error loading model: $e");
      _isModelLoaded = false;
    }
  }

  Future<String> identifyAnimal(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      await _loadModel();
      if (!_isModelLoaded) return "Error: Model not loaded.";
    }

    if (_isBusy) return "Analysis in progress...";
    _isBusy = true;

    try {
      // 1. Read file bytes (fast)
      final imageData = await imageFile.readAsBytes();

      // 2. HEAVY PREPROCESSING -> Send it to an Isolate (separate thread)
      // Pass raw data to the static _preprocessImage function
      final List<List<List<List<double>>>> input = await compute(_preprocessImage, imageData);

      // 3. Prepare the output
      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      // 4. Inference (fast on this type of model)
      _interpreter!.run(input, output);

      // 5. Analyze results
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
          return "No animal detected 🍃";
        }
        return "It's a $animal! 🎉";
      } else {
        return "I'm not sure... 🤔";
      }

    } catch (e) {
      print("Analysis error: $e");
      return "Technical error";
    } finally {
      _isBusy = false;
    }
  }

  // --- STATIC ISOLATED FUNCTION ---
  // This function runs in another thread. It must not access class variables.
  static List<List<List<List<double>>>> _preprocessImage(Uint8List imageData) {
    // A. Decode
    var image = img.decodeImage(imageData);
    if (image == null) throw Exception("Invalid image");

    // B. Rotation (if the image is wider than it is tall, we assume it's lying down)
    if (image.width > image.height) {
      image = img.copyRotate(image, angle: 90);
    }

    // C. Square Crop
    final resizedImage = img.copyResizeCropSquare(image, size: 224);

    // D. Pixel-by-pixel conversion (This is what's slow!)
    var input = List.generate(1, (i) =>
        List.generate(224, (y) =>
            List.generate(224, (x) =>
                List.generate(3, (c) {
                  var pixel = resizedImage.getPixel(x, y);
                  // Normalization 0 to 1
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