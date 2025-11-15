import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'app_router.dart';
import 'theme.dart';

class EcoKidsApp extends StatelessWidget {
  const EcoKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => FirebaseAuthRepository(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) =>
          AuthProvider(ctx.read<AuthRepository>())..listenToAuthChanges(),
        ),
      ],
      child: MaterialApp(
        title: 'EcoKids',
        debugShowCheckedModeBanner: false,
        theme: buildEcoTheme(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: SplashPage.routeName,
      ),
    );
  }
}
