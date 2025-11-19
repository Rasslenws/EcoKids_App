import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/quiz_service.dart';
import '../pages/auth/splash_page.dart';
import 'app_router.dart';
import 'theme.dart';

class EcoKidsApp extends StatelessWidget {
  const EcoKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<QuizService>(
          create: (_) => QuizService(),
        ),
      ],
      child: MaterialApp(
        title: 'EcoKids',
        debugShowCheckedModeBanner: false,
        theme: buildEcoTheme(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: SplashPage.routeName, // This name will be updated
      ),
    );
  }
}
