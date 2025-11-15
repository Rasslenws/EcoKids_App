import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/eco_kids_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // uses firebase_options.dart
  runApp(const EcoKidsApp());
}
