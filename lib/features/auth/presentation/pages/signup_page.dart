// features/auth/presentation/pages/signup_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/eco_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../presentation/providers/auth_provider.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  static const routeName = '/signup';

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Your\nEcoKids Account',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            EcoTextField(
              controller: _nameCtrl,
              hint: 'Enter your name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
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
              label: auth.isLoading ? 'Loading...' : 'Sign up',
              onPressed: auth.isLoading
                  ? null
                  : () async {
                final ok = await auth.signUp(
                  _nameCtrl.text.trim(),
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
            const SizedBox(height: 16),
            _SocialButton(label: 'Google'),
            const SizedBox(height: 10),
            _SocialButton(label: 'Facebook'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account ? '),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    LoginPage.routeName,
                  ),
                  child: const Text(
                    'Login',
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

class _SocialButton extends StatelessWidget {
  final String label;
  const _SocialButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFFF9F9F9),
        ),
        onPressed: () {},
        child: Text(label),
      ),
    );
  }
}
