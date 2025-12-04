import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/eco_text_field.dart';
import '../../widgets/primary_button.dart';
import '../home/home_page.dart';
import '../../services/auth_service.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            EcoTextField(
              controller: _emailCtrl,
              hint: 'Enter your email',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 12),
            EcoTextField(
              controller: _passCtrl,
              hint: 'Enter your password',
              icon: Icons.lock_outline,
              obscure: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (v) =>
                      setState(() => rememberMe = v ?? false),
                ),
                const Text('Remember me'),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final email = _emailCtrl.text.trim();
                    if (email.isNotEmpty) {
                      auth.sendPasswordReset(email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password reset email sent.')),
                      );
                    }
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFF00A86B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 4),
              Text(
                auth.error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            PrimaryButton(
              label: auth.isLoading ? 'Loading...' : 'Login',
              onPressed: auth.isLoading
                  ? null
                  : () async {
                final ok = await auth.signIn(
                  _emailCtrl.text.trim(),
                  _passCtrl.text.trim(),
                );
                if (!mounted) return;
                if (ok) {
                  Navigator.pushReplacementNamed(
                    context,
                    HomePage.routeName,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(
                  child: Divider(thickness: 1, color: Color(0xFFE0E0E0)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('Or'),
                ),
                Expanded(
                  child: Divider(thickness: 1, color: Color(0xFFE0E0E0)),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account ? "),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    SignUpPage.routeName,
                  ),
                  child: const Text(
                    'SignUp',
                    style: TextStyle(
                      color: Color(0xFF007BFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
