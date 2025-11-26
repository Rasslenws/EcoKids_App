import 'dart:io';
import 'package:flutter/material.dart';

class DisplayPicturePage extends StatelessWidget {
  final File imageFile;

  const DisplayPicturePage({required this.imageFile, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captured Picture')),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}