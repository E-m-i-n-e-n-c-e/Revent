import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 88),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2C34),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$title\n',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextSpan(
                    text: subtitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          CircleAvatar(
            radius: 48,
            backgroundImage: NetworkImage(image),
          ),
        ],
      ),
    );
  }
}
