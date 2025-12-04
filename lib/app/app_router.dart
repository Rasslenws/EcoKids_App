import 'package:flutter/material.dart';
import '../pages/auth/splash_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/signup_page.dart';
import '../pages/home/home_page.dart';
import '../pages/quiz/quiz_page.dart';
import '../pages/learn/learn_detail_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/profile/quiz_history_page.dart';
import '../models/learn_game_model.dart';

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



      case QuizPage.routeName:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuizPage(
            quizId: args['quizId'],
            quizTitle: args['quizTitle'],
            quizXp: args['quizXp'],
          ),
        );

      case LearnDetailPage.routeName:
        final game = settings.arguments as LearnGameModel;
        return MaterialPageRoute(
          builder: (_) => LearnDetailPage(game: game),
        );

      case ProfilePage.routeName:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case QuizHistoryPage.routeName:
        return MaterialPageRoute(builder: (_) => const QuizHistoryPage());

      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
