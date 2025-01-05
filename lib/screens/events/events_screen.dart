import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: const Color(0xFF06222F),
      ),
      body: const Center(
        child: Text(
          'Events Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
