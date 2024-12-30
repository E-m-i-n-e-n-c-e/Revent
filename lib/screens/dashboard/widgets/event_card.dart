import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;

  const EventCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 198),
      decoration: BoxDecoration(
        color: const Color(0xFFF3913A),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
