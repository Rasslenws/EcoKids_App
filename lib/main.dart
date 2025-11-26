import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';          // <-- add
import 'app/eco_kids_app.dart';
import 'services/auth_service.dart';
import 'services/quiz_service.dart';
import 'services/learn_service.dart';
import 'services/camera_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<QuizService>(
          create: (_) => QuizService(),
        ),
        Provider<LearnService>(                    // <-- for LearnPage
          create: (_) => LearnService(),
        ),
        Provider<CameraService>
          (create: (_) => CameraService()
        ),
      ],
      child: const EcoKidsApp(),
    ),
  );
}
