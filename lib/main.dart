import 'package:events_manager/firebase_options.dart';
import 'package:events_manager/login_page.dart';
import 'package:events_manager/screens/dashboard/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final kcolorscheme =
        ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 61, 70, 76));
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        colorScheme: kcolorscheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kcolorscheme.primary,
          foregroundColor: kcolorscheme.shadow,
        ),
        scaffoldBackgroundColor: kcolorscheme.onSurface,
        cardTheme: const CardTheme().copyWith(
          color: kcolorscheme.primaryContainer,
          elevation: 5,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: kcolorscheme.onPrimary,
            backgroundColor: kcolorscheme.primary,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(kcolorscheme.primary),
          ),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            var user = snapshot.data;
            return DashboardScreen(user: user as User);
          }
          return LoginPage();
        },
      ),
    );
  }
}
