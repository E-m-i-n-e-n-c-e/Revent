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
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF06222F),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.28),
            blurRadius: 20,
            offset: Offset(0, 0),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(51),
                child: Image.network(
                  image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  semanticLabel: 'Club Logo',
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'View more',
                style: TextStyle(
                  color: Color(0xFF83ACBD),
                  fontSize: 11.5,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF83ACBD),
                size: 10,
              )
              // Image.network(
              //   'https://cdn.builder.io/api/v1/image/assets/TEMP/45be4647c1650bfacba402f5c7eacdb2f586e15ace1060d1a358298e7ac94068?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
              //   width: 4,
              //   fit: BoxFit.contain,
              //   semanticLabel: 'View more indicator',
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
