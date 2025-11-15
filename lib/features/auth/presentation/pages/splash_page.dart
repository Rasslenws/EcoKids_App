import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import '../../presentation/providers/auth_provider.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _goNext);
  }

  void _goNext() {
    if (!mounted) return;                // safety after delay
    // You can read AuthProvider here if you need it later:
    context.read<AuthProvider>();

    // For now: always go to LoginPage
    Navigator.pushReplacementNamed(
      context,
      LoginPage.routeName,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 16,
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/ecokids_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('EcoKids 1.0'),
          ],
        ),
      ),
    );
  }

}
