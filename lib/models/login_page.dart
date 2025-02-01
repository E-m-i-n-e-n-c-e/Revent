import 'package:events_manager/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool isSigningIn = false;

  void signIn() async {
    setState(() {
      isSigningIn = true;
    });

    final GoogleSignInAccount? user = await AuthService().signInWithGoogle();
    if (user != null &&
        !user.email.endsWith("iiitkottayam.ac.in") &&
        context.mounted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in with your IIIT Kottayam account'),
        ),
      );
    }

    setState(() {
      isSigningIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background SVG
          Image.asset(
            'assets/backgrounds/login_background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 226),
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900, // Extra bold
                      fontFamily: 'Inter',
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF4FBDBA),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Events Management App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Inter',
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF4FBDBA),
                    ),
                  ),
                  const Spacer(),
                  if (isSigningIn)
                    const CircularProgressIndicator()
                  else
                    Container(
                      width: 296,
                      height: 63,
                      margin: const EdgeInsets.only(bottom: 180),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: signIn,
                            child: Image.asset(
                              'assets/icons/google_signin.png',
                              fit: BoxFit.cover,
                              width: 296,
                              height: 63,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
