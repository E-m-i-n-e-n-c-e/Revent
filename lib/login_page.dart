import 'package:events_manager/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:events_manager/utils/signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Events Manager',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24.0),
            GoogleSignInButton(
              onPressed: () async {
                final GoogleSignInAccount? user =
                    await AuthService().signInWithGoogle();
                if (user != null &&
                    !user.email.endsWith("iiitkottayam.ac.in") &&
                    context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please sign in with your IIIT Kottayam account'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
