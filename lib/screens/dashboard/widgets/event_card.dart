import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;

  const EventCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xff1a2c34),
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
      ),
    );
  }
}
