import 'package:flutter/material.dart';
import '../pages/auth/splash_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/signup_page.dart';
import '../pages/home/home_page.dart';
import '../pages/quiz/quiz_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashPage.routeName:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case LoginPage.routeName:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case SignUpPage.routeName:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case HomePage.routeName:
        return MaterialPageRoute(builder: (_) => const HomePage());

    // Nouveau cas pour la page de Quiz
      case QuizPage.routeName:
      // On s'attend à recevoir une Map avec l'ID, le Titre et l'XP
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuizPage(
            quizId: args['quizId'],
            quizTitle: args['quizTitle'],
            quizXp: args['quizXp'],
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}