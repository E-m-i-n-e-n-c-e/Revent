import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_manager/firebase_options.dart';
import 'package:events_manager/login_page.dart';
import 'package:events_manager/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:events_manager/event_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

const supabaseUrl = 'https://ttmoltlyckvmfvntgetz.supabase.co';
const supabaseKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0bW9sdGx5Y2t2bWZ2bnRnZXR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc5NzE4OTcsImV4cCI6MjA1MzU0Nzg5N30.26ji5DOeeJkZkZvUdLuI3FoNAVGDLsuEe1boWSiucWY";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Configure Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await supabase.Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  // Initialize notification service after Firebase Auth is initialized
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      // Only initialize notification service when user is logged in
      NotificationService().initialize();
    }
  });

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
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
        cardTheme: const CardThemeData().copyWith(
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
