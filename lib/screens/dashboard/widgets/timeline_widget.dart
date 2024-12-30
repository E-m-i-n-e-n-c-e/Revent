import 'package:flutter/material.dart';

class TimelineWidget extends StatelessWidget {
  final String image;

  const TimelineWidget({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFC5C5C5),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Image.network(
        image,
        width: 326,
        fit: BoxFit.contain,
      ),
    );
  }
}
