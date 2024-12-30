import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventManager extends StatefulWidget {
  const EventManager({super.key, required this.user});

  final User user;
  @override
  State<EventManager> createState() => _EventManagerState();
}

class _EventManagerState extends State<EventManager> {
  bool loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Events Manager'),
            const SizedBox(height: 24.0),
            const Text('You are now signed in!'),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
