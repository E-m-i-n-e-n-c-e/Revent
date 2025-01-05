import 'package:events_manager/firebase_options.dart';
import 'package:events_manager/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:events_manager/event_manager.dart';

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
        ColorScheme.fromSeed(seedColor: const Color(0xff06222F));
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        colorScheme: kcolorscheme,
        appBarTheme: const AppBarTheme().copyWith(
          titleTextStyle:
              const TextStyle(color: Color(0xffAEE7FF), fontSize: 21),
          backgroundColor: Color(0xff1A2C34),
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
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xffAEE7FF),
            fontSize: 26,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
          headlineSmall: TextStyle(
            fontSize: 12,
            fontFamily: 'Inter',
            color: Color(0xffAEE7FF),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontFamily: 'Inter',
            color: Color(0xffAEE7FF),
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
            return EventManager(user: user as User);
          }
          return LoginPage();
        },
      ),
    );
  }
}
