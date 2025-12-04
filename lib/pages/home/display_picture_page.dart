import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';

class DisplayPicturePage extends StatefulWidget {
  final File imageFile;

  const DisplayPicturePage({required this.imageFile, super.key});

  @override
  State<DisplayPicturePage> createState() => _DisplayPicturePageState();
}

class _DisplayPicturePageState extends State<DisplayPicturePage> {
  String _resultText = "Analyse en cours...";
  bool _isAnalyzing = true;
  bool _hasAnalyzed = false; // Drapeau pour éviter la double analyse

  @override
  void initState() {
    super.initState();
    // Lancer l'analyse après le premier frame pour être sûr que le contexte est prêt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }

  Future<void> _startAnalysis() async {
    if (_hasAnalyzed) return; // Stop si déjà fait
    _hasAnalyzed = true;

    try {
      // On récupère l'instance unique du Provider (listen: false car hors du build)
      final aiService = Provider.of<AIService>(context, listen: false);
      final String result = await aiService.identifyAnimal(widget.imageFile);

      if (!mounted) return;

      setState(() {
        _resultText = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultText = "Erreur inattendue.";
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Photo'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Image.file(widget.imageFile, fit: BoxFit.cover),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Résultat de l'analyse :",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 15),
                if (_isAnalyzing)
                  const CircularProgressIndicator(color: Color(0xFF007BFF))
                else
                  Text(
                    _resultText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007BFF),
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA726),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Retour",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}